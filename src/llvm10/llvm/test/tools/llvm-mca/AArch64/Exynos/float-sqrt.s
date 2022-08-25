# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -march=aarch64 -mcpu=exynos-m3 -resource-pressure=false < %s | FileCheck %s -check-prefixes=ALL,M3
# RUN: llvm-mca -march=aarch64 -mcpu=exynos-m4 -resource-pressure=false < %s | FileCheck %s -check-prefixes=ALL,M4
# RUN: llvm-mca -march=aarch64 -mcpu=exynos-m5 -resource-pressure=false < %s | FileCheck %s -check-prefixes=ALL,M5

fsqrt	s31, s31

# Newton series for sqrtf().
frsqrte	s1, s0
fmul	s2, s1, s1
frsqrts	s2, s0, s2
fmul	s1, s1, s2
fmul	s2, s1, s1
frsqrts	s2, s0, s2
fmul	s2, s2, s0
fmul	s1, s1, s2
fcmp	s0, #0.0
fcsel	s0, s0, s1, eq

# ALL:      Iterations:        100
# ALL-NEXT: Instructions:      1100

# M3-NEXT:  Total Cycles:      3203
# M4-NEXT:  Total Cycles:      3103
# M5-NEXT:  Total Cycles:      2803

# ALL-NEXT: Total uOps:        1200

# ALL:      Dispatch Width:    6

# M3-NEXT:  uOps Per Cycle:    0.37
# M3-NEXT:  IPC:               0.34
# M3-NEXT:  Block RThroughput: 20.0

# M4-NEXT:  uOps Per Cycle:    0.39
# M4-NEXT:  IPC:               0.35
# M4-NEXT:  Block RThroughput: 2.3

# M5-NEXT:  uOps Per Cycle:    0.43
# M5-NEXT:  IPC:               0.39
# M5-NEXT:  Block RThroughput: 2.3

# ALL:      Instruction Info:
# ALL-NEXT: [1]: #uOps
# ALL-NEXT: [2]: Latency
# ALL-NEXT: [3]: RThroughput
# ALL-NEXT: [4]: MayLoad
# ALL-NEXT: [5]: MayStore
# ALL-NEXT: [6]: HasSideEffects (U)

# ALL:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:

# M3-NEXT:   1      18    19.00                       fsqrt	s31, s31
# M3-NEXT:   1      4     0.50                        frsqrte	s1, s0

# M4-NEXT:   1      8     1.75                        fsqrt	s31, s31
# M4-NEXT:   1      3     0.50                        frsqrte	s1, s0

# M5-NEXT:   1      8     1.25                        fsqrt	s31, s31
# M5-NEXT:   1      3     0.50                        frsqrte	s1, s0

# ALL-NEXT:  1      3     0.33                        fmul	s2, s1, s1
# ALL-NEXT:  1      4     0.33                        frsqrts	s2, s0, s2
# ALL-NEXT:  1      3     0.33                        fmul	s1, s1, s2
# ALL-NEXT:  1      3     0.33                        fmul	s2, s1, s1
# ALL-NEXT:  1      4     0.33                        frsqrts	s2, s0, s2
# ALL-NEXT:  1      3     0.33                        fmul	s2, s2, s0
# ALL-NEXT:  1      3     0.33                        fmul	s1, s1, s2
# ALL-NEXT:  1      2     1.00                        fcmp	s0, #0.0

# M3-NEXT:   2      5     1.00                        fcsel	s0, s0, s1, eq
# M4-NEXT:   2      5     1.00                        fcsel	s0, s0, s1, eq
# M5-NEXT:   2      2     1.00                        fcsel	s0, s0, s1, eq
