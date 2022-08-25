//===-- AVRAsmBackend.h - AVR Asm Backend  --------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// \file The AVR assembly backend implementation.
//
//===----------------------------------------------------------------------===//
//

#ifndef LLVM_AVR_ASM_BACKEND_H
#define LLVM_AVR_ASM_BACKEND_H

#include "MCTargetDesc/AVRFixupKinds.h"

#include "llvm/ADT/Triple.h"
#include "llvm/MC/MCAsmBackend.h"

namespace llvm {

class MCAssembler;
class MCObjectWriter;
class Target;

struct MCFixupKindInfo;

/// Utilities for manipulating generated AVR machine code.
class AVRAsmBackend : public MCAsmBackend {
public:
  AVRAsmBackend(Triple::OSType OSType)
      : MCAsmBackend(support::little), OSType(OSType) {}

  void adjustFixupValue(const MCFixup &Fixup, const MCValue &Target,
                        uint64_t &Value, MCContext *Ctx = nullptr) const;

  std::unique_ptr<MCObjectTargetWriter>
  createObjectTargetWriter() const override;

  void applyFixup(const MCAssembler &Asm, const MCFixup &Fixup,
                  const MCValue &Target, MutableArrayRef<char> Data,
                  uint64_t Value, bool IsResolved,
                  const MCSubtargetInfo *STI) const override;

  const MCFixupKindInfo &getFixupKindInfo(MCFixupKind Kind) const override;

  unsigned getNumFixupKinds() const override {
    return AVR::NumTargetFixupKinds;
  }

  bool mayNeedRelaxation(const MCInst &Inst,
                         const MCSubtargetInfo &STI) const override {
    return false;
  }

  bool fixupNeedsRelaxation(const MCFixup &Fixup, uint64_t Value,
                            const MCRelaxableFragment *DF,
                            const MCAsmLayout &Layout) const override {
    llvm_unreachable("RelaxInstruction() unimplemented");
    return false;
  }

  void relaxInstruction(const MCInst &Inst, const MCSubtargetInfo &STI,
                        MCInst &Res) const override {}

  bool writeNopData(raw_ostream &OS, uint64_t Count) const override;

  // Koo [N/A Here]
  unsigned getFixupKindLog2Size(unsigned Kind) const override { return 0; }

  bool shouldForceRelocation(const MCAssembler &Asm, const MCFixup &Fixup,
                             const MCValue &Target) override;

private:
  Triple::OSType OSType;
};

} // end namespace llvm

#endif // LLVM_AVR_ASM_BACKEND_H

