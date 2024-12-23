
module gpu_core_1(
	input wire clk,
	input wire reset,
	input wire val_ins,
	input wire val_mask_R0,
	input wire val_mask_ac,
	input wire val_R0,
	
	
	input wire val_data, // val data from memmory
	input wire[15:0] instruction, // ins_mem from TS
	output reg [11:0] addr_shared_memory, // addr to shared memory   /// clean
	input wire[7:0] mem_dat, // data from sm
	output reg [7:0] mem_dat_st, // data to sm  // clean
	input wire [3:0] core_id,
	
	output reg rtr, // Ready to recieve
	output reg mem_req_ld, // Memory request
	output reg mem_req_st, // Memory request
	output reg ready // READY signal to TS
	);
	parameter [3:0] RI = 0,F = 1, D = 2, E = 3, M = 4, M_W = 5, WB = 6, NA = 7;
	//reg [3:0] state = RI;
	reg [3:0] state;
	
	// Internal registers
	reg [7:0] RF [0:15]; // Register File
	reg [3:0] PC; // Instruction Pointer
	reg [3:0] PC_D; // clean
	reg [3:0] PC_E;
	reg [15:0] ins_mem [0:15]; // clean
	reg [15:0] IR_D; // clean
	reg [15:0] IR_E; // clean
	reg [15:0] IR_M; // clean
	reg [15:0] IR_WB;
	reg [7:0] A;
	reg [7:0] D_WB; // clean
	reg [7:0] data_to_store_E; // clean
	reg [7:0] data_to_store_M; // clean
	reg [7:0] B_E; // clean
	reg [7:0] B_M;  // clean
	reg [11:0] O_M; // clean
	reg [11:0] O_WB;
	
	
	reg br_tkn;
	reg [3:0] br_target;
	
	reg [4:0] i ;
	reg [4:0] counter_ri;

	integer c;
	//integer count = 0;
	//reg cos = 1;

    reg cos1; // cleaned
    always @(posedge clk) begin
        if (reset)
            cos1 <= 1;
        else
            cos1 <= (state == RI) ? 1 :
                    (state == D)  ? 0 :
                                  cos1;
    end

/*
    // state logic
    always @(posedge clk) begin
        if (reset)
            state <= RI;
        else
*/


    reg [7:0] RF_0;
    reg [7:0] RF_1;
    reg [7:0] RF_2;
    reg [7:0] RF_3;
    reg [7:0] RF_4;
    reg [7:0] RF_5;
    reg [7:0] RF_6;
    reg [7:0] RF_7;
    reg [7:0] RF_8;
    reg [7:0] RF_9;
    reg [7:0] RF_10;
    reg [7:0] RF_11;
    reg [7:0] RF_12;
    reg [7:0] RF_13;
    reg [7:0] RF_14;
    reg [7:0] RF_15;


    always @(posedge clk) 
        begin
          RF_0 <= RF[0];
          RF_1 <= RF[1];
          RF_2 <= RF[2];
          RF_3 <= RF[3];
          RF_4 <= RF[4];
          RF_5 <= RF[5];
          RF_6 <= RF[6];
          RF_7 <= RF[7];
          RF_8 <= RF[8];
          RF_9 <= RF[9];
          RF_10 <= RF[10];
          RF_11 <= RF[11];
          RF_12 <= RF[12];
          RF_13 <= RF[13];
          RF_14 <= RF[14];
          RF_15 <= RF[15];
        end

    always @(posedge clk) 
        begin
          if (reset) 
            begin
              for (c = 0; c < 16; c=c+1 )
                begin 
                  RF[c] <= 0;
                end
            end
        end

	always @(posedge clk) 
		begin
			if (reset) 
				begin
					i <= 0;
					counter_ri <=0;
					PC <= 0;
					ready <= 1;
					rtr <= 1;
					br_tkn <= 0;
					br_target <= 0;
					state <= RI;
				end
		end	
	
	always @(posedge clk) 
		begin
			if (!(reset)&&(state==RI)) 
				begin
					rtr <= 1;
					if ((val_mask_ac) && (!(instruction[core_id])))
						begin
							state <= NA;
						end	
					
					if ((val_mask_R0)&&(instruction[core_id]))
						begin
							RF[0] <= 1;
						end
					else RF[0] <= RF[0];		
					if (val_R0)
						begin
							if(RF[0] && (counter_ri == core_id))
								begin 
									RF[0] <= instruction[15:8];
								end
							if(RF[0] && (counter_ri == core_id-1))
								begin 
									RF[0] <= instruction[7:0];
								end	
							counter_ri = counter_ri+2;
						end
					if (val_ins) 
						begin
							ready <=0;
							counter_ri <= 16;
							ins_mem[i] <= instruction;
							i = i +1;
						end
					else ins_mem[i]<=ins_mem[i];
					
					if ((i == 16)&&(counter_ri == 16))
						begin 
							state <=F;
							i<=0;
							counter_ri <= 0;
							rtr <= 0;
						end
					
				end
		end
		
	always @(posedge clk)
		begin 
			if (!(reset)&&(state==F)) 
				begin
					if (br_tkn)
						begin
							PC <= br_target;
							br_tkn <= 0;
							IR_D <= ins_mem[br_target];
							PC_D <= br_target;
						end
					else
						if (cos1)
							begin 
								PC <= 0;
								PC_D <= PC;
								IR_D <= ins_mem[PC];
								
							end
						else
							begin 
								PC <= PC+1;
								PC_D <= PC+1;
								IR_D <= ins_mem[PC+1];
							end
					
					state <= D;	
				end
		end	
		
	always @(posedge clk)
		begin 
			if (!(reset)&&(state==D)) 
				begin
					IR_E <= IR_D;
					PC_E <= PC_D;
					if(IR_D[15:12]==13)
						begin
							data_to_store_E <= RF[IR_D[3:0]];
						end
					A <= RF[IR_D[11:8]];
					B_E <= RF[IR_D[7:4]]; 
					
					state <= E;	
				end
		end	
		
	always @(posedge clk)
		begin 
			if (!(reset)&&(state==E)) 
				begin
					case (IR_E[15:12])
						4'b0000: ; // nop
						4'b0001: O_M[7:0] <= A + B_E; // add
						4'b0010: O_M[7:0] <= A - B_E; // sub
						4'b0011: O_M[7:0] <= A * B_E; // mul
						4'b0100: O_M[7:0] <= A / B_E; // div
						4'b0101: O_M[7:0] <= A >= B_E; // cmpge
						4'b0110: O_M[7:0] <= A >> B_E[3:0]; // rshift
						4'b0111: O_M[7:0] <= A << B_E[3:0]; // lshift 
						4'b1000: O_M[7:0] <= A & B_E; // and
						4'b1001: O_M[7:0] <= A | B_E; // or
						4'b1010: O_M[7:0] <= A ^ B_E; // xor
						4'b1011: O_M      <= {A[3:0],B_E};  // addr for ld 
						4'b1100:  
							begin
								if (IR_E[3] == 0)
									begin
										O_M <= {4'h0,core_id[3:0]};
									end
								else
									begin  
										O_M <= {IR_E[11:8],IR_E[7:4]};
									end
							end
						4'b1101: O_M      <= {A[3:0],B_E};  //addr for st
						4'b1110:
							begin 
								if (A != 0)
									begin
										br_target<=IR_E[7:4];
										br_tkn <= 1;
									end
							end 
					endcase  
					
					B_M <= B_E;
					IR_M <= IR_E;
					data_to_store_M <= data_to_store_E;
					
					state <= M;
				end
		end	
	always @(posedge clk)
		begin
			if (reset)
				begin
				mem_dat_st<=0;
				addr_shared_memory<=0;
				mem_req_ld <= 0;
				mem_req_st <= 0;
				end
			if (!(reset)&&(state==M)) 
				begin
					if(IR_M[15:12]==11)
						begin
							mem_req_ld <= 1;
							addr_shared_memory <= O_M;
							state <= M_W;
						end
					if(IR_M[15:12]==13)
						begin
							mem_req_st <= 1;
							mem_dat_st <= data_to_store_M;
							
							addr_shared_memory <= O_M;
							state <= M_W;
						end	
					
					if(IR_M[15:12]!=11 && IR_M[15:12]!=13)
						begin
							IR_WB <= IR_M;
							O_WB[7:0] <= O_M;
							state <= WB;
						end
				end
		end	
	always @(posedge clk)
		begin 
			if (!(reset)&&(state==M_W)) 
				begin
					if((val_data)&&IR_M[15:12]==11)
						begin
							D_WB[7:0] <= mem_dat;
							O_WB[7:0] <= O_M;
							IR_WB <= IR_M;
							state <= WB;
							mem_req_ld <=0;
						end
					if((val_data)&&(IR_M[15:12]==13))
						begin
							IR_WB <= IR_M;
							state <= WB;
							mem_req_st <=0;
						end	
				end	
		end
	
	always @(posedge clk)
		begin 
			if (!(reset)&&(state==WB)) 
				begin
					if((IR_M[15:12]<11) || (IR_M[15:12]==12))
						begin
							RF[IR_WB[3:0]]<= O_WB;
							state <= F;
						end
					if(IR_M[15:12]==11)
						begin
							RF[IR_WB[3:0]]<= D_WB;
							state <= F;
						end
					
					if((IR_M[15:12]==13)||(IR_M[15:12]==14)||(IR_M[15:12]==0))
						begin
							state <= F;
						end
					if ((IR_E[15:12]==15)||(PC_E==15 && (IR_WB[15:12] != 14))) 
						begin
							ready <= 1;
							PC <= 0;
							state <= RI;
						end
				end
		end	
	always @(posedge clk)
		begin 
			if ((val_mask_ac)&&(instruction[core_id]))
				begin
					state <= RI;
				end
		end	
	
	
endmodule
