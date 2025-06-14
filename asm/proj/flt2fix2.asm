// flt2fix2.asm

// mem[0] = 0xFF
// mem[1] = 0x16 = 22 for shift amount
// mem[2] = 0x00
// mem[3] = 0x04 for implicit 1
// mem[4] = lo input
// mem[5] = hi input
// mem[6] = lo output
// mem[7] = hi output

lw 4 r1 // r1 = lo byte
lw 5 r2 // r2 = hi byte
lw 0 r6 // r6 = 0b1111 1111
lw 2 r4 // r4

br r1 check_r2  // if r1 == 0, continue to check r2
br r0 continue  // if r1 != 0, skip trap (unconditional branch)

check_r2:
br r2 trap     // if r2 == 0, both r1 and r2 are 0 => trap
br r0 continue  // else skip trap

trap:
sw 6 r1
sw 7 r2
done

continue:
shl r2 r3 // shift sign bit into r3 // 48
lw 1 r5 // 22 for shift amt calculation

shl r1 r2 // get rid of sign bit
shl r0 r1

// extract exponent
shl r2 r4
shl r1 r2
shl r0 r1
shl r2 r4
shl r1 r2
shl r0 r1
shl r2 r4
shl r1 r2
shl r0 r1
shl r2 r4
shl r1 r2
shl r0 r1
shl r2 r4
shl r1 r2
shl r0 r1

// calculate shift amt
xor r6 r4 // r4 = ~r4
shl r6 r7 // r7 = 1
add r7 r4 // r4 = r4 + 1
nop
nop
nop
add r5 r4 // r4 = shift_amt = 22 + r4
xor r3 r0 // to trigger exception
xor r3 r0 // to trigger exception

shr r2 r1
shr r6 r2 // shift in implicit 1

// shift by shift amt
shift_mantissa:
br r4 shift_done
shr r2 r1
shr r0 r2
add r6 r4 // decrement r4
br r0 shift_mantissa

shift_done:
// negate if sign bit is 1
br r3 exit // skip if r3 == 0
xor r6 r2 // r2 = ~r2
xor r6 r1 // r1 = ~r1
add r3 r1 // r1 = r1 + 1
nop
br r1 carry
br r0 exit
carry:
add r3 r2 // r2 = r2 + 1

exit:
sw 6 r1
sw 7 r2
nop
nop
nop
done

exp_error0: // if sign bit is 0 and exp > 22 return 0x7FFF
sw 6 r6 // 0xFF
shr r0 r6 // 0x7F
sw 7 r6
nop
nop
nop
done

exp_error1: // if sign is 1 and exp > 22 return 0x8000
xor r3 r3 // clear r3
sw 6 r3 // 0x00
shr r6 r3 // 0x80
sw 7 r3
nop
nop
nop
done
