/*

r3 ->  core_id
r4 -> tmp val
r5 -> tmp val
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
/// bank addr == core_id


12'h0, 4'h1
16'h7fff
16'h7fff
16'h0
16'h0
16'h0
16'h0
16'h0
8'h0,  8'h10
8'h20, 8'h30
8'h40, 8'h50
8'h60, 8'h70
8'h80, 8'h90
8'ha0, 8'hb0
8'hc0, 8'hd0
8'he0, 8'hf0


//// except for 1st core
`OPCODE_SET_CONST, 8'h0, `R3 

`OPCODE_SET_CONST, 8'h4, `R9

`OPCODE_SET_CONST, 8'h252, `R10
`OPCODE_SET_CONST, 8'h1,   `R12 

// `OPCODE_BNZ, `R8, 4'ha, 4'h0             // remember about target + 4'h0
    `OPCODE_ST, `R0, `R3, `R15    /// need to cut out first bits of R3
    `OPCODE_ADD, `R15, `R12, `R15    // addr ++
//    `OPCODE_ADD, `R11, `R11, `R12      // counter += 1   ////////////////////  counter === addr r11 = r15
    `OPCODE_SUB, `R3, `R15, `R4
    `OPCODE_BNZ, `R4, 4'h5, 4'h0    // addr = counter != id -> jmp back  /// target 

    `OPCODE_ST, `R0, `R3, `R15    /// need to cut out first bits of RE


    `OPCODE_ADD, `R0, `R9, `R0  // val += 4
    `OPCODE_ST, `R0, `R3, `R15    /// need to cut out first bits of RE
    `OPCODE_ADD, `R15, `R12, `R15    // addr ++

    `OPCODE_SUB, `R10, `R0, `R4  /// 255 - val
    `OPCODE_BNZ, `R4,  `R10, 4'h0            //// if 0 back    TARGET
    `OPCODE_NOP, 12'h0

    `OPCODE_READY, 12'h0  // extra
   
    
12'h0, 4'h1
16'h8000
16'h8000   // only 1st core
16'h0
16'h0
16'h0
16'h0
16'h0
16'h0
16'h0
16'h0
16'h0
16'h0
16'h0
16'h0
16'h0

    `OPCODE_SET_CONST, 8'h0, `R3 

    `OPCODE_SET_CONST, 8'h4, `R9

    `OPCODE_SET_CONST, 8'h252, `R10
    `OPCODE_SET_CONST, 8'h1,   `R12 

    `OPCODE_ST, `R0, `R3, `R15    /// need to cut out first bits of RE

    `OPCODE_ADD, `R0, `R9, `R0  // val += 4
    `OPCODE_ADD, `R15, `R12, `R15    // addr ++

    `OPCODE_SUB, `R10, `R0, `R4  /// 255 - val
    `OPCODE_BNZ, `R4,  `R10, 4'h0            //// if 0 back    TARGET
    `OPCODE_NOP, 12'h0
    `OPCODE_NOP, 12'h0
    `OPCODE_NOP, 12'h0
    `OPCODE_NOP, 12'h0
    `OPCODE_NOP, 12'h0

    `OPCODE_READY, 12'h0  // extra

/// each 4th line written






12'h0, 4'h1
16'hffff
16'hffff
16'h0
16'h0
16'h0
16'h0
16'h0
8'h4,  8'h14
8'h24, 8'h34
8'h44, 8'h54
8'h64, 8'h74
8'h84, 8'h94
8'ha4, 8'hb4
8'hc4, 8'hd4
8'he4, 8'hf4


    `OPCODE_ST, `R0, `R3, `R15    /// need to cut out first bits of R3
    `OPCODE_ADD, `R15, `R12, `R15    // addr ++
    
    `OPCODE_ADD, `R3, `R12, `R5    // some kind of +=1 to coreid to catch diagonal 
    `OPCODE_SUB, `R5, `R15, `R4   //
    `OPCODE_BNZ, `R4, 4'h5, 4'h0    // addr = counter != id -> jmp back  /// target 

    `OPCODE_ST, `R0, `R3, `R15    /// need to cut out first bits of RE


    `OPCODE_ADD, `R0, `R9, `R0  // val += 4
    `OPCODE_ST, `R0, `R3, `R15    /// need to cut out first bits of RE
    `OPCODE_ADD, `R15, `R12, `R15    // addr ++

    `OPCODE_SUB, `R10, `R0, `R4  /// 255 - val
    `OPCODE_BNZ, `R4,  `R10, 4'h0            //// if 0 back    TARGET
    `OPCODE_NOP, 12'h0
    `OPCODE_NOP, 12'h0
    `OPCODE_NOP, 12'h0
    `OPCODE_NOP, 12'h0

    `OPCODE_READY, 12'h0  // extra
   

//half done





12'h0, 4'h1
16'h7fff
16'h7fff
16'h0
16'h0
16'h0
16'h0
16'h0
8'h8,  8'h18
8'h28, 8'h38
8'h48, 8'h58
8'h68, 8'h78
8'h88, 8'h98
8'ha8, 8'hb8
8'hc8, 8'hd8
8'he8, 8'hf8
    


    `OPCODE_ST, `R0, `R3, `R15    /// need to cut out first bits of R3
    `OPCODE_ADD, `R15, `R12, `R15    // addr ++
    
    `OPCODE_ADD, `R3, `R12, `R5    // some kind of +=1 to coreid to catch diagonal 
    `OPCODE_ADD, `R3, `R12, `R5    // some kind of +=1 to coreid to catch diagonal 
    `OPCODE_SUB, `R5, `R15, `R4   //
    `OPCODE_BNZ, `R4, 4'h5, 4'h0    // addr = counter != id -> jmp back  /// target 

    `OPCODE_ST, `R0, `R3, `R15    /// need to cut out first bits of RE


    `OPCODE_ADD, `R0, `R9, `R0  // val += 4
    `OPCODE_ST, `R0, `R3, `R15    /// need to cut out first bits of RE
    `OPCODE_ADD, `R15, `R12, `R15    // addr ++

    `OPCODE_SUB, `R10, `R0, `R4  /// 255 - val
    `OPCODE_BNZ, `R4,  `R10, 4'h0            //// if 0 back    TARGET
    `OPCODE_NOP, 12'h0
    `OPCODE_NOP, 12'h0
    `OPCODE_NOP, 12'h0

    `OPCODE_READY, 12'h0  // extra

// 3/4 done 










12'h0, 4'h1
16'hffff
16'hffff
16'h0
16'h0
16'h0
16'h0
16'h0
8'hc,  8'h1c
8'h2c, 8'h3c
8'h4c, 8'h5c
8'h6c, 8'h7c
8'h8c, 8'h9c
8'hac, 8'hbc
8'hcc, 8'hdc
8'hec, 8'hfc


    `OPCODE_ST, `R0, `R3, `R15    /// need to cut out first bits of R3
    `OPCODE_ADD, `R15, `R12, `R15    // addr ++
    
    `OPCODE_ADD, `R3, `R12, `R5    // some kind of +=1 to coreid to catch diagonal 
    `OPCODE_SUB, `R5, `R15, `R4   //
    `OPCODE_BNZ, `R4, 4'h5, 4'h0    // addr = counter != id -> jmp back  /// target 

    `OPCODE_ST, `R0, `R3, `R15    /// need to cut out first bits of RE


    `OPCODE_ADD, `R0, `R9, `R0  // val += 4
    `OPCODE_ST, `R0, `R3, `R15    /// need to cut out first bits of RE
    `OPCODE_ADD, `R15, `R12, `R15    // addr ++

    `OPCODE_SUB, `R10, `R0, `R4  /// 255 - val
    `OPCODE_BNZ, `R4,  `R10, 4'h0            //// if 0 back    TARGET
    `OPCODE_NOP, 12'h0
    `OPCODE_NOP, 12'h0
    `OPCODE_NOP, 12'h0
    `OPCODE_NOP, 12'h0

    `OPCODE_READY, 12'h0  // extra
    /// except for final line 
    /// mb better final core separately




12'h0, 4'h1
16'h0001
16'h0001   // only 1st core
16'h0
16'h0
16'h0
16'h0
16'h0
16'h0
16'h0
16'h0
16'h0
16'h0
16'h0
16'h0
16'h0


    `OPCODE_SET_CONST, 8'h63, `R10
// R7 counter
    `OPCODE_ST, `R0, `R3, `R15    /// need to cut out first bits of RE
    `OPCODE_ADD, `R15, `R12, `R15    // addr ++
    `OPCODE_ADD, `R15, `R12, `R7    // counter ++
    `OPCODE_SUB, `R10, `R7, `R4  /// 255 - val

    `OPCODE_BNZ, `R4,  4'h2, 4'h0            //// if 0 back    TARGET
    `OPCODE_NOP, 12'h0
    `OPCODE_NOP, 12'h0
    `OPCODE_NOP, 12'h0
    `OPCODE_NOP, 12'h0
    `OPCODE_NOP, 12'h0
    `OPCODE_NOP, 12'h0
    `OPCODE_NOP, 12'h0
    `OPCODE_NOP, 12'h0
    `OPCODE_NOP, 12'h0

    `OPCODE_READY, 12'h0  // extra



