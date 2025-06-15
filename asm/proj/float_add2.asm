
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

// mem[0] = msb x
// mem[1] = exp X
// mem[2] = hi mantissa X
// mem[3] = lo mantissa x

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

// mem[4] = msb Y
// mem[5] = exp Y
// mem[6] = hi mantissa Y
// mem[7] = lo mantissa Y

// second part - calculate shift
// let's do expX - expY
// then check sign bit of X to see if it's positive
// if it is then that mean Y is smaller
// so he have to shift Y right, but first don't forget the implicit 1
// we shift right by the distance of expX and expY

// r6 = r6 - r7 (distance of exp)

sub r7 r6
sw 6 r3
br r6 skip_align

xor r7 r7 // clear r7
shl r6 r7 // get sign bit of r6

// shift in implicit 1 in mantissa of y
lw 6 r4 // r4 = -1
shr r2 r1
shr r4 r6

xor r6 r0
sw 6 r2
sw 7 r1
xor r7 r0

xor r3 r3                       // clear r3 gonna use this for which flag

br r7 Y_smaller                 // sign bit is zero which means Y is smaller

// logic for X_smaller

// right now r1 and r2 has bytes for Y, so swap them for X,
// is Y is smaller then this step is skipped so just use value of r1 and r2
// load X in r1 and r2

xor r6 r0
sw 6 r2
sw 7 r2
lw 3 r1
lw 2 r2

// since the distance is negative we have to get the absolute value

shr r2 r1                           // might as well do the shift immplicit 1 shift
shr r4 r6
sw 3 r1
sw 2 r2
xor r7 r0
xor r7 r0
sw 0 r7
xor r6 r0

xor r4 r4               // clear r4
sub r6 r4               // r4 = 0 - 6    (remember r6 = distance of exp)
xor r6 r6               // r6 = 0
add r4 r6               // r6 = -r6. Since the original r6 has a 1 in the sign bit, that means it's negative and we have to negate it

lw 6 r4

lw 6 r3                 // this will only not be zero if X is smaller and we shifted x so that mean r1 and r2 hold X

// logic for Y_smaller


Y_smaller:
br r6 skip_align
shr r2 r1
shr r0 r2
add r4 r6               // decrement r6
br r0 Y_smaller         // unconditional jump

// where do we save?? did we just shift X or Y?

skip_align:

// save answers using the flag
br r3 save_Y            // if you triggered this that means your r1 and r2 is Y
xor r6 r0               // if you reach here that means your r1 and r2 is X
sw 2 r2
sw 3 r1
xor r7 r0
br r0 done_saving

save_Y:
xor r6 r0
sw 6 r2
sw 7 r1
xor r7 r0
br r0 done_saving

done_saving:

// exponents are aligned now
// time to compare signs
// load everything

xor r6 r0
sw 3 r1         // r2, r1 = X       r4, r3 = Y
sw 2 r2
sw 6 r4
sw 7 r3
sw 0 r5
sw 4 r6
xor r7 r0


// r5 = x sign
// r6 = y sign

// do x - Y
sub r6 r5           // r5 = r5 - r6
br r5 same_sign
xor r6 r6           // clear r6
shl r5 r6           // r6 = 0 if x is bigger
br r6 x_bigger

// block for if y is bigger

sub r2 r4           // r4 = r4 - r2
sub r1 r3           // r3 = r3 - r1
// handle overflow??
xor r5 r0
xor r2 r2
xor r1 r1
xor r4 r2
xor r3 r1
nop
br r0 done_adding

same_sign:
add r4 r2
add r3 r1
// handle overflow
xor r5 r0
nop
br r0 done_adding

x_bigger:
sub r4 r2           // r2 = r2 - r4
sub r3 r1           // r1 = r1 - r3
// handle overflow
xor r5 r0
nop
done_adding:

// normalize
xor r6 r6
xor r2 r6
shr r0 r6
shr r0 r6
br r6 no_leading_one



nop
nop
nop
done