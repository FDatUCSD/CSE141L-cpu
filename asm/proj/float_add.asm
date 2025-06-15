// float_add.asm


// mem[8] = lo input
// mem[9] = hi input
// mem[10] = lo input
// mem[11] = hi input
// mem[12] = lo output
// mem[13] = hi output
// mem[14] = 0xFF


xor r7 r0 // page up
// lw 0 r1 X
lw 1 r2 X
// lw 2 r3 Y
lw 3 r4 Y

// extract sign and exponent
shl r2 r5
shl r4 r5

// extract exponent
shl r2 r0     // X
shr r2 r0     // 000 eeeee
shr r2 r0
shr r2 r0

shl r4 r0     // Y
shr r4 r0
shr r4 r0
shr r4 r0

// exp X - Y
lw 7 r6
xor r6 r4 // r4 = ~4
shl r6 r7 // r7 = 1
add r7 r4
add r2 r4 // exp(X) - exp(Y). r4 = difference between exp

nop
br r4 skip_align // same mantissa
shr r0 r7
shl r4 r7 // shift sign bit into r7
br r7 X_smaller// exp Y is bigger

// r1, r2 X
// r3, r4 Y
// r5 signs
// r6 -1
// r7?

lw 2 r1 // lo Y
lw 3 r1 // hi Y


//exp Y is smaller, fall through
Y_smaller:
br r4 skip_align




