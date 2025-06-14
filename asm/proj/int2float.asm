// int2float.asm
// r1: lo byte from mem[0]
// r2: hi byte from mem[1]
// r3: sign bit
// r4: -1 or 0b1111_1111 (preloaded) from mem[4]
// r5: MSB when finding leading 1
// r6: shift count
// r7: 1 (preloaded) from mem[5]
// return lo byte to mem[2] and hi byte to mem[3]

// mem[0] = lo byte
// mem[1] = hi byte
// mem[2] = lo byte return
// mem[3] = hi byte return
// mem[4] = 0xFF
// mem[5] = 1
// mem[6] = 0x0F (15)
// mem[7] = 0x07


// load hi and lo bytes
lw 1 r2 // r2 = hi byte
lw 0 r1 // r1 = lo byte
lw 4 r4 // r4 = 0xFF
lw 5 r7 // r7 = 1

// r6 is scratch
br r1 check_r2  // if r1 == 0, continue to check r2
br r0 continue  // if r1 != 0, skip trap (unconditional branch)

check_r2:
br r2 trap     // if r2 == 0, both r1 and r2 are 0 => trap
br r0 continue  // else skip trap

trap:
sw 2 r1
sw 3 r2
done

continue:
// extract sign bits
shl r2 r3 // shift in MSB of r2 into r3. r3 = sign bit = hi byte[7]
nop

// negate bits if sign bit r3 == 1
br r3 norm // skip if r3 == 0
xor r4 r2 // r2 = ~r2
xor r4 r1 // r1 = ~r1
add r3 r1 // r1 = r1 + 1
nop
br r1 carry
br r0 norm
carry:
add r3 r2 // r2 = r2 + 1


// shift until r2[7] == 1
norm:
shl r2 r5 // r5 = r2[7]
nop
br r5 norm_next // if r5 is 0, we move on to the next step
br r0 exit // if r5 is 1, we fall through and exit the loop. This is an unconditional jump

norm_next: // 24
shl r1 r2 // r2 = {r2[6:0], r1[7]}
shl r0 r1 // r1 = {r1[6:0],0}
add r7 r6 // r6 = r6 + 1 [r6: shift count]
br r0 norm

exit:
// compute exp = bias + (7 - shift count)
lw 6 r5 // r5 = 15

// negate shift count
xor r4 r6 // r6 = ~r6
add r7 r6 // r6 = r6 + 1

lw 7 r4 // r4 = 7
add r4 r6 // r6 = r4 + r6
add r6 r5 // r5 = r6 + 15 [r5: exponent]

// shift again to skip implicit leading 1
shl r1 r2
shl r0 r1

// Big brain floating point building time
// shift sign bit 7 times
shl r0 r3
shl r0 r3
shl r0 r3
shl r0 r3
shl r0 r3
shl r0 r3
shl r0 r3

// shift exp 2 times
shl r0 r5
shl r0 r5

// shift right mantissa 6 times
shr r2 r1
shr r0 r2
shr r2 r1
shr r0 r2
shr r2 r1
shr r0 r2
shr r2 r1
shr r0 r2
shr r2 r1
shr r0 r2
shr r2 r1
shr r0 r2

// add everything
add r5 r2
add r3 r2

// return
sw 2 r1
sw 3 r2
nop
nop
nop
nop

done