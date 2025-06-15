    lw 0 r1        // Load memory[0] → r1 (simulate delay to write back)
    br r1 skip     // Branch if r1 == 0 (data hazard: should stall if lw hasn't written back yet)
    add r2 r2      // This should be skipped if branch is taken
skip:
    add r3 r3      // Some instruction after branch
    done