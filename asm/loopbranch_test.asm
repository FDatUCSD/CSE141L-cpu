init:
    add r0 r1         // r1 = r1 + 0, assume r1 initialized to 3 externally
loop:
    add r2 r2         // dummy op
    add r7 r1         // r1 = r1 - 1, assume r7 = -1
    nop
    br r1 end         // branch if r1 == 0 (i.e., exit loop)
    br r0 loop        // unconditional branch via r0 == 0
end:
    xor r3 r4         // reached only after loop ends
