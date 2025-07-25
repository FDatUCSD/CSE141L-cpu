# CSE141L: Far Reduced Instruction Set Computer (FRISC)

## Introduction
The main aim of this instruction set is to just challenge myself with my understanding of the pipeline. That's why I decided to make a 5 stage pipelined machine.

Main characteristics of the machine:<br>
* An register/register machine
* Hazard detection with full forwarding support
* Page style memory access
* Built in exception handler

## Architectural Overview
5 Stages: Fetch, Decode, Execute, Memory and Writeback<br>
![RTL](res/RTL.png)

Fetch stage:<br>
The fetch stage is responsible for fetching the next program counter which then gets passed through the instruction memory that outputs our 9 bit instruction. My CPU features a fetch module that handles stalls, exceptions and branches. The instruction memory holds and spits out instruction when given an address PC. Unlike the fetch module this is not clocked.

Decode stage:<br>
This is the most complicated stage. The control block takes the instruction bits and spits out magical signals that tell all other components to do things and how to do them.
The register file holds values that our ALU can use to compute. The hazard detector reads in signals from other pipeline registers to see what register their writing back to and check if we're accessing that register. The hazard control MUX does the simple job of zeroing out the pipeline register essentially freezing the next stage. The exception detector detects if we're about to do something nasty and tells the PC to jump somewhere we can handle it. The branch page register is a little work around to the limited amount of branches we can do. Basically we can trigger a special instruction where you can increment or decrement the branch page register to traverse the instruction ROM. It's the classic ol' page + offset absolute jump technique. Also in the decode stage is the comparator used to decide whether to branch or not. This gives only 1 cycle that needs to be flushed before branching. Helping the comparator is the forwarding MUX that helps get the right data to compare to.

Execute stage:<br>
The ALU just computes values. The two forwarding MUXes help get the correct data from the correct place to avoid using stale data. 

Memory stage:<br>
The data memory is a 256x8 data register. Nothing special about it. Didn't touch it much. The data memory MUX helps forward the write data to write to the data memory. I didn't realize it at first but you can have the stage before you write a register when trying to store a word then everything gets jumbled up. Not fun. The page register help access more regions of memory. Also the same page + offset trick, where you have a special instruction to increment or decrement page.

Writeback stage:<br>
There's only the memToRegMux that decides what data should be written back that's all.

Special thanks to the pipeline registers for always doing their job.

## Machine Specifications
|Type       |   Format              |   Corresponding instruction   |
|:---------:|:----------------------|:------------------------------|
|R          |3 bit opcode, 3 bit source register, 3 bit destination register|sub, xor, shl, shr, add|
|I          |3 bit opcode, 3 bit immediate, 3 bit destination register|lw, sw|
|B          |3 bit opcode, 3 bit register| 3 bit immediate|


| Name | Type | Example                                | Notes                                                                                                                                                       |   |
|------|------|----------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------|---|
| sub  | R    | 000100110: r6 = r6 - r4                | All instruction follows this format                                                                                                                         |   |
| xor  | R    | 001100110: r6 = r6 ^ r4                | This is useful when trying to copy contents from a register to an empty register. Also helpful when negating bits. Also useful when checking for inequality. Because of how useless this  |   |
| shl  | R    | 010100110: r6 = {r6[6:0], r4[7]}       | Useful for shifting in bits for the lower bytes, or extracting MSB                                                                                          |   |
| shr  | R    | 011100110: same as above but backwards | useful when finding exponents because you can just shift them into place                                                                                    |   |
| add  | R    | 100100110: r6 = r6 + r4                | I didn't use the overflow flags maybe I should have                                                                                                         |   |
| lw   | I    | 101100110: r6 = mem[4]                 |                                                                                                                                                             |   |
| sw   | I    | 110100110: mem[4] = r6                 |                                                                                                                                                             |   |
| br   | B    | 111000001: PC = page*8 + 1 << 5        | Pages help give more range of motion                                                                                                                        |   |

## Programs
Program 1:<br>
```
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
```
Program 2:<br>
```
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
```
Program 3: **Doesn't work** <br>
```
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
```




