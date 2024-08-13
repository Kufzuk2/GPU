`define OPCODE_NOP          0'h0   // No operation
`define OPCODE_ADD          0'h1   // RF[dst] <- RF[src_0] + RF[src_1]
`define OPCODE_SUB          0'h2   // RF[dst] <- RF[src_0] - RF[src_1]
`define OPCODE_MUL          0'h3   // {RF[dst+1], RF[dst]} <- RF[src_0] * RF[src_1]
`define OPCODE_DIV          0'h4   // RF[dst] <- RF[src_0] / RF[src_1]
`define OPCODE_CMPGE        0'h5   // RF[dst] <- RF[src_0] >= RF[src_1]
`define OPCODE_RSHFT        0'h6   // RF[dst] <- RF[src_0] >> src_1[2:0]
`define OPCODE_LSHFT        0'h7   // RF[dst] <- RF[src_0] << src_1[2:0]
`define OPCODE_AND          0'h8   // RF[dst] <- RF[src_0] & RF[src_1]
`define OPCODE_OR           0'h9   // RF[dst] <- RF[src_0] | RF[src_1]
`define OPCODE_XOR          0'hA   // RF[dst] <- RF[src_0] ^ RF[src_1]
`define OPCODE_LD           0'hB   // RF[dst] <- MEM[ADDR][11:0], ADDR[11:0] = {RF[src_1][3:0]; RF[src_0][7:0]}
`define OPCODE_LD_SYNC      0'hB   // аналогично операции ld, с аппаратной блокировкой
`define OPCODE_SET_CONST     0'hC   // Если(dst[3] = 0) RF[dst] <- {4'h0, core_id[3:0]} или RF[dst] <- {const_[7:4], const[3:0]}
`define OPCODE_ST            0'hD   // MEM[ADDR[11:0]] <- RF[src_2], ADDR[11:0]={RF[src_1][3:0]; RF[src_0][7:0]}
`define OPCODE_ST_SYNC       0'hD   // аналогично операции st, с аппаратной разблокировкой
`define OPCODE_BNZ           0'hE   // if(src0 != 0) IP ← target[3:0] * instr_size else IP ← IP + instr_size
`define OPCODE_READY         0'hF   // IP<-0; конец работы ядра (выдача сигнала READY в Task Scheduler)
