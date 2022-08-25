; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mcpu=pwr7 -ppc-asm-full-reg-names -ppc-vsr-nums-as-vr \
; RUN:   -mtriple=powerpc64-unknown-unknown -verify-machineinstrs < %s | \
; RUN:   FileCheck %s --check-prefix=BE
; RUN: llc -mcpu=pwr8 -ppc-asm-full-reg-names -ppc-vsr-nums-as-vr \
; RUN:   -mtriple=powerpc64le-unknown-unknown -verify-machineinstrs < %s | \
; RUN:   FileCheck %s
; RUN: llc -mcpu=pwr8 -ppc-asm-full-reg-names -ppc-vsr-nums-as-vr \
; RUN:   -mtriple=powerpc64le-unknown-unknown -verify-machineinstrs < %s \
; RUN:   --enable-unsafe-fp-math | FileCheck %s --check-prefix=FAST
define dso_local i64 @test_lrint(double %d) local_unnamed_addr {
; BE-LABEL: test_lrint:
; BE:       # %bb.0: # %entry
; BE-NEXT:    mflr r0
; BE-NEXT:    std r0, 16(r1)
; BE-NEXT:    stdu r1, -112(r1)
; BE-NEXT:    .cfi_def_cfa_offset 112
; BE-NEXT:    .cfi_offset lr, 16
; BE-NEXT:    bl lrint
; BE-NEXT:    nop
; BE-NEXT:    addi r1, r1, 112
; BE-NEXT:    ld r0, 16(r1)
; BE-NEXT:    mtlr r0
; BE-NEXT:    blr
;
; CHECK-LABEL: test_lrint:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mflr r0
; CHECK-NEXT:    std r0, 16(r1)
; CHECK-NEXT:    stdu r1, -32(r1)
; CHECK-NEXT:    .cfi_def_cfa_offset 32
; CHECK-NEXT:    .cfi_offset lr, 16
; CHECK-NEXT:    bl lrint
; CHECK-NEXT:    nop
; CHECK-NEXT:    addi r1, r1, 32
; CHECK-NEXT:    ld r0, 16(r1)
; CHECK-NEXT:    mtlr r0
; CHECK-NEXT:    blr
;
; FAST-LABEL: test_lrint:
; FAST:       # %bb.0: # %entry
; FAST-NEXT:    fctid f0, f1
; FAST-NEXT:    mffprd r3, f0
; FAST-NEXT:    blr
entry:
  %0 = tail call i64 @llvm.lrint.i64.f64(double %d)
  ret i64 %0
}

declare i64 @llvm.lrint.i64.f64(double)

define dso_local i64 @test_lrintf(float %f) local_unnamed_addr {
; BE-LABEL: test_lrintf:
; BE:       # %bb.0: # %entry
; BE-NEXT:    mflr r0
; BE-NEXT:    std r0, 16(r1)
; BE-NEXT:    stdu r1, -112(r1)
; BE-NEXT:    .cfi_def_cfa_offset 112
; BE-NEXT:    .cfi_offset lr, 16
; BE-NEXT:    bl lrintf
; BE-NEXT:    nop
; BE-NEXT:    addi r1, r1, 112
; BE-NEXT:    ld r0, 16(r1)
; BE-NEXT:    mtlr r0
; BE-NEXT:    blr
;
; CHECK-LABEL: test_lrintf:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mflr r0
; CHECK-NEXT:    std r0, 16(r1)
; CHECK-NEXT:    stdu r1, -32(r1)
; CHECK-NEXT:    .cfi_def_cfa_offset 32
; CHECK-NEXT:    .cfi_offset lr, 16
; CHECK-NEXT:    bl lrintf
; CHECK-NEXT:    nop
; CHECK-NEXT:    addi r1, r1, 32
; CHECK-NEXT:    ld r0, 16(r1)
; CHECK-NEXT:    mtlr r0
; CHECK-NEXT:    blr
;
; FAST-LABEL: test_lrintf:
; FAST:       # %bb.0: # %entry
; FAST-NEXT:    fctid f0, f1
; FAST-NEXT:    mffprd r3, f0
; FAST-NEXT:    blr
entry:
  %0 = tail call i64 @llvm.lrint.i64.f32(float %f)
  ret i64 %0
}

declare i64 @llvm.lrint.i64.f32(float)

define dso_local i64 @test_llrint(double %d) local_unnamed_addr {
; BE-LABEL: test_llrint:
; BE:       # %bb.0: # %entry
; BE-NEXT:    mflr r0
; BE-NEXT:    std r0, 16(r1)
; BE-NEXT:    stdu r1, -112(r1)
; BE-NEXT:    .cfi_def_cfa_offset 112
; BE-NEXT:    .cfi_offset lr, 16
; BE-NEXT:    bl llrint
; BE-NEXT:    nop
; BE-NEXT:    addi r1, r1, 112
; BE-NEXT:    ld r0, 16(r1)
; BE-NEXT:    mtlr r0
; BE-NEXT:    blr
;
; CHECK-LABEL: test_llrint:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mflr r0
; CHECK-NEXT:    std r0, 16(r1)
; CHECK-NEXT:    stdu r1, -32(r1)
; CHECK-NEXT:    .cfi_def_cfa_offset 32
; CHECK-NEXT:    .cfi_offset lr, 16
; CHECK-NEXT:    bl llrint
; CHECK-NEXT:    nop
; CHECK-NEXT:    addi r1, r1, 32
; CHECK-NEXT:    ld r0, 16(r1)
; CHECK-NEXT:    mtlr r0
; CHECK-NEXT:    blr
;
; FAST-LABEL: test_llrint:
; FAST:       # %bb.0: # %entry
; FAST-NEXT:    fctid f0, f1
; FAST-NEXT:    mffprd r3, f0
; FAST-NEXT:    blr
entry:
  %0 = tail call i64 @llvm.llrint.i64.f64(double %d)
  ret i64 %0
}

declare i64 @llvm.llrint.i64.f64(double)

define dso_local i64 @test_llrintf(float %f) local_unnamed_addr {
; BE-LABEL: test_llrintf:
; BE:       # %bb.0: # %entry
; BE-NEXT:    mflr r0
; BE-NEXT:    std r0, 16(r1)
; BE-NEXT:    stdu r1, -112(r1)
; BE-NEXT:    .cfi_def_cfa_offset 112
; BE-NEXT:    .cfi_offset lr, 16
; BE-NEXT:    bl llrintf
; BE-NEXT:    nop
; BE-NEXT:    addi r1, r1, 112
; BE-NEXT:    ld r0, 16(r1)
; BE-NEXT:    mtlr r0
; BE-NEXT:    blr
;
; CHECK-LABEL: test_llrintf:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mflr r0
; CHECK-NEXT:    std r0, 16(r1)
; CHECK-NEXT:    stdu r1, -32(r1)
; CHECK-NEXT:    .cfi_def_cfa_offset 32
; CHECK-NEXT:    .cfi_offset lr, 16
; CHECK-NEXT:    bl llrintf
; CHECK-NEXT:    nop
; CHECK-NEXT:    addi r1, r1, 32
; CHECK-NEXT:    ld r0, 16(r1)
; CHECK-NEXT:    mtlr r0
; CHECK-NEXT:    blr
;
; FAST-LABEL: test_llrintf:
; FAST:       # %bb.0: # %entry
; FAST-NEXT:    fctid f0, f1
; FAST-NEXT:    mffprd r3, f0
; FAST-NEXT:    blr
entry:
  %0 = tail call i64 @llvm.llrint.i64.f32(float %f)
  ret i64 %0
}

declare i64 @llvm.llrint.i64.f32(float)

define dso_local i64 @test_lround(double %d) local_unnamed_addr {
; BE-LABEL: test_lround:
; BE:       # %bb.0: # %entry
; BE-NEXT:    mflr r0
; BE-NEXT:    std r0, 16(r1)
; BE-NEXT:    stdu r1, -112(r1)
; BE-NEXT:    .cfi_def_cfa_offset 112
; BE-NEXT:    .cfi_offset lr, 16
; BE-NEXT:    bl lround
; BE-NEXT:    nop
; BE-NEXT:    addi r1, r1, 112
; BE-NEXT:    ld r0, 16(r1)
; BE-NEXT:    mtlr r0
; BE-NEXT:    blr
;
; CHECK-LABEL: test_lround:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mflr r0
; CHECK-NEXT:    std r0, 16(r1)
; CHECK-NEXT:    stdu r1, -32(r1)
; CHECK-NEXT:    .cfi_def_cfa_offset 32
; CHECK-NEXT:    .cfi_offset lr, 16
; CHECK-NEXT:    bl lround
; CHECK-NEXT:    nop
; CHECK-NEXT:    addi r1, r1, 32
; CHECK-NEXT:    ld r0, 16(r1)
; CHECK-NEXT:    mtlr r0
; CHECK-NEXT:    blr
;
; FAST-LABEL: test_lround:
; FAST:       # %bb.0: # %entry
; FAST-NEXT:    xsrdpi f0, f1
; FAST-NEXT:    fctid f0, f0
; FAST-NEXT:    mffprd r3, f0
; FAST-NEXT:    blr
entry:
  %0 = tail call i64 @llvm.lround.i64.f64(double %d)
  ret i64 %0
}

declare i64 @llvm.lround.i64.f64(double)

define dso_local i64 @test_lroundf(float %f) local_unnamed_addr {
; BE-LABEL: test_lroundf:
; BE:       # %bb.0: # %entry
; BE-NEXT:    mflr r0
; BE-NEXT:    std r0, 16(r1)
; BE-NEXT:    stdu r1, -112(r1)
; BE-NEXT:    .cfi_def_cfa_offset 112
; BE-NEXT:    .cfi_offset lr, 16
; BE-NEXT:    bl lroundf
; BE-NEXT:    nop
; BE-NEXT:    addi r1, r1, 112
; BE-NEXT:    ld r0, 16(r1)
; BE-NEXT:    mtlr r0
; BE-NEXT:    blr
;
; CHECK-LABEL: test_lroundf:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mflr r0
; CHECK-NEXT:    std r0, 16(r1)
; CHECK-NEXT:    stdu r1, -32(r1)
; CHECK-NEXT:    .cfi_def_cfa_offset 32
; CHECK-NEXT:    .cfi_offset lr, 16
; CHECK-NEXT:    bl lroundf
; CHECK-NEXT:    nop
; CHECK-NEXT:    addi r1, r1, 32
; CHECK-NEXT:    ld r0, 16(r1)
; CHECK-NEXT:    mtlr r0
; CHECK-NEXT:    blr
;
; FAST-LABEL: test_lroundf:
; FAST:       # %bb.0: # %entry
; FAST-NEXT:    xsrdpi f0, f1
; FAST-NEXT:    fctid f0, f0
; FAST-NEXT:    mffprd r3, f0
; FAST-NEXT:    blr
entry:
  %0 = tail call i64 @llvm.lround.i64.f32(float %f)
  ret i64 %0
}

declare i64 @llvm.lround.i64.f32(float)

define dso_local i64 @test_llround(double %d) local_unnamed_addr {
; BE-LABEL: test_llround:
; BE:       # %bb.0: # %entry
; BE-NEXT:    mflr r0
; BE-NEXT:    std r0, 16(r1)
; BE-NEXT:    stdu r1, -112(r1)
; BE-NEXT:    .cfi_def_cfa_offset 112
; BE-NEXT:    .cfi_offset lr, 16
; BE-NEXT:    bl llround
; BE-NEXT:    nop
; BE-NEXT:    addi r1, r1, 112
; BE-NEXT:    ld r0, 16(r1)
; BE-NEXT:    mtlr r0
; BE-NEXT:    blr
;
; CHECK-LABEL: test_llround:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mflr r0
; CHECK-NEXT:    std r0, 16(r1)
; CHECK-NEXT:    stdu r1, -32(r1)
; CHECK-NEXT:    .cfi_def_cfa_offset 32
; CHECK-NEXT:    .cfi_offset lr, 16
; CHECK-NEXT:    bl llround
; CHECK-NEXT:    nop
; CHECK-NEXT:    addi r1, r1, 32
; CHECK-NEXT:    ld r0, 16(r1)
; CHECK-NEXT:    mtlr r0
; CHECK-NEXT:    blr
;
; FAST-LABEL: test_llround:
; FAST:       # %bb.0: # %entry
; FAST-NEXT:    xsrdpi f0, f1
; FAST-NEXT:    fctid f0, f0
; FAST-NEXT:    mffprd r3, f0
; FAST-NEXT:    blr
entry:
  %0 = tail call i64 @llvm.llround.i64.f64(double %d)
  ret i64 %0
}

declare i64 @llvm.llround.i64.f64(double)

define dso_local i64 @test_llroundf(float %f) local_unnamed_addr {
; BE-LABEL: test_llroundf:
; BE:       # %bb.0: # %entry
; BE-NEXT:    mflr r0
; BE-NEXT:    std r0, 16(r1)
; BE-NEXT:    stdu r1, -112(r1)
; BE-NEXT:    .cfi_def_cfa_offset 112
; BE-NEXT:    .cfi_offset lr, 16
; BE-NEXT:    bl llroundf
; BE-NEXT:    nop
; BE-NEXT:    addi r1, r1, 112
; BE-NEXT:    ld r0, 16(r1)
; BE-NEXT:    mtlr r0
; BE-NEXT:    blr
;
; CHECK-LABEL: test_llroundf:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mflr r0
; CHECK-NEXT:    std r0, 16(r1)
; CHECK-NEXT:    stdu r1, -32(r1)
; CHECK-NEXT:    .cfi_def_cfa_offset 32
; CHECK-NEXT:    .cfi_offset lr, 16
; CHECK-NEXT:    bl llroundf
; CHECK-NEXT:    nop
; CHECK-NEXT:    addi r1, r1, 32
; CHECK-NEXT:    ld r0, 16(r1)
; CHECK-NEXT:    mtlr r0
; CHECK-NEXT:    blr
;
; FAST-LABEL: test_llroundf:
; FAST:       # %bb.0: # %entry
; FAST-NEXT:    xsrdpi f0, f1
; FAST-NEXT:    fctid f0, f0
; FAST-NEXT:    mffprd r3, f0
; FAST-NEXT:    blr
entry:
  %0 = tail call i64 @llvm.llround.i64.f32(float %f)
  ret i64 %0
}

declare i64 @llvm.llround.i64.f32(float)

define dso_local double @test_nearbyint(double %d) local_unnamed_addr {
; BE-LABEL: test_nearbyint:
; BE:    # %bb.0: # %entry
; BE:    bl nearbyint
; BE:    blr
;
; CHECK-LABEL: test_nearbyint:
; CHECK:    # %bb.0: # %entry
; CHECK:    bl nearbyint
; CHECK:    blr
;
; FAST-LABEL: test_nearbyint:
; FAST:       # %bb.0: # %entry
; FAST-NEXT:    xsrdpic f1, f1
; FAST-NEXT:    blr
entry:
  %0 = tail call double @llvm.nearbyint.f64(double %d)
  ret double %0
}

declare double @llvm.nearbyint.f64(double)

define dso_local float @test_nearbyintf(float %f) local_unnamed_addr {
; BE-LABEL: test_nearbyintf:
; BE:    # %bb.0: # %entry
; BE:    bl nearbyint
; BE:    blr
;
; CHECK-LABEL: test_nearbyintf:
; CHECK:    # %bb.0: # %entry
; CHECK:    bl nearbyintf
; CHECK:    blr
;
; FAST-LABEL: test_nearbyintf:
; FAST:       # %bb.0: # %entry
; FAST-NEXT:    xsrdpic f1, f1
; FAST-NEXT:    blr
entry:
  %0 = tail call float @llvm.nearbyint.f32(float %f)
  ret float %0
}

declare float @llvm.nearbyint.f32(float)

define dso_local double @test_round(double %d) local_unnamed_addr {
; BE-LABEL: test_round:
; BE:       # %bb.0: # %entry
; BE-NEXT:    xsrdpi f1, f1
; BE-NEXT:    blr
;
; CHECK-LABEL: test_round:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xsrdpi f1, f1
; CHECK-NEXT:    blr
;
; FAST-LABEL: test_round:
; FAST:       # %bb.0: # %entry
; FAST-NEXT:    xsrdpi f1, f1
; FAST-NEXT:    blr
entry:
  %0 = tail call double @llvm.round.f64(double %d)
  ret double %0
}

declare double @llvm.round.f64(double)

define dso_local float @test_roundf(float %f) local_unnamed_addr {
; BE-LABEL: test_roundf:
; BE:       # %bb.0: # %entry
; BE-NEXT:    xsrdpi f1, f1
; BE-NEXT:    blr
;
; CHECK-LABEL: test_roundf:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xsrdpi f1, f1
; CHECK-NEXT:    blr
;
; FAST-LABEL: test_roundf:
; FAST:       # %bb.0: # %entry
; FAST-NEXT:    xsrdpi f1, f1
; FAST-NEXT:    blr
entry:
  %0 = tail call float @llvm.round.f32(float %f)
  ret float %0
}

declare float @llvm.round.f32(float)

define dso_local double @test_trunc(double %d) local_unnamed_addr {
; BE-LABEL: test_trunc:
; BE:       # %bb.0: # %entry
; BE-NEXT:    xsrdpiz f1, f1
; BE-NEXT:    blr
;
; CHECK-LABEL: test_trunc:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xsrdpiz f1, f1
; CHECK-NEXT:    blr
;
; FAST-LABEL: test_trunc:
; FAST:       # %bb.0: # %entry
; FAST-NEXT:    xsrdpiz f1, f1
; FAST-NEXT:    blr
entry:
  %0 = tail call double @llvm.trunc.f64(double %d)
  ret double %0
}

declare double @llvm.trunc.f64(double)

define dso_local float @test_truncf(float %f) local_unnamed_addr {
; BE-LABEL: test_truncf:
; BE:       # %bb.0: # %entry
; BE-NEXT:    xsrdpiz f1, f1
; BE-NEXT:    blr
;
; CHECK-LABEL: test_truncf:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xsrdpiz f1, f1
; CHECK-NEXT:    blr
;
; FAST-LABEL: test_truncf:
; FAST:       # %bb.0: # %entry
; FAST-NEXT:    xsrdpiz f1, f1
; FAST-NEXT:    blr
entry:
  %0 = tail call float @llvm.trunc.f32(float %f)
  ret float %0
}

declare float @llvm.trunc.f32(float)

define dso_local double @test_floor(double %d) local_unnamed_addr {
; BE-LABEL: test_floor:
; BE:       # %bb.0: # %entry
; BE-NEXT:    xsrdpim f1, f1
; BE-NEXT:    blr
;
; CHECK-LABEL: test_floor:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xsrdpim f1, f1
; CHECK-NEXT:    blr
;
; FAST-LABEL: test_floor:
; FAST:       # %bb.0: # %entry
; FAST-NEXT:    xsrdpim f1, f1
; FAST-NEXT:    blr
entry:
  %0 = tail call double @llvm.floor.f64(double %d)
  ret double %0
}

declare double @llvm.floor.f64(double)

define dso_local float @test_floorf(float %f) local_unnamed_addr {
; BE-LABEL: test_floorf:
; BE:       # %bb.0: # %entry
; BE-NEXT:    xsrdpim f1, f1
; BE-NEXT:    blr
;
; CHECK-LABEL: test_floorf:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xsrdpim f1, f1
; CHECK-NEXT:    blr
;
; FAST-LABEL: test_floorf:
; FAST:       # %bb.0: # %entry
; FAST-NEXT:    xsrdpim f1, f1
; FAST-NEXT:    blr
entry:
  %0 = tail call float @llvm.floor.f32(float %f)
  ret float %0
}

declare float @llvm.floor.f32(float)

define dso_local double @test_ceil(double %d) local_unnamed_addr {
; BE-LABEL: test_ceil:
; BE:       # %bb.0: # %entry
; BE-NEXT:    xsrdpip f1, f1
; BE-NEXT:    blr
;
; CHECK-LABEL: test_ceil:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xsrdpip f1, f1
; CHECK-NEXT:    blr
;
; FAST-LABEL: test_ceil:
; FAST:       # %bb.0: # %entry
; FAST-NEXT:    xsrdpip f1, f1
; FAST-NEXT:    blr
entry:
  %0 = tail call double @llvm.ceil.f64(double %d)
  ret double %0
}

declare double @llvm.ceil.f64(double)

define dso_local float @test_ceilf(float %f) local_unnamed_addr {
; BE-LABEL: test_ceilf:
; BE:       # %bb.0: # %entry
; BE-NEXT:    xsrdpip f1, f1
; BE-NEXT:    blr
;
; CHECK-LABEL: test_ceilf:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xsrdpip f1, f1
; CHECK-NEXT:    blr
;
; FAST-LABEL: test_ceilf:
; FAST:       # %bb.0: # %entry
; FAST-NEXT:    xsrdpip f1, f1
; FAST-NEXT:    blr
entry:
  %0 = tail call float @llvm.ceil.f32(float %f)
  ret float %0
}

declare float @llvm.ceil.f32(float)
