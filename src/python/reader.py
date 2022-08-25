# coding=utf-8
import optparse
import shuffleInfo_pb2
import elfParser

x64_reloc_dict = {
    1:  'R_X86_64_64',
    10: 'R_X86_64_32',
    11: 'R_X86_64_32S',
    12: 'R_X86_64_16',
    14: 'R_X86_64_8',

    24: 'R_X86_64_PC64',
    2:  'R_X86_64_PC32',
    39: 'R_X86_64_PC32_BND',
    13: 'R_X86_64_PC16',
    15: 'R_X86_64_PC8',

    25: 'R_X86_64_GOTOFF64',
    4:  'R_X86_64_PLT32',
    40: 'R_X86_64_PLT32_BND',
    31: 'R_X86_64_PLTOFF64',

    9:  'R_X86_64_GOTPCREL',
    41: 'R_X86_64_GOTPCRELX',
    42: 'R_X86_64_REX_GOTPCRELX',
    28: 'R_X86_64_GOTPCREL64',
    3:  'R_X86_64_GOT32',
    27: 'R_X86_64_GOT64',
    30: 'R_X86_64_GOTPLT64',
    26: 'R_X86_64_GOTPC32',
    29: 'R_X86_64_GOTPC64',

    19: 'R_X86_64_TLSGD',
    20: 'R_X86_64_TLSLD',
    34: 'R_X86_64_GOTPC32_TLSDESC',
    35: 'R_X86_64_TLSDESC_CALL',
    17: 'R_X86_64_DTPOFF64',
    21: 'R_X86_64_DTPOFF32',
    22: 'R_X86_64_GOTTPOFF',
    23: 'R_X86_64_TPOFF32',

    37: 'R_X86_64_IRELATIVE',
    38: 'R_X86_64_RELATIVE64',
    8:  'R_X86_64_RELATIVE',

    5:  'R_X86_64_COPY',
    6:  'R_X86_64_GLOB_DAT',
    7:  'R_X86_64_JUMP_SLOT',
    18: 'R_X86_64_TPOFF64',
    16: 'R_X86_64_DTPMOD64',
    36: 'R_X86_64_TLSDESC',

    32: 'R_X86_64_SIZE32',
    33: 'R_X86_64_SIZE64',

    0:  'R_X86_64_NONE',
    250:'R_X86_64_GNU_VTINHERIT',
    251:'R_X86_64_GNU_VTENTRY'
}
BBL_TYPE = {0: "BBL", 1: "FUN", 2: "OBJ", 3: "OBJ_TEMP"}
SRC_TYPE = {0: "C/C++", 1: "Inline Assembly", 2: "Standalone Assembly"}

def readOnly(randInfo, start, elf):
    def printFixups(F, sec):
        if len(F) > 0:
            try:
                sec_VA = elf.section_ranges[sec][0]
            except:
                sec_VA = 0
        else:
            return

        print("Fixups in %s: %d\n" % (sec, len(F)))
        for i in range(len(F)):
            _type = F[i].type

            baseType = _type & 3
            targetType = (_type >> 2) & 3
            isRela = (_type >> 4) & 1
            isNewSection = (_type >> 5) & 1
            isJumpTable = (_type >> 6) & 1
            isFromRand = (_type >> 7) & 1
            isFromReloc = (_type >> 8) & 1
            reloc_type_num = (_type >> 16) & 0xffff
            reloc_type = x64_reloc_dict[reloc_type_num]

            base_str = ""
            if baseType > 1:
                if baseType == 2:
                    if F[i].base_section:
                        type = elf.section_index[F[i].base_section]
                    else:
                        type = ""
                else:
                    type = "INDEX"
                base_str = 'Base:{num}({type}), '.format(
                    num=hex(F[i].base_bbl_sym),
                    type=type)
            target_str = ""
            if targetType > 1:
                if targetType == 2:
                    if F[i].target_section:
                        type = elf.section_index[F[i].target_section]
                    else:
                        type = ""
                else:
                    type = "INDEX"
                target_str = 'Target:{num}({type}),'.format(
                    num=hex(F[i].target_bbl_sym),
                    type=type)
            if F[i].info:
                sec_str = F[i].info
            else:
                try:
                    sec_str = elf.section_index[F[i].section]
                except:
                    sec_str = "Unknown " + str(F[i].section)

            print("\tFixup#%4d VA:0x%04x, offset:0x%04x, Reloc:%s, %s%s add:0x%04x (@Sec %s)%s%s%s%s" % \
                  (i,
                   sec_VA + F[i].offset,
                   F[i].offset,
                   reloc_type,
                   base_str,
                   target_str,
                   F[i].add,
                   sec_str,
                   " (NewSection)" if isNewSection else "",
                   " (JMPTBL)" if isJumpTable else "",
                   " (RAND)" if isFromRand else "",
                   " (RELOC)" if isFromReloc else ""))

    obj = randInfo.bin
    bblLayout = randInfo.layout
    fixups = randInfo.fixup

    print("Rand Object Offset : 0x%04x" % obj.rand_obj_offset)
    print("Total BBLs in .text: %d" % len(bblLayout))

    fallThroughCtr = 0
    offset = 0
    last_section = 0
    last_VA_base = 0
    for idx in range(len(bblLayout)):
        sz = bblLayout[idx].bb_size
        _type = BBL_TYPE[bblLayout[idx].type]

        if bblLayout[idx].bb_fallthrough:
            canFallThrough = "Y"
            fallThroughCtr += 1
        else:
            canFallThrough = "N"

        if bblLayout[idx].section:
            if bblLayout[idx].section == last_section:
                VA_base = last_VA_base
            else:
                try:
                    VA_base = elf.section_ranges[bblLayout[idx].section][0]
                except:
                    VA_base = elf.section_ranges['.text'][0]
        else:
            VA_base = elf.section_ranges['.text'][0]

        print("\tBBL#%4d (%3dB) %s VA: 0x%08x FallThrough: %s %s" % \
              (idx,
               sz,
               _type.ljust(10),
               VA_base + start + offset,
               canFallThrough,
               SRC_TYPE[bblLayout[idx].src_type] if bblLayout[idx].type >= 2 else ""))

        last_section = bblLayout[idx].section
        last_VA_base = VA_base
        offset += sz

    for fi in range(len(fixups)):
        printFixups(fixups[fi].text, '.text')
        printFixups(fixups[fi].rodata, '.rodata')
        printFixups(fixups[fi].data, '.data')
        printFixups(fixups[fi].datarel, '.data.rel.ro')
        printFixups(fixups[fi].initarray, '.init_array')
        printFixups(fixups[fi].got, '.got')
        printFixups(fixups[fi].init, '.init')
        printFixups(fixups[fi].fini, '.fini')


if __name__ == '__main__':

    usage = "Usage: reader.py FilePath (Use -h for help)"
    parser = optparse.OptionParser(usage=usage)
    (options, args) = parser.parse_args()

    if len(args) != 1:
        print("Usage: python3 reader.py FilePath (Use -h for help)")
        exit(1)

    elf = elfParser.ELFParser(args[0])
    if ".rand" not in elf.section_offset:
        print("Cannot find .rand section in {}".format(args[0]))
        exit(1)

    randStart = elf.section_offset['.rand'][0]
    randSize = elf.section_offset['.rand'][1]
    fr = open(args[0], "rb")
    fr.seek(randStart, 0)
    randBytes = fr.read(randSize)
    fr.close()

    RI = shuffleInfo_pb2.ReorderInfo()
    RI.ParseFromString(randBytes)
    readOnly(RI, RI.bin.rand_obj_offset, elf)