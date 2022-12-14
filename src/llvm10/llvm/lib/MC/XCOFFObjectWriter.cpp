//===-- lib/MC/XCOFFObjectWriter.cpp - XCOFF file writer ------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements XCOFF object file writer information.
//
//===----------------------------------------------------------------------===//

#include "llvm/BinaryFormat/XCOFF.h"
#include "llvm/MC/MCAsmLayout.h"
#include "llvm/MC/MCAssembler.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCSectionXCOFF.h"
#include "llvm/MC/MCSymbolXCOFF.h"
#include "llvm/MC/MCValue.h"
#include "llvm/MC/MCXCOFFObjectWriter.h"
#include "llvm/MC/StringTableBuilder.h"
#include "llvm/Support/Error.h"
#include "llvm/Support/MathExtras.h"

#include <deque>

using namespace llvm;

// An XCOFF object file has a limited set of predefined sections. The most
// important ones for us (right now) are:
// .text --> contains program code and read-only data.
// .data --> contains initialized data, function descriptors, and the TOC.
// .bss  --> contains uninitialized data.
// Each of these sections is composed of 'Control Sections'. A Control Section
// is more commonly referred to as a csect. A csect is an indivisible unit of
// code or data, and acts as a container for symbols. A csect is mapped
// into a section based on its storage-mapping class, with the exception of
// XMC_RW which gets mapped to either .data or .bss based on whether it's
// explicitly initialized or not.
//
// We don't represent the sections in the MC layer as there is nothing
// interesting about them at at that level: they carry information that is
// only relevant to the ObjectWriter, so we materialize them in this class.
namespace {

constexpr unsigned DefaultSectionAlign = 4;
constexpr int16_t MaxSectionIndex = INT16_MAX;

// Packs the csect's alignment and type into a byte.
uint8_t getEncodedType(const MCSectionXCOFF *);

// Wrapper around an MCSymbolXCOFF.
struct Symbol {
  const MCSymbolXCOFF *const MCSym;
  uint32_t SymbolTableIndex;

  XCOFF::StorageClass getStorageClass() const {
    return MCSym->getStorageClass();
  }
  StringRef getName() const { return MCSym->getName(); }
  Symbol(const MCSymbolXCOFF *MCSym) : MCSym(MCSym), SymbolTableIndex(-1) {}
};

// Wrapper for an MCSectionXCOFF.
struct ControlSection {
  const MCSectionXCOFF *const MCCsect;
  uint32_t SymbolTableIndex;
  uint32_t Address;
  uint32_t Size;

  SmallVector<Symbol, 1> Syms;
  StringRef getName() const { return MCCsect->getSectionName(); }
  ControlSection(const MCSectionXCOFF *MCSec)
      : MCCsect(MCSec), SymbolTableIndex(-1), Address(-1), Size(0) {}
};

// Type to be used for a container representing a set of csects with
// (approximately) the same storage mapping class. For example all the csects
// with a storage mapping class of `xmc_pr` will get placed into the same
// container.
using CsectGroup = std::deque<ControlSection>;

using CsectGroups = std::deque<CsectGroup *>;

// Represents the data related to a section excluding the csects that make up
// the raw data of the section. The csects are stored separately as not all
// sections contain csects, and some sections contain csects which are better
// stored separately, e.g. the .data section containing read-write, descriptor,
// TOCBase and TOC-entry csects.
struct Section {
  char Name[XCOFF::NameSize];
  // The physical/virtual address of the section. For an object file
  // these values are equivalent.
  uint32_t Address;
  uint32_t Size;
  uint32_t FileOffsetToData;
  uint32_t FileOffsetToRelocations;
  uint32_t RelocationCount;
  int32_t Flags;

  int16_t Index;

  // Virtual sections do not need storage allocated in the object file.
  const bool IsVirtual;

  // XCOFF has special section numbers for symbols:
  // -2 Specifies N_DEBUG, a special symbolic debugging symbol.
  // -1 Specifies N_ABS, an absolute symbol. The symbol has a value but is not
  // relocatable.
  //  0 Specifies N_UNDEF, an undefined external symbol.
  // Therefore, we choose -3 (N_DEBUG - 1) to represent a section index that
  // hasn't been initialized.
  static constexpr int16_t UninitializedIndex =
      XCOFF::ReservedSectionNum::N_DEBUG - 1;

  CsectGroups Groups;

  void reset() {
    Address = 0;
    Size = 0;
    FileOffsetToData = 0;
    FileOffsetToRelocations = 0;
    RelocationCount = 0;
    Index = UninitializedIndex;
    // Clear any csects we have stored.
    for (auto *Group : Groups)
      Group->clear();
  }

  Section(const char *N, XCOFF::SectionTypeFlags Flags, bool IsVirtual,
          CsectGroups Groups)
      : Address(0), Size(0), FileOffsetToData(0), FileOffsetToRelocations(0),
        RelocationCount(0), Flags(Flags), Index(UninitializedIndex),
        IsVirtual(IsVirtual), Groups(Groups) {
    strncpy(Name, N, XCOFF::NameSize);
  }
};

class XCOFFObjectWriter : public MCObjectWriter {

  uint32_t SymbolTableEntryCount = 0;
  uint32_t SymbolTableOffset = 0;
  uint16_t SectionCount = 0;

  support::endian::Writer W;
  std::unique_ptr<MCXCOFFObjectTargetWriter> TargetObjectWriter;
  StringTableBuilder Strings;

  // CsectGroups. These store the csects which make up different parts of
  // the sections. Should have one for each set of csects that get mapped into
  // the same section and get handled in a 'similar' way.
  CsectGroup UndefinedCsects;
  CsectGroup ProgramCodeCsects;
  CsectGroup ReadOnlyCsects;
  CsectGroup DataCsects;
  CsectGroup FuncDSCsects;
  CsectGroup TOCCsects;
  CsectGroup BSSCsects;

  // The Predefined sections.
  Section Text;
  Section Data;
  Section BSS;

  // All the XCOFF sections, in the order they will appear in the section header
  // table.
  std::array<Section *const, 3> Sections{{&Text, &Data, &BSS}};

  CsectGroup &getCsectGroup(const MCSectionXCOFF *MCSec);

  virtual void reset() override;

  void executePostLayoutBinding(MCAssembler &, const MCAsmLayout &) override;

  void recordRelocation(MCAssembler &, const MCAsmLayout &, const MCFragment *,
                        const MCFixup &, MCValue, uint64_t &) override;

  /// xie
  unsigned getRelocType(MCAssembler &Asm,
                        const MCValue &Target,
                        const MCFixup &Fixup,
                        bool IsPCRel) override;
  
  uint64_t writeObject(MCAssembler &, const MCAsmLayout &) override;

  static bool nameShouldBeInStringTable(const StringRef &);
  void writeSymbolName(const StringRef &);
  void writeSymbolTableEntryForCsectMemberLabel(const Symbol &,
                                                const ControlSection &, int16_t,
                                                uint64_t);
  void writeSymbolTableEntryForControlSection(const ControlSection &, int16_t,
                                              XCOFF::StorageClass);
  void writeFileHeader();
  void writeSectionHeaderTable();
  void writeSections(const MCAssembler &Asm, const MCAsmLayout &Layout);
  void writeSymbolTable(const MCAsmLayout &Layout);

  // Called after all the csects and symbols have been processed by
  // `executePostLayoutBinding`, this function handles building up the majority
  // of the structures in the object file representation. Namely:
  // *) Calculates physical/virtual addresses, raw-pointer offsets, and section
  //    sizes.
  // *) Assigns symbol table indices.
  // *) Builds up the section header table by adding any non-empty sections to
  //    `Sections`.
  void assignAddressesAndIndices(const MCAsmLayout &);

  bool
  needsAuxiliaryHeader() const { /* TODO aux header support not implemented. */
    return false;
  }

  // Returns the size of the auxiliary header to be written to the object file.
  size_t auxiliaryHeaderSize() const {
    assert(!needsAuxiliaryHeader() &&
           "Auxiliary header support not implemented.");
    return 0;
  }

public:
  XCOFFObjectWriter(std::unique_ptr<MCXCOFFObjectTargetWriter> MOTW,
                    raw_pwrite_stream &OS);
};

XCOFFObjectWriter::XCOFFObjectWriter(
    std::unique_ptr<MCXCOFFObjectTargetWriter> MOTW, raw_pwrite_stream &OS)
    : W(OS, support::big), TargetObjectWriter(std::move(MOTW)),
      Strings(StringTableBuilder::XCOFF),
      Text(".text", XCOFF::STYP_TEXT, /* IsVirtual */ false,
           CsectGroups{&ProgramCodeCsects, &ReadOnlyCsects}),
      Data(".data", XCOFF::STYP_DATA, /* IsVirtual */ false,
           CsectGroups{&DataCsects, &FuncDSCsects, &TOCCsects}),
      BSS(".bss", XCOFF::STYP_BSS, /* IsVirtual */ true,
          CsectGroups{&BSSCsects}) {}

void XCOFFObjectWriter::reset() {
  UndefinedCsects.clear();

  // Reset any sections we have written to, and empty the section header table.
  for (auto *Sec : Sections)
    Sec->reset();

  // Reset the symbol table and string table.
  SymbolTableEntryCount = 0;
  SymbolTableOffset = 0;
  SectionCount = 0;
  Strings.clear();

  MCObjectWriter::reset();
}

CsectGroup &XCOFFObjectWriter::getCsectGroup(const MCSectionXCOFF *MCSec) {
  switch (MCSec->getMappingClass()) {
  case XCOFF::XMC_PR:
    assert(XCOFF::XTY_SD == MCSec->getCSectType() &&
           "Only an initialized csect can contain program code.");
    return ProgramCodeCsects;
  case XCOFF::XMC_RO:
    assert(XCOFF::XTY_SD == MCSec->getCSectType() &&
           "Only an initialized csect can contain read only data.");
    return ReadOnlyCsects;
  case XCOFF::XMC_RW:
    if (XCOFF::XTY_CM == MCSec->getCSectType())
      return BSSCsects;

    if (XCOFF::XTY_SD == MCSec->getCSectType())
      return DataCsects;

    report_fatal_error("Unhandled mapping of read-write csect to section.");
  case XCOFF::XMC_DS:
    return FuncDSCsects;
  case XCOFF::XMC_BS:
    assert(XCOFF::XTY_CM == MCSec->getCSectType() &&
           "Mapping invalid csect. CSECT with bss storage class must be "
           "common type.");
    return BSSCsects;
  case XCOFF::XMC_TC0:
    assert(XCOFF::XTY_SD == MCSec->getCSectType() &&
           "Only an initialized csect can contain TOC-base.");
    assert(TOCCsects.empty() &&
           "We should have only one TOC-base, and it should be the first csect "
           "in this CsectGroup.");
    return TOCCsects;
  case XCOFF::XMC_TC:
    assert(XCOFF::XTY_SD == MCSec->getCSectType() &&
           "Only an initialized csect can contain TC entry.");
    assert(!TOCCsects.empty() &&
           "We should at least have a TOC-base in this CsectGroup.");
    return TOCCsects;
  default:
    report_fatal_error("Unhandled mapping of csect to section.");
  }
}

void XCOFFObjectWriter::executePostLayoutBinding(MCAssembler &Asm,
                                                 const MCAsmLayout &Layout) {
  if (TargetObjectWriter->is64Bit())
    report_fatal_error("64-bit XCOFF object files are not supported yet.");

  // Maps the MC Section representation to its corresponding ControlSection
  // wrapper. Needed for finding the ControlSection to insert an MCSymbol into
  // from its containing MCSectionXCOFF.
  DenseMap<const MCSectionXCOFF *, ControlSection *> WrapperMap;

  for (const auto &S : Asm) {
    const auto *MCSec = cast<const MCSectionXCOFF>(&S);
    assert(WrapperMap.find(MCSec) == WrapperMap.end() &&
           "Cannot add a csect twice.");
    assert(XCOFF::XTY_ER != MCSec->getCSectType() &&
           "An undefined csect should not get registered.");

    // If the name does not fit in the storage provided in the symbol table
    // entry, add it to the string table.
    if (nameShouldBeInStringTable(MCSec->getSectionName()))
      Strings.add(MCSec->getSectionName());

    CsectGroup &Group = getCsectGroup(MCSec);
    Group.emplace_back(MCSec);
    WrapperMap[MCSec] = &Group.back();
  }

  for (const MCSymbol &S : Asm.symbols()) {
    // Nothing to do for temporary symbols.
    if (S.isTemporary())
      continue;

    const MCSymbolXCOFF *XSym = cast<MCSymbolXCOFF>(&S);
    const MCSectionXCOFF *ContainingCsect = XSym->getContainingCsect();

    // Handle undefined symbol.
    if (ContainingCsect->getCSectType() == XCOFF::XTY_ER) {
      UndefinedCsects.emplace_back(ContainingCsect);
      continue;
    }

    // If the symbol is the csect itself, we don't need to put the symbol
    // into csect's Syms.
    if (XSym == ContainingCsect->getQualNameSymbol())
      continue;

    assert(WrapperMap.find(ContainingCsect) != WrapperMap.end() &&
           "Expected containing csect to exist in map");

    // Lookup the containing csect and add the symbol to it.
    WrapperMap[ContainingCsect]->Syms.emplace_back(XSym);

    // If the name does not fit in the storage provided in the symbol table
    // entry, add it to the string table.
    if (nameShouldBeInStringTable(XSym->getName()))
      Strings.add(XSym->getName());
    }

  Strings.finalize();
  assignAddressesAndIndices(Layout);
}

/// xie
unsigned XCOFFObjectWriter::getRelocType(MCAssembler &Asm,
                                       const MCValue &Target,
                                       const MCFixup &Fixup,
                                       bool IsPCRel){
  // TODO: recordRelocation is not yet implemented.
  return 0;
}

void XCOFFObjectWriter::recordRelocation(MCAssembler &, const MCAsmLayout &,
                                         const MCFragment *, const MCFixup &,
                                         MCValue, uint64_t &) {
  // TODO: recordRelocation is not yet implemented.
}

void XCOFFObjectWriter::writeSections(const MCAssembler &Asm,
                                      const MCAsmLayout &Layout) {
  uint32_t CurrentAddressLocation = 0;
  for (const auto *Section : Sections) {
    // Nothing to write for this Section.
    if (Section->Index == Section::UninitializedIndex || Section->IsVirtual)
      continue;

    assert(CurrentAddressLocation == Section->Address &&
           "Sections should be written consecutively.");
    for (const auto *Group : Section->Groups) {
      for (const auto &Csect : *Group) {
        if (uint32_t PaddingSize = Csect.Address - CurrentAddressLocation)
          W.OS.write_zeros(PaddingSize);
        if (Csect.Size)
          Asm.writeSectionData(W.OS, Csect.MCCsect, Layout);
        CurrentAddressLocation = Csect.Address + Csect.Size;
      }
    }

    // The size of the tail padding in a section is the end virtual address of
    // the current section minus the the end virtual address of the last csect
    // in that section.
    if (uint32_t PaddingSize =
            Section->Address + Section->Size - CurrentAddressLocation) {
      W.OS.write_zeros(PaddingSize);
      CurrentAddressLocation += PaddingSize;
    }
  }
}

uint64_t XCOFFObjectWriter::writeObject(MCAssembler &Asm,
                                        const MCAsmLayout &Layout) {
  // We always emit a timestamp of 0 for reproducibility, so ensure incremental
  // linking is not enabled, in case, like with Windows COFF, such a timestamp
  // is incompatible with incremental linking of XCOFF.
  if (Asm.isIncrementalLinkerCompatible())
    report_fatal_error("Incremental linking not supported for XCOFF.");

  if (TargetObjectWriter->is64Bit())
    report_fatal_error("64-bit XCOFF object files are not supported yet.");

  uint64_t StartOffset = W.OS.tell();

  writeFileHeader();
  writeSectionHeaderTable();
  writeSections(Asm, Layout);
  // TODO writeRelocations();

  writeSymbolTable(Layout);
  // Write the string table.
  Strings.write(W.OS);

  return W.OS.tell() - StartOffset;
}

bool XCOFFObjectWriter::nameShouldBeInStringTable(const StringRef &SymbolName) {
  return SymbolName.size() > XCOFF::NameSize;
}

void XCOFFObjectWriter::writeSymbolName(const StringRef &SymbolName) {
  if (nameShouldBeInStringTable(SymbolName)) {
    W.write<int32_t>(0);
    W.write<uint32_t>(Strings.getOffset(SymbolName));
  } else {
    char Name[XCOFF::NameSize+1];
    std::strncpy(Name, SymbolName.data(), XCOFF::NameSize);
    ArrayRef<char> NameRef(Name, XCOFF::NameSize);
    W.write(NameRef);
  }
}

void XCOFFObjectWriter::writeSymbolTableEntryForCsectMemberLabel(
    const Symbol &SymbolRef, const ControlSection &CSectionRef,
    int16_t SectionIndex, uint64_t SymbolOffset) {
  // Name or Zeros and string table offset
  writeSymbolName(SymbolRef.getName());
  assert(SymbolOffset <= UINT32_MAX - CSectionRef.Address &&
         "Symbol address overflows.");
  W.write<uint32_t>(CSectionRef.Address + SymbolOffset);
  W.write<int16_t>(SectionIndex);
  // Basic/Derived type. See the description of the n_type field for symbol
  // table entries for a detailed description. Since we don't yet support
  // visibility, and all other bits are either optionally set or reserved, this
  // is always zero.
  // TODO FIXME How to assert a symbol's visibilty is default?
  // TODO Set the function indicator (bit 10, 0x0020) for functions
  // when debugging is enabled.
  W.write<uint16_t>(0);
  W.write<uint8_t>(SymbolRef.getStorageClass());
  // Always 1 aux entry for now.
  W.write<uint8_t>(1);

  // Now output the auxiliary entry.
  W.write<uint32_t>(CSectionRef.SymbolTableIndex);
  // Parameter typecheck hash. Not supported.
  W.write<uint32_t>(0);
  // Typecheck section number. Not supported.
  W.write<uint16_t>(0);
  // Symbol type: Label
  W.write<uint8_t>(XCOFF::XTY_LD);
  // Storage mapping class.
  W.write<uint8_t>(CSectionRef.MCCsect->getMappingClass());
  // Reserved (x_stab).
  W.write<uint32_t>(0);
  // Reserved (x_snstab).
  W.write<uint16_t>(0);
}

void XCOFFObjectWriter::writeSymbolTableEntryForControlSection(
    const ControlSection &CSectionRef, int16_t SectionIndex,
    XCOFF::StorageClass StorageClass) {
  // n_name, n_zeros, n_offset
  writeSymbolName(CSectionRef.getName());
  // n_value
  W.write<uint32_t>(CSectionRef.Address);
  // n_scnum
  W.write<int16_t>(SectionIndex);
  // Basic/Derived type. See the description of the n_type field for symbol
  // table entries for a detailed description. Since we don't yet support
  // visibility, and all other bits are either optionally set or reserved, this
  // is always zero.
  // TODO FIXME How to assert a symbol's visibilty is default?
  // TODO Set the function indicator (bit 10, 0x0020) for functions
  // when debugging is enabled.
  W.write<uint16_t>(0);
  // n_sclass
  W.write<uint8_t>(StorageClass);
  // Always 1 aux entry for now.
  W.write<uint8_t>(1);

  // Now output the auxiliary entry.
  W.write<uint32_t>(CSectionRef.Size);
  // Parameter typecheck hash. Not supported.
  W.write<uint32_t>(0);
  // Typecheck section number. Not supported.
  W.write<uint16_t>(0);
  // Symbol type.
  W.write<uint8_t>(getEncodedType(CSectionRef.MCCsect));
  // Storage mapping class.
  W.write<uint8_t>(CSectionRef.MCCsect->getMappingClass());
  // Reserved (x_stab).
  W.write<uint32_t>(0);
  // Reserved (x_snstab).
  W.write<uint16_t>(0);
}

void XCOFFObjectWriter::writeFileHeader() {
  // Magic.
  W.write<uint16_t>(0x01df);
  // Number of sections.
  W.write<uint16_t>(SectionCount);
  // Timestamp field. For reproducible output we write a 0, which represents no
  // timestamp.
  W.write<int32_t>(0);
  // Byte Offset to the start of the symbol table.
  W.write<uint32_t>(SymbolTableOffset);
  // Number of entries in the symbol table.
  W.write<int32_t>(SymbolTableEntryCount);
  // Size of the optional header.
  W.write<uint16_t>(0);
  // Flags.
  W.write<uint16_t>(0);
}

void XCOFFObjectWriter::writeSectionHeaderTable() {
  for (const auto *Sec : Sections) {
    // Nothing to write for this Section.
    if (Sec->Index == Section::UninitializedIndex)
      continue;

    // Write Name.
    ArrayRef<char> NameRef(Sec->Name, XCOFF::NameSize);
    W.write(NameRef);

    // Write the Physical Address and Virtual Address. In an object file these
    // are the same.
    W.write<uint32_t>(Sec->Address);
    W.write<uint32_t>(Sec->Address);

    W.write<uint32_t>(Sec->Size);
    W.write<uint32_t>(Sec->FileOffsetToData);

    // Relocation pointer and Lineno pointer. Not supported yet.
    W.write<uint32_t>(0);
    W.write<uint32_t>(0);

    // Relocation and line-number counts. Not supported yet.
    W.write<uint16_t>(0);
    W.write<uint16_t>(0);

    W.write<int32_t>(Sec->Flags);
  }
}

void XCOFFObjectWriter::writeSymbolTable(const MCAsmLayout &Layout) {
  for (const auto &Csect : UndefinedCsects) {
    writeSymbolTableEntryForControlSection(
        Csect, XCOFF::ReservedSectionNum::N_UNDEF, Csect.MCCsect->getStorageClass());
  }

  for (const auto *Section : Sections) {
    // Nothing to write for this Section.
    if (Section->Index == Section::UninitializedIndex)
      continue;

    for (const auto *Group : Section->Groups) {
      if (Group->empty())
        continue;

      const int16_t SectionIndex = Section->Index;
      for (const auto &Csect : *Group) {
        // Write out the control section first and then each symbol in it.
        writeSymbolTableEntryForControlSection(
            Csect, SectionIndex, Csect.MCCsect->getStorageClass());

        for (const auto &Sym : Csect.Syms)
          writeSymbolTableEntryForCsectMemberLabel(
              Sym, Csect, SectionIndex, Layout.getSymbolOffset(*(Sym.MCSym)));
      }
    }
  }
}

void XCOFFObjectWriter::assignAddressesAndIndices(const MCAsmLayout &Layout) {
  // The first symbol table entry is for the file name. We are not emitting it
  // yet, so start at index 0.
  uint32_t SymbolTableIndex = 0;

  // Calculate indices for undefined symbols.
  for (auto &Csect : UndefinedCsects) {
    Csect.Size = 0;
    Csect.Address = 0;
    Csect.SymbolTableIndex = SymbolTableIndex;
    // 1 main and 1 auxiliary symbol table entry for each contained symbol.
    SymbolTableIndex += 2;
  }

  // The address corrresponds to the address of sections and symbols in the
  // object file. We place the shared address 0 immediately after the
  // section header table.
  uint32_t Address = 0;
  // Section indices are 1-based in XCOFF.
  int32_t SectionIndex = 1;

  for (auto *Section : Sections) {
    const bool IsEmpty =
        llvm::all_of(Section->Groups,
                     [](const CsectGroup *Group) { return Group->empty(); });
    if (IsEmpty)
      continue;

    if (SectionIndex > MaxSectionIndex)
      report_fatal_error("Section index overflow!");
    Section->Index = SectionIndex++;
    SectionCount++;

    bool SectionAddressSet = false;
    for (auto *Group : Section->Groups) {
      if (Group->empty())
        continue;

      for (auto &Csect : *Group) {
        const MCSectionXCOFF *MCSec = Csect.MCCsect;
        Csect.Address = alignTo(Address, MCSec->getAlignment());
        Csect.Size = Layout.getSectionAddressSize(MCSec);
        Address = Csect.Address + Csect.Size;
        Csect.SymbolTableIndex = SymbolTableIndex;
        // 1 main and 1 auxiliary symbol table entry for the csect.
        SymbolTableIndex += 2;
        
        for (auto &Sym : Csect.Syms) {
          Sym.SymbolTableIndex = SymbolTableIndex;
          // 1 main and 1 auxiliary symbol table entry for each contained
          // symbol.
          SymbolTableIndex += 2;
        }
      }

      if (!SectionAddressSet) {
        Section->Address = Group->front().Address;
        SectionAddressSet = true;
      }
    }

    // Make sure the address of the next section aligned to
    // DefaultSectionAlign.
    Address = alignTo(Address, DefaultSectionAlign);
    Section->Size = Address - Section->Address;
  }

  SymbolTableEntryCount = SymbolTableIndex;

  // Calculate the RawPointer value for each section.
  uint64_t RawPointer = sizeof(XCOFF::FileHeader32) + auxiliaryHeaderSize() +
                        SectionCount * sizeof(XCOFF::SectionHeader32);
  for (auto *Sec : Sections) {
    if (Sec->Index == Section::UninitializedIndex || Sec->IsVirtual)
      continue;

    Sec->FileOffsetToData = RawPointer;
    RawPointer += Sec->Size;
  }

  // TODO Add in Relocation storage to the RawPointer Calculation.
  // TODO What to align the SymbolTable to?
  // TODO Error check that the number of symbol table entries fits in 32-bits
  // signed ...
  if (SymbolTableEntryCount)
    SymbolTableOffset = RawPointer;
}

// Takes the log base 2 of the alignment and shifts the result into the 5 most
// significant bits of a byte, then or's in the csect type into the least
// significant 3 bits.
uint8_t getEncodedType(const MCSectionXCOFF *Sec) {
  unsigned Align = Sec->getAlignment();
  assert(isPowerOf2_32(Align) && "Alignment must be a power of 2.");
  unsigned Log2Align = Log2_32(Align);
  // Result is a number in the range [0, 31] which fits in the 5 least
  // significant bits. Shift this value into the 5 most significant bits, and
  // bitwise-or in the csect type.
  uint8_t EncodedAlign = Log2Align << 3;
  return EncodedAlign | Sec->getCSectType();
}

} // end anonymous namespace

std::unique_ptr<MCObjectWriter>
llvm::createXCOFFObjectWriter(std::unique_ptr<MCXCOFFObjectTargetWriter> MOTW,
                              raw_pwrite_stream &OS) {
  return std::make_unique<XCOFFObjectWriter>(std::move(MOTW), OS);
}
