// float_add.asm


// mem[8] = lo input
// mem[9] = hi input
// mem[10] = lo input
// mem[11] = hi input
// mem[12] = lo output
// mem[13] = hi output
// mem[14] = 0xFF


xor r7 r0 // page up
lw 0 r1             // X lo
lw 1 r2             // X hi

// extract sign bit X
shl r2 r3           // r3 = msb of X
shl r0 r2

// extract exponent of X
shl r2 r6
shl r0 r2
shl r2 r6
shl r0 r2
shl r2 r6
shl r0 r2
shl r2 r6
shl r0 r2
shl r2 r6
shl r0 r2

shl r2 r2
shl r2 r2

// save results
xor r6 r0           // pg down
sw 0 r3
sw 1 r6
sw 2 r2
sw 3 r1
xor r7 r0 // pg up


lw 2 r1             // Y lo
lw 3 r2             // Y hi

// extract sign bit Y
shl r2 r5           // r5 = msb of Y
shl r0 r2

// extract exponent of Y
shl r2 r7
shl r0 r2
shl r2 r7
shl r0 r2
shl r2 r7
shl r0 r2
shl r2 r7
shl r0 r2
shl r2 r7
shl r0 r2

shl r2 r2
shl r2 r2

// r1 = lo byte, r2 = hi byte, r3 = X sign, r4 = ?, r5 = Y sign, r6 = exp x, r7 = exp y

// save results
xor r6 r0           // pg down
sw 4 r3
sw 5 r6
sw 6 r2
sw 7 r1
xor r7 r0           // pg up

// mem[0] = msb x
// mem[1] = exp X
// mem[2] = hi mantissa X
// mem[3] = lo mantissa x
// mem[4] = msb Y
// mem[5] = exp Y
// mem[6] = hi mantissa Y
// mem[7] = lo mantissa Y

// Calculate shift
// exp x - exp Y

sub r7 r6           // r6 = exp x - exp y
br r6 skip_align

xor r7 r7
shl r6 r7           // r7 = sign bit of exp distance

// Shift implicit 1
lw 6 r4             // r4 = -1

