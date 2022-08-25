#as: -march=armv8.4-a+fp16 -mfpu=neon-fp-armv8
#source: armv8_2-a-fp16.s
#objdump: -d

.*: +file format .*arm.*

Disassembly of section .text:

.* <.*>:
.*:	fc210810 	vfmal.f16	d0, s2, s0
.*:	fe002810 	vfmal.f16	d2, s0, s0\[0\]
.*:	fca10810 	vfmsl.f16	d0, s2, s0
.*:	fe102818 	vfmsl.f16	d2, s0, s0\[1\]
.*:	fc210814 	vfmal.f16	d0, s2, s8
.*:	fe002814 	vfmal.f16	d2, s0, s8\[0\]
.*:	fca10814 	vfmsl.f16	d0, s2, s8
.*:	fe10281c 	vfmsl.f16	d2, s0, s8\[1\]
.*:	fc210837 	vfmal.f16	d0, s2, s15
.*:	fe002837 	vfmal.f16	d2, s0, s15\[0\]
.*:	fca10837 	vfmsl.f16	d0, s2, s15
.*:	fe10283f 	vfmsl.f16	d2, s0, s15\[1\]
.*:	fc270890 	vfmal.f16	d0, s15, s0
.*:	fe00f810 	vfmal.f16	d15, s0, s0\[0\]
.*:	fca70890 	vfmsl.f16	d0, s15, s0
.*:	fe10f818 	vfmsl.f16	d15, s0, s0\[1\]
.*:	fc270894 	vfmal.f16	d0, s15, s8
.*:	fe00f814 	vfmal.f16	d15, s0, s8\[0\]
.*:	fca70894 	vfmsl.f16	d0, s15, s8
.*:	fe10f81c 	vfmsl.f16	d15, s0, s8\[1\]
.*:	fc2708b7 	vfmal.f16	d0, s15, s15
.*:	fe00f837 	vfmal.f16	d15, s0, s15\[0\]
.*:	fca708b7 	vfmsl.f16	d0, s15, s15
.*:	fe10f83f 	vfmsl.f16	d15, s0, s15\[1\]
.*:	fc2f0810 	vfmal.f16	d0, s30, s0
.*:	fe40e810 	vfmal.f16	d30, s0, s0\[0\]
.*:	fcaf0810 	vfmsl.f16	d0, s30, s0
.*:	fe50e818 	vfmsl.f16	d30, s0, s0\[1\]
.*:	fc2f0814 	vfmal.f16	d0, s30, s8
.*:	fe40e814 	vfmal.f16	d30, s0, s8\[0\]
.*:	fcaf0814 	vfmsl.f16	d0, s30, s8
.*:	fe50e81c 	vfmsl.f16	d30, s0, s8\[1\]
.*:	fc2f0837 	vfmal.f16	d0, s30, s15
.*:	fe40e837 	vfmal.f16	d30, s0, s15\[0\]
.*:	fcaf0837 	vfmsl.f16	d0, s30, s15
.*:	fe50e83f 	vfmsl.f16	d30, s0, s15\[1\]
.*:	fc217810 	vfmal.f16	d7, s2, s0
.*:	fe032890 	vfmal.f16	d2, s7, s0\[0\]
.*:	fca17810 	vfmsl.f16	d7, s2, s0
.*:	fe132898 	vfmsl.f16	d2, s7, s0\[1\]
.*:	fc217814 	vfmal.f16	d7, s2, s8
.*:	fe032894 	vfmal.f16	d2, s7, s8\[0\]
.*:	fca17814 	vfmsl.f16	d7, s2, s8
.*:	fe13289c 	vfmsl.f16	d2, s7, s8\[1\]
.*:	fc217837 	vfmal.f16	d7, s2, s15
.*:	fe0328b7 	vfmal.f16	d2, s7, s15\[0\]
.*:	fca17837 	vfmsl.f16	d7, s2, s15
.*:	fe1328bf 	vfmsl.f16	d2, s7, s15\[1\]
.*:	fc277890 	vfmal.f16	d7, s15, s0
.*:	fe03f890 	vfmal.f16	d15, s7, s0\[0\]
.*:	fca77890 	vfmsl.f16	d7, s15, s0
.*:	fe13f898 	vfmsl.f16	d15, s7, s0\[1\]
.*:	fc277894 	vfmal.f16	d7, s15, s8
.*:	fe03f894 	vfmal.f16	d15, s7, s8\[0\]
.*:	fca77894 	vfmsl.f16	d7, s15, s8
.*:	fe13f89c 	vfmsl.f16	d15, s7, s8\[1\]
.*:	fc2778b7 	vfmal.f16	d7, s15, s15
.*:	fe03f8b7 	vfmal.f16	d15, s7, s15\[0\]
.*:	fca778b7 	vfmsl.f16	d7, s15, s15
.*:	fe13f8bf 	vfmsl.f16	d15, s7, s15\[1\]
.*:	fc2f7810 	vfmal.f16	d7, s30, s0
.*:	fe43e890 	vfmal.f16	d30, s7, s0\[0\]
.*:	fcaf7810 	vfmsl.f16	d7, s30, s0
.*:	fe53e898 	vfmsl.f16	d30, s7, s0\[1\]
.*:	fc2f7814 	vfmal.f16	d7, s30, s8
.*:	fe43e894 	vfmal.f16	d30, s7, s8\[0\]
.*:	fcaf7814 	vfmsl.f16	d7, s30, s8
.*:	fe53e89c 	vfmsl.f16	d30, s7, s8\[1\]
.*:	fc2f7837 	vfmal.f16	d7, s30, s15
.*:	fe43e8b7 	vfmal.f16	d30, s7, s15\[0\]
.*:	fcaf7837 	vfmsl.f16	d7, s30, s15
.*:	fe53e8bf 	vfmsl.f16	d30, s7, s15\[1\]
.*:	fc610810 	vfmal.f16	d16, s2, s0
.*:	fe082810 	vfmal.f16	d2, s16, s0\[0\]
.*:	fce10810 	vfmsl.f16	d16, s2, s0
.*:	fe182818 	vfmsl.f16	d2, s16, s0\[1\]
.*:	fc610814 	vfmal.f16	d16, s2, s8
.*:	fe082814 	vfmal.f16	d2, s16, s8\[0\]
.*:	fce10814 	vfmsl.f16	d16, s2, s8
.*:	fe18281c 	vfmsl.f16	d2, s16, s8\[1\]
.*:	fc610837 	vfmal.f16	d16, s2, s15
.*:	fe082837 	vfmal.f16	d2, s16, s15\[0\]
.*:	fce10837 	vfmsl.f16	d16, s2, s15
.*:	fe18283f 	vfmsl.f16	d2, s16, s15\[1\]
.*:	fc670890 	vfmal.f16	d16, s15, s0
.*:	fe08f810 	vfmal.f16	d15, s16, s0\[0\]
.*:	fce70890 	vfmsl.f16	d16, s15, s0
.*:	fe18f818 	vfmsl.f16	d15, s16, s0\[1\]
.*:	fc670894 	vfmal.f16	d16, s15, s8
.*:	fe08f814 	vfmal.f16	d15, s16, s8\[0\]
.*:	fce70894 	vfmsl.f16	d16, s15, s8
.*:	fe18f81c 	vfmsl.f16	d15, s16, s8\[1\]
.*:	fc6708b7 	vfmal.f16	d16, s15, s15
.*:	fe08f837 	vfmal.f16	d15, s16, s15\[0\]
.*:	fce708b7 	vfmsl.f16	d16, s15, s15
.*:	fe18f83f 	vfmsl.f16	d15, s16, s15\[1\]
.*:	fc6f0810 	vfmal.f16	d16, s30, s0
.*:	fe48e810 	vfmal.f16	d30, s16, s0\[0\]
.*:	fcef0810 	vfmsl.f16	d16, s30, s0
.*:	fe58e818 	vfmsl.f16	d30, s16, s0\[1\]
.*:	fc6f0814 	vfmal.f16	d16, s30, s8
.*:	fe48e814 	vfmal.f16	d30, s16, s8\[0\]
.*:	fcef0814 	vfmsl.f16	d16, s30, s8
.*:	fe58e81c 	vfmsl.f16	d30, s16, s8\[1\]
.*:	fc6f0837 	vfmal.f16	d16, s30, s15
.*:	fe48e837 	vfmal.f16	d30, s16, s15\[0\]
.*:	fcef0837 	vfmsl.f16	d16, s30, s15
.*:	fe58e83f 	vfmsl.f16	d30, s16, s15\[1\]
.*:	fc61f810 	vfmal.f16	d31, s2, s0
.*:	fe0f2890 	vfmal.f16	d2, s31, s0\[0\]
.*:	fce1f810 	vfmsl.f16	d31, s2, s0
.*:	fe1f2898 	vfmsl.f16	d2, s31, s0\[1\]
.*:	fc61f814 	vfmal.f16	d31, s2, s8
.*:	fe0f2894 	vfmal.f16	d2, s31, s8\[0\]
.*:	fce1f814 	vfmsl.f16	d31, s2, s8
.*:	fe1f289c 	vfmsl.f16	d2, s31, s8\[1\]
.*:	fc61f837 	vfmal.f16	d31, s2, s15
.*:	fe0f28b7 	vfmal.f16	d2, s31, s15\[0\]
.*:	fce1f837 	vfmsl.f16	d31, s2, s15
.*:	fe1f28bf 	vfmsl.f16	d2, s31, s15\[1\]
.*:	fc67f890 	vfmal.f16	d31, s15, s0
.*:	fe0ff890 	vfmal.f16	d15, s31, s0\[0\]
.*:	fce7f890 	vfmsl.f16	d31, s15, s0
.*:	fe1ff898 	vfmsl.f16	d15, s31, s0\[1\]
.*:	fc67f894 	vfmal.f16	d31, s15, s8
.*:	fe0ff894 	vfmal.f16	d15, s31, s8\[0\]
.*:	fce7f894 	vfmsl.f16	d31, s15, s8
.*:	fe1ff89c 	vfmsl.f16	d15, s31, s8\[1\]
.*:	fc67f8b7 	vfmal.f16	d31, s15, s15
.*:	fe0ff8b7 	vfmal.f16	d15, s31, s15\[0\]
.*:	fce7f8b7 	vfmsl.f16	d31, s15, s15
.*:	fe1ff8bf 	vfmsl.f16	d15, s31, s15\[1\]
.*:	fc6ff810 	vfmal.f16	d31, s30, s0
.*:	fe4fe890 	vfmal.f16	d30, s31, s0\[0\]
.*:	fceff810 	vfmsl.f16	d31, s30, s0
.*:	fe5fe898 	vfmsl.f16	d30, s31, s0\[1\]
.*:	fc6ff814 	vfmal.f16	d31, s30, s8
.*:	fe4fe894 	vfmal.f16	d30, s31, s8\[0\]
.*:	fceff814 	vfmsl.f16	d31, s30, s8
.*:	fe5fe89c 	vfmsl.f16	d30, s31, s8\[1\]
.*:	fc6ff837 	vfmal.f16	d31, s30, s15
.*:	fe4fe8b7 	vfmal.f16	d30, s31, s15\[0\]
.*:	fceff837 	vfmsl.f16	d31, s30, s15
.*:	fe5fe8bf 	vfmsl.f16	d30, s31, s15\[1\]
.*:	fc204850 	vfmal.f16	q2, d0, d0
.*:	fe020850 	vfmal.f16	q0, d2, d0\[0\]
.*:	fca04850 	vfmsl.f16	q2, d0, d0
.*:	fe120878 	vfmsl.f16	q0, d2, d0\[3\]
.*:	fc204857 	vfmal.f16	q2, d0, d7
.*:	fe020857 	vfmal.f16	q0, d2, d7\[0\]
.*:	fca04857 	vfmsl.f16	q2, d0, d7
.*:	fe12087f 	vfmsl.f16	q0, d2, d7\[3\]
.*:	fc206850 	vfmal.f16	q3, d0, d0
.*:	fe030850 	vfmal.f16	q0, d3, d0\[0\]
.*:	fca06850 	vfmsl.f16	q3, d0, d0
.*:	fe130878 	vfmsl.f16	q0, d3, d0\[3\]
.*:	fc206857 	vfmal.f16	q3, d0, d7
.*:	fe030857 	vfmal.f16	q0, d3, d7\[0\]
.*:	fca06857 	vfmsl.f16	q3, d0, d7
.*:	fe13087f 	vfmsl.f16	q0, d3, d7\[3\]
.*:	fc60a850 	vfmal.f16	q13, d0, d0
.*:	fe0d0850 	vfmal.f16	q0, d13, d0\[0\]
.*:	fce0a850 	vfmsl.f16	q13, d0, d0
.*:	fe1d0878 	vfmsl.f16	q0, d13, d0\[3\]
.*:	fc60a857 	vfmal.f16	q13, d0, d7
.*:	fe0d0857 	vfmal.f16	q0, d13, d7\[0\]
.*:	fce0a857 	vfmsl.f16	q13, d0, d7
.*:	fe1d087f 	vfmsl.f16	q0, d13, d7\[3\]
.*:	fc214850 	vfmal.f16	q2, d1, d0
.*:	fe022850 	vfmal.f16	q1, d2, d0\[0\]
.*:	fca14850 	vfmsl.f16	q2, d1, d0
.*:	fe122878 	vfmsl.f16	q1, d2, d0\[3\]
.*:	fc214857 	vfmal.f16	q2, d1, d7
.*:	fe022857 	vfmal.f16	q1, d2, d7\[0\]
.*:	fca14857 	vfmsl.f16	q2, d1, d7
.*:	fe12287f 	vfmsl.f16	q1, d2, d7\[3\]
.*:	fc216850 	vfmal.f16	q3, d1, d0
.*:	fe032850 	vfmal.f16	q1, d3, d0\[0\]
.*:	fca16850 	vfmsl.f16	q3, d1, d0
.*:	fe132878 	vfmsl.f16	q1, d3, d0\[3\]
.*:	fc216857 	vfmal.f16	q3, d1, d7
.*:	fe032857 	vfmal.f16	q1, d3, d7\[0\]
.*:	fca16857 	vfmsl.f16	q3, d1, d7
.*:	fe13287f 	vfmsl.f16	q1, d3, d7\[3\]
.*:	fc61a850 	vfmal.f16	q13, d1, d0
.*:	fe0d2850 	vfmal.f16	q1, d13, d0\[0\]
.*:	fce1a850 	vfmsl.f16	q13, d1, d0
.*:	fe1d2878 	vfmsl.f16	q1, d13, d0\[3\]
.*:	fc61a857 	vfmal.f16	q13, d1, d7
.*:	fe0d2857 	vfmal.f16	q1, d13, d7\[0\]
.*:	fce1a857 	vfmsl.f16	q13, d1, d7
.*:	fe1d287f 	vfmsl.f16	q1, d13, d7\[3\]
.*:	fc264850 	vfmal.f16	q2, d6, d0
.*:	fe02c850 	vfmal.f16	q6, d2, d0\[0\]
.*:	fca64850 	vfmsl.f16	q2, d6, d0
.*:	fe12c878 	vfmsl.f16	q6, d2, d0\[3\]
.*:	fc264857 	vfmal.f16	q2, d6, d7
.*:	fe02c857 	vfmal.f16	q6, d2, d7\[0\]
.*:	fca64857 	vfmsl.f16	q2, d6, d7
.*:	fe12c87f 	vfmsl.f16	q6, d2, d7\[3\]
.*:	fc266850 	vfmal.f16	q3, d6, d0
.*:	fe03c850 	vfmal.f16	q6, d3, d0\[0\]
.*:	fca66850 	vfmsl.f16	q3, d6, d0
.*:	fe13c878 	vfmsl.f16	q6, d3, d0\[3\]
.*:	fc266857 	vfmal.f16	q3, d6, d7
.*:	fe03c857 	vfmal.f16	q6, d3, d7\[0\]
.*:	fca66857 	vfmsl.f16	q3, d6, d7
.*:	fe13c87f 	vfmsl.f16	q6, d3, d7\[3\]
.*:	fc66a850 	vfmal.f16	q13, d6, d0
.*:	fe0dc850 	vfmal.f16	q6, d13, d0\[0\]
.*:	fce6a850 	vfmsl.f16	q13, d6, d0
.*:	fe1dc878 	vfmsl.f16	q6, d13, d0\[3\]
.*:	fc66a857 	vfmal.f16	q13, d6, d7
.*:	fe0dc857 	vfmal.f16	q6, d13, d7\[0\]
.*:	fce6a857 	vfmsl.f16	q13, d6, d7
.*:	fe1dc87f 	vfmsl.f16	q6, d13, d7\[3\]
.*:	fc2f4850 	vfmal.f16	q2, d15, d0
.*:	fe42e850 	vfmal.f16	q15, d2, d0\[0\]
.*:	fcaf4850 	vfmsl.f16	q2, d15, d0
.*:	fe52e878 	vfmsl.f16	q15, d2, d0\[3\]
.*:	fc2f4857 	vfmal.f16	q2, d15, d7
.*:	fe42e857 	vfmal.f16	q15, d2, d7\[0\]
.*:	fcaf4857 	vfmsl.f16	q2, d15, d7
.*:	fe52e87f 	vfmsl.f16	q15, d2, d7\[3\]
.*:	fc2f6850 	vfmal.f16	q3, d15, d0
.*:	fe43e850 	vfmal.f16	q15, d3, d0\[0\]
.*:	fcaf6850 	vfmsl.f16	q3, d15, d0
.*:	fe53e878 	vfmsl.f16	q15, d3, d0\[3\]
.*:	fc2f6857 	vfmal.f16	q3, d15, d7
.*:	fe43e857 	vfmal.f16	q15, d3, d7\[0\]
.*:	fcaf6857 	vfmsl.f16	q3, d15, d7
.*:	fe53e87f 	vfmsl.f16	q15, d3, d7\[3\]
.*:	fc6fa850 	vfmal.f16	q13, d15, d0
.*:	fe4de850 	vfmal.f16	q15, d13, d0\[0\]
.*:	fcefa850 	vfmsl.f16	q13, d15, d0
.*:	fe5de878 	vfmsl.f16	q15, d13, d0\[3\]
.*:	fc6fa857 	vfmal.f16	q13, d15, d7
.*:	fe4de857 	vfmal.f16	q15, d13, d7\[0\]
.*:	fcefa857 	vfmsl.f16	q13, d15, d7
.*:	fe5de87f 	vfmsl.f16	q15, d13, d7\[3\]
