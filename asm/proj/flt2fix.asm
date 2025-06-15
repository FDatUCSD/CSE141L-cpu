// flt2fix.asm

// mem[0] = 0xFF
// mem[1] = 0xF9 = -7 = -15 + 8
// mem[2] = 0x7C for mask
// mem[3] = 0x04 for implicit 1
// mem[4] = lo input
// mem[5] = hi input
// mem[6] = lo output
// mem[7] = hi output

lw 4 r1 // r1 = lo byte
lw 5 r2 // r2 = hi byte
lw 0 r6 // r6 = 0b1111 1111
lw 2 r4 // r4 = mask

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

// extract exponent
and r2 r4
shr r0 r4
shr r0 r4

// mask other bits except mantissa in r2
shl r6 r5 // shift 1 twice into r5 to make 3
shl r6 r5
and r5 r2 // only last 2 bits will be left

// restore implicit 1
lw 3 r5
add r5 r2

// r5 = shift amount = exp - 15 + 8 (remove bias)
lw 1 r5 // r5 = -7
add r4 r5
br r4 shift_mantissa

shift_mantissa:
br r5 done_shift // skip if shift amount is 0
shl r2 r1
shl r0 r2
add r6 r5 // decrement shift_amt
br r0 shift_mantissa

done_shift:
br r3 trap
xor r6 r2 // r2 = ~r2
xor r6 r1 // r1 = ~r1
add r3 r1 // r1 = r1 + 1
br r1 carry
br r0 trap
carry:
add r3 r2 // r2 = r2 + 1

sw 6 r1
sw 7 r2
nop
nop
nop
done