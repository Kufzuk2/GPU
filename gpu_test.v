
`include "pseudo_asm.v"
`timescale 1ns/100ps

module gpu_test;

    reg reset;
    reg [DATA_DEPTH - 1: 0][15: 0] data_frames_in;
    wire               frame_being_sent;

    integer i; 
    integer k; 
    integer file;
    integer status;

    reg [15:0]              instruction;     
    reg                    prog_loading;
    reg [15: 0]                 tm_line;


/// for outfiles
	reg [8 * 29: 1] output_file;
	reg [     3: 0]    bank_num;
	reg [     1: 0]        flag;

	integer h, out_dsp;
/// for outfiles

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


    gpu gpu (
             .clk             (             clk),
             .reset           (           reset),
             .prog_loading    (    prog_loading),
             .data_frames_in  (  data_frames_in)
    );


    initial begin
        clk          <= 0;
        reset        <= 1;
        prog_loading <= 1;


    for (k = 0; k < 1024; k = k + 1) begin 
        case (k) 

        ///control frame. waiting for 1 IF
        ///    all r0 initialized
        //
        0: tm_line = {12'h0, 4'h1};                                                                                                                                                                                                                  
        1: tm_line = {16'hfffe};                                                                                                                                                                                                                     
        2: tm_line = {16'hfffe};                                                                                                                                                                                                                     
        3: tm_line = {16'h0};                                                                                                                                                                                                                        
        4: tm_line = {16'h0};                                                                                                                                                                                                                        
        5: tm_line = {16'h0};                                                                                                                                                                                                                        
        6: tm_line = {16'h0};                                                                                                                                                                                                                        
        7: tm_line = {16'h0};                                                                                                                                                                                                                        
        8: tm_line = {8'h0, 8'h10};                                                                                                                                                                                                                  
        9: tm_line = {8'h20, 8'h30};                                                                                                                                                                                                                 
        10: tm_line = {8'h40, 8'h50};                                                                                                                                                                                                               
        11: tm_line = {8'h60, 8'h70};                                                                                                                                                                                                               
        12: tm_line = {8'h80, 8'h90};                                                                                                                                                                                                               
        13: tm_line = {8'ha0, 8'hb0};                                                                                                                                                                                                               
        14: tm_line = {8'hc0, 8'hd0};                                                                                                                                                                                                               
        15: tm_line = {8'he0, 8'hf0};   
                                                                                                                                                                                                                    
        /// must be used 15 cores except for 1s core
        /// store bank_id, addr_in_bank, what to store
        /// R15  -  current address
        //
        16: tm_line = {`OPCODE_SET_CONST, 8'h0, `R3};  // R3 = core_id                                                                                                                                                                                             
        17: tm_line = {`OPCODE_SET_CONST, 8'h4, `R9};                                                                                                                                                                                               
        18: tm_line = {`OPCODE_SET_CONST, 8'd252, `R10};                                                                                                                                                                                            
        19: tm_line = {`OPCODE_SET_CONST, 8'h1,   `R12};                                                                                                                                                                                            
        // tm_line = {21, `OPCODE_BNZ, `R8, 4'ha, 4'h0}; // remember about target + 4'h0                                                                                                                                                             
        20: tm_line = {`OPCODE_ST, `R3, `R15, `R0}; // need to cut out first bits of R3                                                                                                                                                             
        
        21: tm_line = {`OPCODE_ADD, `R15, `R12, `R15}; // addr ++                                                                                                                                                                                   
        //!!!!!!!!!!!!!!!!!!!!!i
        //
        // tm_line = {24, `OPCODE_ADD, `R11, `R11, `R12}; // counter += 1; // counter === addr r11 = r15                                                                                                                                             
        22: tm_line = {`OPCODE_MUL, `R3, `R9, `R6};
        23: tm_line = {`OPCODE_SUB, `R6, `R15, `R4};                                                                                                                                                                                                  
        24: tm_line = {`OPCODE_BNZ, `R4, 4'h4, 4'h0}; // addr = counter != id -> jmp back; // target                                                                                                                                                 
        25: tm_line = {`OPCODE_ST, `R3, `R15, `R0}; // to write core_id * 4 + 1 cell
        //
        26: tm_line = {`OPCODE_ADD, `R15, `R12, `R15}; // addr ++                                                                                                                                                                                   
        27: tm_line = {`OPCODE_ADD, `R0, `R9, `R0}; // val += 4                                                                                                                                                                                     
        28: tm_line = {`OPCODE_ST, `R3, `R15, `R0}; // need to cut out first bits of RE                                                                                                                                                             
        29: tm_line = {`OPCODE_ADD, `R15, `R12, `R15}; // addr ++                                                                                                                                                                                   
        30: tm_line = {`OPCODE_SUB, `R10, `R0, `R4}; // 255 - val                                                                                                                                                                                   
        31: tm_line = {`OPCODE_BNZ, `R4, 4'hB, 4'h0}; // if 0 back; // TARGET                                                                                                                                                                       
        //31: tm_line = {`OPCODE_READY, 12'h0}; // extra                                                                                                                                                                                              



        32: tm_line = {12'h0, 4'h1};                                                                                                                                                                                                                 
        33: tm_line = {16'h0001};                                                                                                                                                                                                                   
        34: tm_line = {16'h0001}; // only 1st core                                                                                                                                                                                                 
        35: tm_line = {16'h0};                                                                                                                                                                                                                       
        36: tm_line = {16'h0};                                                                                                                                                                                                                       
        37: tm_line = {16'h0};                                                                                                                                                                                                                       
        38: tm_line = {16'h0};                                                                                                                                                                                                                       
        39: tm_line = {16'h0};                                                                                                                                                                                                                       
        40: tm_line = {16'h0};                                                                                                                                                                                                                       
        41: tm_line = {16'h0};                                                                                                                                                                                                                       
        42: tm_line = {16'h0};                                                                                                                                                                                                                       
        43: tm_line = {16'h0};                                                                                                                                                                                                                       
        44: tm_line = {16'h0};                       
        45: tm_line = {16'h0};
        46: tm_line = {16'h0};
        47: tm_line = {16'h0};

/// separately 1st core
        48: tm_line = {`OPCODE_SET_CONST, 8'h0, `R3};
        49: tm_line = {`OPCODE_SET_CONST, 8'h4, `R9};
        50: tm_line = {`OPCODE_SET_CONST, 8'd252, `R10};
        51: tm_line = {`OPCODE_SET_CONST, 8'h1, `R12};
        52: tm_line = {`OPCODE_ST, `R3, `R15, `R0}; // need to cut out first bits of RE
        53: tm_line = {`OPCODE_ADD, `R0, `R9, `R0}; // val += 4
        54: tm_line = {`OPCODE_ADD, `R15, `R12, `R15}; // addr ++
        55: tm_line = {`OPCODE_SUB, `R10, `R0, `R4}; // 255 - val
        56: tm_line = {`OPCODE_BNZ, `R4, 4'h4, 4'h0}; // if 0 back; // TARGET
        57: tm_line = {`OPCODE_ST, `R3, `R15, `R0}; // need to cut out first bits of RE
        58: tm_line = {`OPCODE_NOP, 12'h0};
        59: tm_line = {`OPCODE_NOP, 12'h0};
        60: tm_line = {`OPCODE_NOP, 12'h0};
        61: tm_line = {`OPCODE_NOP, 12'h0}; // дублированная инструкция
        62: tm_line = {`OPCODE_NOP, 12'h0}; // еще одна дублированная инструкция
        63: tm_line = {`OPCODE_READY, 12'h0}; // extra




        64: tm_line = {12'h0, 4'h1};
        65: tm_line = {16'hffff};
        66: tm_line = {16'hffff};
        67: tm_line = {16'h0};
        68: tm_line = {16'h0};
        69: tm_line = {16'h0};
        70: tm_line = {16'h0};
        71: tm_line = {16'h0};
        72: tm_line = {8'h4, 8'h14};
        73: tm_line = {8'h24, 8'h34};
        74: tm_line = {8'h44, 8'h54};
        75: tm_line = {8'h64, 8'h74};
        76: tm_line = {8'h84, 8'h94};
        77: tm_line = {8'ha4, 8'hb4};
        78: tm_line = {8'hc4, 8'hd4};
        79: tm_line = {8'he4, 8'hf4};


        /// 
        80: tm_line = {`OPCODE_ST, `R3, `R15, `R0}; 
        81: tm_line = {`OPCODE_ADD, `R15, `R12, `R15}; // addr ++
        82: tm_line = {`OPCODE_ADD, `R3, `R12, `R5}; // some kind of +=1 to coreid to catch diagonal
        83: tm_line = {`OPCODE_SUB, `R5, `R15, `R4}; //
        84: tm_line = {`OPCODE_BNZ, `R4, 4'h0, 4'h0}; // addr = counter != id -> jmp back; // target
        85: tm_line = {`OPCODE_ST, `R3, `R15, `R0}; 
        86: tm_line = {`OPCODE_ADD, `R0, `R9, `R0}; // val += 4
        87: tm_line = {`OPCODE_ST, `R3, `R15, `R0}; 
        88: tm_line = {`OPCODE_ADD, `R15, `R12, `R15}; // addr ++
        89: tm_line = {`OPCODE_SUB, `R10, `R0, `R4}; // 255 - val
        90: tm_line = {`OPCODE_BNZ, `R4, 4'h6, 4'h0}; // if 0 back; // TARGET
        91: tm_line = {`OPCODE_NOP, 12'h0};
        92: tm_line = {`OPCODE_NOP, 12'h0};
        93: tm_line = {`OPCODE_NOP, 12'h0};
        94: tm_line = {`OPCODE_NOP, 12'h0};
        95: tm_line = {`OPCODE_READY, 12'h0}; // extra


        96: tm_line = {12'h0, 4'h1};
        97: tm_line = {16'hfffe};
        98: tm_line = {16'hfffe};
        99: tm_line = {16'h0};
        100: tm_line = {16'h0};
        101: tm_line = {16'h0};
        102: tm_line = {16'h0};
        103: tm_line = {16'h0};
        104: tm_line = {8'h8, 8'h18};
        105: tm_line = {8'h28, 8'h38};
        106: tm_line = {8'h48, 8'h58};
        107: tm_line = {8'h68, 8'h78};
        108: tm_line = {8'h88, 8'h98};
        109: tm_line = {8'ha8, 8'hb8};
        110: tm_line = {8'hc8, 8'hd8};
        111: tm_line = {8'he8, 8'hf8};

        112: tm_line = {`OPCODE_ST, `R3, `R15, `R0}; 
        113: tm_line = {`OPCODE_ADD, `R15, `R12, `R15}; // addr ++
        114: tm_line = {`OPCODE_ADD, `R3, `R12, `R5}; // some kind of +=1 to coreid to catch diagonal
        115: tm_line = {`OPCODE_ADD, `R3, `R12, `R5}; // some kind of +=1 to coreid to catch diagonal
        116: tm_line = {`OPCODE_SUB, `R5, `R15, `R4}; //
        117: tm_line = {`OPCODE_BNZ, `R4, 4'h0, 4'h0}; // addr = counter != id -> jmp back; // target
        118: tm_line = {`OPCODE_ST, `R3, `R15, `R0}; 
        119: tm_line = {`OPCODE_ADD, `R0, `R9, `R0}; // val += 4
        120: tm_line = {`OPCODE_ST, `R3, `R15, `R0}; 
        121: tm_line = {`OPCODE_ADD, `R15, `R12, `R15}; // addr ++
        122: tm_line = {`OPCODE_SUB, `R10, `R0, `R4}; // 255 - val
        123: tm_line = {`OPCODE_BNZ, `R4, 4'h7, 4'h0}; // if 0 back; // TARGET
        124: tm_line = {`OPCODE_NOP, 12'h0};
        125: tm_line = {`OPCODE_NOP, 12'h0};
        126: tm_line = {`OPCODE_NOP, 12'h0};
        127: tm_line = {`OPCODE_READY, 12'h0}; // extra


        128: tm_line = {12'h0, 4'h1};
        129: tm_line = {16'hffff};
        130: tm_line = {16'hffff};
        131: tm_line = {16'h0};
        132: tm_line = {16'h0};
        133: tm_line = {16'h0};
        134: tm_line = {16'h0};
        135: tm_line = {16'h0};
        136: tm_line = {8'hc, 8'h1c};
        137: tm_line = {8'h2c, 8'h3c};
        138: tm_line = {8'h4c, 8'h5c};
        139: tm_line = {8'h6c, 8'h7c};
        140: tm_line = {8'h8c, 8'h9c};
        141: tm_line = {8'hac, 8'hbc};
        142: tm_line = {8'hcc, 8'hdc};
        143: tm_line = {8'hec, 8'hfc};


        144: tm_line = {`OPCODE_ST, `R3, `R15, `R0}; 
        145: tm_line = {`OPCODE_ADD, `R15, `R12, `R15}; // addr ++
        146: tm_line = {`OPCODE_ADD, `R3, `R12, `R5}; // some kind of +=1 to coreid to catch diagonal
        147: tm_line = {`OPCODE_SUB, `R5, `R15, `R4}; //
        148: tm_line = {`OPCODE_BNZ, `R4, 4'h0, 4'h0}; // addr = counter != id -> jmp back; // target
        149: tm_line = {`OPCODE_ST, `R3, `R15, `R0}; 
        150: tm_line = {`OPCODE_ADD, `R0, `R9, `R0}; // val += 4
        151: tm_line = {`OPCODE_ST, `R3, `R15, `R0}; 
        152: tm_line = {`OPCODE_ADD, `R15, `R12, `R15}; // addr ++
        153: tm_line = {`OPCODE_SUB, `R10, `R0, `R4}; // 255 - val
        154: tm_line = {`OPCODE_BNZ, `R4, 4'h6, 4'h0}; // if 0 back; // TARGET
        155: tm_line = {`OPCODE_NOP, 12'h0};
        156: tm_line = {`OPCODE_NOP, 12'h0};
        157: tm_line = {`OPCODE_NOP, 12'h0};
        158: tm_line = {`OPCODE_NOP, 12'h0};
        159: tm_line = {`OPCODE_READY, 12'h0}; // extra


        160: tm_line = {12'h0, 4'h1};
        161: tm_line = {16'h8000}; 
        162: tm_line = {16'h8000};
        163: tm_line = {16'h0};
        164: tm_line = {16'h0};
        165: tm_line = {16'h0};
        166: tm_line = {16'h0};
        167: tm_line = {16'h0};
        168: tm_line = {16'h0};
        169: tm_line = {16'h0};
        170: tm_line = {16'h0};
        171: tm_line = {16'h0};
        172: tm_line = {16'h0};
        173: tm_line = {16'h0};
        174: tm_line = {16'h0};
        175: tm_line = {16'h0};


        176: tm_line = {`OPCODE_SET_CONST, 8'h3f, `R10}; // R7 counter
        177: tm_line = {`OPCODE_ST, `R3, `R15, `R0}; 
        178: tm_line = {`OPCODE_ADD, `R15, `R12, `R15}; // addr ++
        179: tm_line = {`OPCODE_ADD, `R15, `R12, `R7}; // counter ++
        180: tm_line = {`OPCODE_SUB, `R10, `R7, `R4}; // 255 - val
        181: tm_line = {`OPCODE_BNZ, `R4, 4'h1, 4'h0}; // if 0 back; TARGET
        182: tm_line = {`OPCODE_NOP, 12'h0};
        183: tm_line = {`OPCODE_NOP, 12'h0};
        184: tm_line = {`OPCODE_NOP, 12'h0};
        185: tm_line = {`OPCODE_NOP, 12'h0};
        186: tm_line = {`OPCODE_NOP, 12'h0};
        187: tm_line = {`OPCODE_NOP, 12'h0};
        188: tm_line = {`OPCODE_NOP, 12'h0};
        189: tm_line = {`OPCODE_NOP, 12'h0};
        190: tm_line = {`OPCODE_NOP, 12'h0};
        191: tm_line = {`OPCODE_READY, 12'h0}; // extra


       //     default: {16'h0}; // Обработка остальных случаев (опционально, можно оставить пустым)
        endcase
        send_tm_line(tm_line, k);
    end
    end

/*
    initial begin

		flag     =   2'b0;
		bank_num = bank_n;

		for (k = 0; k < 16; k = k + 1) begin
			if(k[3 : 0] == bank_n) begin
				if(k[3:0] < 10)
					output_file = {"out_data/bank_", "0" + k[7:0]        , ".txt"};
				else
					output_file = {"out_data/bank_", "a" + k[7:0] - 8'd10, ".txt"};
				
				k = 16;
			end
		end

        while(flag < 2'b01)  begin
            k = 0;
            out_dsp = $fopen(output_file);
        end

		for(k = 0; k < 256; k = k + 1) begin
			if((k[7:0] + 1) % 64)
				$fwrite(out_dsp, " ");

			$fwrite(out_dsp, "%d %t\n", mem[k[7:0]], $time);
		end
		
		$fclose(out_dsp);
    end
*/

	initial begin 
		$dumpfile("dump.vcd"); $dumpvars(0, gpu_test);
        #10;
        reset = 0;
        #10;

        for (i = 191; i < 1024; i = i + 1) begin
            data_frames_in[i] = 0;
        end
        #20;
        prog_loading = 0;
        #190;
        #450;
        #450;
        #450;
        #450;
        #450;
        #450;
        #450;
        #450;
        #450;
        #450;
        #450;
        #450;


        #40500;
        reset = 1;
        #50;
        $finish;
	end

    




endmodule 


/*
            0: tm_line = {8'h0, 2'h0,2'h2}; // fence 0, if_num 2
            // i
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
            47: tm_line = {`OPCODE_READY, `R0, `R0, `R0};*/
