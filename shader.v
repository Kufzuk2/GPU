/*

r3 ->  core_id
r4 -> tmp val


r7 ->  start value of id * 4
r8 ->  flag: 0 if before diagonal

r9 -> == 4
R10 -> == 255
r11 -> counter
r12 ->  == 1
R13  -> TMP CALC
r14 -> bank_id       ==== addr[11: 8]
r15 -> addr_in_bank  ==== addr[ 7: 0]

*/




ifnum fence ????
ffff
ffff
0000
0000
0000
0000
0000
r0_data
r0_data
r0_data
r0_data
r0_data
r0_data
r0_data
r0_data

`OPCODE_SET_CONST, 8'h0, `R3 

`OPCODE_SET_CONST, 8'h4, `R9

`OPCODE_SET_CONST, 8'h255, `R10
`OPCODE_SET_CONST, 8'h1,   `R12 

`OPCODE_BNZ, `R8,              // remember about target + 4'h0
    `OPCODE_ST, `R7, `R14, `R15    /// need to cut out first bits of RE
    `OPCODE_ADD, `R15, `R12, `R15    // addr ++
    `OPCODE_ADD, `R11, `R11, `R12      // counter += 1
    `OPCODE_SUB, `R3, `R11, `R4
    `OPCODE_BNZ, `R4, 4'h5, 4'h0    // counter != id -> jmp back  /// target 

    `OPCODE_ST, `R7, `R14, `R15    /// need to cut out first bits of RE


    `OPCODE_ADD, `R7, `R9, `R7  // val += 4
    `OPCODE_ST, `R7, `R14, `R15    /// need to cut out first bits of RE
    `OPCODE_ADD, `R15, `R12, `R15    // addr ++

    `OPCODE_SUB, `R10, `R7, `R4  /// 255 - val
    `OPCODE_BNZ, `R4,              //// if 0 back    TARGET

    `OPCODE_READY, 12'h0  // extra
    //
    















