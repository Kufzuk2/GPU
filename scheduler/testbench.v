`include "../../pseudo_asm.v"
`timescale 1ns/100ps

module testbench;
    parameter  DATA_DEPTH = 1024;

    reg clk;
    reg reset;
    reg core_reading;
    reg [DATA_DEPTH - 1: 0][15: 0] data_frames_in;
    reg [15: 0]              core_ready;
    reg [15: 0]                 tm_line;
    reg                    prog_loading;
    wire               frame_being_sent;
    integer i; 
    integer k; 
    
    integer file;
    integer status;
    reg [15:0] instruction;     

    always 
        #1 clk = ~clk;
 


    task send_tm_line(input [15:0] instruction, input integer j);
        begin
            // Проверка на допустимый индекс
            if (j >= 0 && j <= 1023) begin
                $display ("before write: instruction: %h , number %d", instruction, j);
                data_frames_in[j] = instruction; // Запись инструкции в массив
                $display ("after writing     data_frames_in[%d] = %h ", j, data_frames_in[j]);
            end else begin
                $display("Ошибка: индекс вне диапазона!");
            end
        end
    endtask

    scheduler #(.DATA_DEPTH(1024), .R0_DATA_SIZE(128), .CTRL_DATA_SIZE(48), 
                .INSTR_SIZE(16),   .FRAME_SIZE(256),   .FRAME_NUM(64),
                .CORE_NUM(16),     .BUS_TO_CORE(16),   .R0_DEPTH(8))       scheduler
                        (
                         .clk             (             clk),
                         .reset           (           reset),
                         .core_ready      (      core_ready),
                         .core_reading    (    core_reading),
                         .prog_loading    (    prog_loading),
                         .data_frames_in  (  data_frames_in)

    );




    initial begin
        clk          <= 0;
        reset        <= 1;
        core_ready   <= 16'hffff;
        core_reading <= 1;
        prog_loading <= 1;


    for (k = 0; k < 48; k = k + 1) begin 
        case (k) 
            
            0: tm_line = {8'h0, 2'h0,2'h2}; // fence 0, if_num 2
            1: tm_line = {16'h0f0f}; // random mask
            2: tm_line = {16'h0f00}; // r0_ mask not needed yet
            3: tm_line = {16'h0}; // 
            4: tm_line = {16'h0}; // 
            5: tm_line = {16'h0}; // 
            6: tm_line = {16'h0}; // 
            7: tm_line = {16'h0}; // 
            8: tm_line = {16'h0}; // r0_data empty
            9: tm_line = {16'h0}; // r0_data empty
            10: tm_line = {16'h0}; // r0_data empty
            11: tm_line = {16'h0}; // r0_data empty
            12: tm_line = {16'h0}; // r0_data empty
            13: tm_line = {16'h0}; // r0_data empty
            14: tm_line = {16'h0}; // r0_data empty
            15: tm_line = {16'h0}; // r0_data empty
            

            16: tm_line = {`OPCODE_SET_CONST, 4'h0, 4'h0, `R0};
            17: tm_line = {`OPCODE_SET_CONST, 4'h0, 4'h0, `R1};
            18: tm_line = {`OPCODE_SET_CONST, 4'h0, 4'h0, `R2};
            19: tm_line = {`OPCODE_SET_CONST, 4'h0, 4'h0, `R3};
            20: tm_line = {`OPCODE_SET_CONST, 4'h0, 4'h0, `R4};
            21: tm_line = {`OPCODE_SET_CONST, 4'h0, 4'h0, `R5};
            22: tm_line = {`OPCODE_SET_CONST, 4'h0, 4'h0, `R6};
            23: tm_line = {`OPCODE_SET_CONST, 4'h0, 4'h0, `R7};
            24: tm_line = {`OPCODE_SET_CONST, 4'h0, 4'h0, `R8};
            25: tm_line = {`OPCODE_SET_CONST, 4'h0, 4'h0, `R9};
            26: tm_line = {`OPCODE_SET_CONST, 4'h0, 4'h0, `R10};
            27: tm_line = {`OPCODE_SET_CONST, 4'h0, 4'h0, `R11};
            28: tm_line = {`OPCODE_SET_CONST, 4'h0, 4'h0, `R12};
            29: tm_line = {`OPCODE_SET_CONST, 4'h0, 4'h0, `R13};
            30: tm_line = {`OPCODE_SET_CONST, 4'h0, 4'h0, `R14};
            31: tm_line = {`OPCODE_SET_CONST, 4'h0, 4'h0, `R15};

            32: tm_line = {`OPCODE_ADD, `R0, `R1, `R2};
            33: tm_line = {`OPCODE_ADD, `R0, `R1, `R8};
            34: tm_line = {`OPCODE_MUL, `R8, `R8, `R9};
            35: tm_line = {`OPCODE_DIV, `R9, `R2, `R12};
            36: tm_line = {`OPCODE_SUB, `R2, `R1, `R13};
            37: tm_line = {`OPCODE_CMPGE, `R9, `R2, `R15};
            38: tm_line = {`OPCODE_RSHFT, `R9, `R0, `R14};
            39: tm_line = {`OPCODE_LSHFT, `R9, `R0, `R14};
            40: tm_line = {`OPCODE_AND, `R0, `R2, `R7};
            41: tm_line = {`OPCODE_OR, `R0, `R2, `R7};
            42: tm_line = {`OPCODE_XOR, `R1, `R0, `R7};
            43: tm_line = {`OPCODE_LD, `R0, `R0, `R0};
            44: tm_line = {`OPCODE_ST, `R0, `R0, `R0};
            45: tm_line = {`OPCODE_SUB, `R0, `R3, `R0};
            46: tm_line = {`OPCODE_BNZ, `R0, `R13, `R13};
            47: tm_line = {`OPCODE_READY, `R0, `R0, `R0};

            // Второй фрейм - операции

        //    default: {16'h0}; // Обработка остальных случаев (опционально, можно оставить пустым)
        endcase
        send_tm_line(tm_line, k);
    end
    end

	initial begin 
		$dumpfile("dump.vcd"); $dumpvars(0, testbench);
        #10;
        reset = 0;
        #10;

        for (i = 48; i < 1024; i = i + 1) begin
            data_frames_in[i] = $random;
        end
        #20;
        prog_loading = 0;
        #190;
        #450;
        #450;
        $finish;
	end

    




endmodule 



