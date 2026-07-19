SECTIONS {
  . = SIZEOF_HEADERS;
  . = ALIGN(__section_alignment__);
  .idata __image_base__ + (__section_alignment__ < 0x1000 ? . : __section_alignment__) : {
    SORT(*)(.idata$2); SORT(*)(.idata$3);
    LONG (0); LONG (0); LONG (0); LONG (0); LONG (0);
    SORT(*)(.idata$4); __IAT_start__ = .; SORT(*)(.idata$5); __IAT_end__ = .;
    SORT(*)(.idata$6); SORT(*)(.idata$7);
  }
  .text BLOCK(__section_alignment__) : {
    *(.text) *(SORT(.text$*)) *(.text.*) *(.rdata) *(SORT(.rdata$*))
  }
  .reloc : { *(.reloc) }
}
