#objdump: -dw
#name: x86-64 manual rex prefix use
#notarget: x86_64-*-elf*

.*: +file format .*

Disassembly of section .text:

0+ <_start>:
[	 ]*[0-9a-f]+:[	 ]+40 0f ae 00[	 ]+rex fxsave[	 ]+\(%rax\)
[	 ]*[0-9a-f]+:[	 ]+48 0f ae 00[	 ]+fxsave64[	 ]+\(%rax\)
[	 ]*[0-9a-f]+:[	 ]+41 0f ae 00[	 ]+fxsave[	 ]+\(%r8\)
[	 ]*[0-9a-f]+:[	 ]+49 0f ae 00[	 ]+fxsave64[	 ]+\(%r8\)
[	 ]*[0-9a-f]+:[	 ]+42 0f ae 04 05 00 00 00 00[	 ]+fxsave[	 ]+(0x0)?\(,%r8(,1)?\)
[	 ]*[0-9a-f]+:[	 ]+4a 0f ae 04 05 00 00 00 00[	 ]+fxsave64[	 ]+(0x0)?\(,%r8(,1)?\)
[	 ]*[0-9a-f]+:[	 ]+43 0f ae 04 00[	 ]+fxsave[	 ]+\(%r8,%r8(,1)?\)
[	 ]*[0-9a-f]+:[	 ]+4b 0f ae 04 00[	 ]+fxsave64[	 ]+\(%r8,%r8(,1)?\)
[	 ]*[0-9a-f]+:[	 ]+48 03 04 00[	 ]+add[	 ]+\(%rax,%rax(,1)?\),%rax
[	 ]*[0-9a-f]+:[	 ]+44 03 04 00[	 ]+add[	 ]+\(%rax,%rax(,1)?\),%r8d
[	 ]*[0-9a-f]+:[	 ]+41 03 04 00[	 ]+add[	 ]+\(%r8,%rax(,1)?\),%eax
[	 ]*[0-9a-f]+:[	 ]+42 03 04 00[	 ]+add[	 ]+\(%rax,%r8(,1)?\),%eax
[	 ]*[0-9a-f]+:[	 ]+49 03 04 00[	 ]+add[	 ]+\(%r8,%rax(,1)?\),%rax
[	 ]*[0-9a-f]+:[	 ]+46 03 04 00[	 ]+add[	 ]+\(%rax,%r8(,1)?\),%r8d
[	 ]*[0-9a-f]+:[	 ]+45 03 04 00[	 ]+add[	 ]+\(%r8,%rax(,1)?\),%r8d
[	 ]*[0-9a-f]+:[	 ]+4a 03 04 00[	 ]+add[	 ]+\(%rax,%r8(,1)?\),%rax
[	 ]*[0-9a-f]+:[	 ]+41\s+rex\.B
[	 ]*[0-9a-f]+:[	 ]+9b dd 30\s+fsave\s+\(%rax\)
[	 ]*[0-9a-f]+:[	 ]+9b 41 dd 30\s+fsave\s+\(%r8\)
[	 ]*[0-9a-f]+:[	 ]+40 c5 f9 28 00[	 ]+rex vmovapd \(%rax\),%xmm0
[	 ]*[0-9a-f]+:[	 ]+40[	 ]+rex
[	 ]*[0-9a-f]+:[	 ]+41[	 ]+rex.B
[	 ]*[0-9a-f]+:[	 ]+42[	 ]+rex.X
[	 ]*[0-9a-f]+:[	 ]+43[	 ]+rex.XB
[	 ]*[0-9a-f]+:[	 ]+44[	 ]+rex.R
[	 ]*[0-9a-f]+:[	 ]+45[	 ]+rex.RB
[	 ]*[0-9a-f]+:[	 ]+46[	 ]+rex.RX
[	 ]*[0-9a-f]+:[	 ]+47[	 ]+rex.RXB
[	 ]*[0-9a-f]+:[	 ]+48[	 ]+rex.W
[	 ]*[0-9a-f]+:[	 ]+49[	 ]+rex.WB
[	 ]*[0-9a-f]+:[	 ]+4a[	 ]+rex.WX
[	 ]*[0-9a-f]+:[	 ]+4b[	 ]+rex.WXB
[	 ]*[0-9a-f]+:[	 ]+4c[	 ]+rex.WR
[	 ]*[0-9a-f]+:[	 ]+4d[	 ]+rex.WRB
[	 ]*[0-9a-f]+:[	 ]+4e[	 ]+rex.WRX
[	 ]*[0-9a-f]+:[	 ]+4f[	 ]+rex.WRXB
#pass