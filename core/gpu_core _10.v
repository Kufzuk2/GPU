module gpu_core_10(
	input wire clk,
	input wire reset,
	input wire val_ins,
	input wire val_data, // val data from memmory
	input wire[15:0] instruction, // ins_mem from TS
	output reg [11:0] addr_shared_memory, // addr to shared memory
	input wire[7:0] mem_dat, // data from sm
	output reg [7:0] mem_dat_st, // data to sm 
	output reg [3:0] core_id = 10,
	
	output reg rtr, // Ready to recieve
	output reg mem_req, // Memory request
	output reg ready // READY signal to TS
	);
	parameter [3:0] RI = 0,F = 1, D = 2, E = 3, M = 4, M_W = 5, WB = 6;
	reg [3:0] state = RI;
	
	// Internal registers
	reg [7:0] RF [0:15]; // Register File
	reg [3:0] PC; // Instruction Pointer
	reg [3:0] PC_D;
	reg [3:0] PC_E;
	reg [15:0] ins_mem [0:15];
	reg [15:0] IR_D;
	reg [15:0] IR_E;
	reg [15:0] IR_M;
	reg [15:0] IR_WB;
	reg [7:0] A;
	reg [7:0] D_WB;
	reg [7:0] data_to_store_E;
	reg [7:0] data_to_store_M;
	reg [7:0] B_E;
	reg [7:0] B_M; 
	reg [11:0] O_M;
	reg [11:0] O_WB;
	
	
	reg br_tkn;
	reg [3:0] br_target;
	
	integer i = 0;
	//integer count = 0;
	integer cos = 1;
	
	always @(posedge clk or posedge reset) 
		begin
			if (reset) 
				begin
					PC <= 0;
					ready <= 0;
					rtr <= 1;
					br_tkn <= 0;
					br_target <= 0;
					state <= RI;
				end 
			else 
				begin
					case(state)
						RI :
						begin 
							cos = 1;
						rtr <= 1;
						if (val_ins) 
							begin
								ready <=0;
								ins_mem[i] <= instruction;
								i = i +1;
								if (i == 16)
									begin 
										state <=F;
										i=0;
										rtr <= 0;
									end
							end
						end
						F: 
							begin
								
								
								
								if (br_tkn)
									begin
										PC <= br_target;
										br_tkn <= 0;
										IR_D <= ins_mem[br_target];
								        PC_D <= br_target;
									end
								else
									if (cos)
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
						
						D:
						begin
							cos <= 0;
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
						E: 
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
									4'b1011: O_M      <= {B_E[3:0],A};  // addr for ld 
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
									4'b1101: O_M      <= {B_E[3:0],A};  //addr for st
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
						M:	  
							begin 
								
								if(IR_M[15:12]==11)
									begin
										mem_req <= 1;
										addr_shared_memory <= O_M;
										state <= M_W;
									end
								if(IR_M[15:12]==13)
									begin
										mem_req <= 1;
										
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
						M_W:
							begin
								if(val_data) 
									begin
										if(IR_M[15:12]==11)
											begin
												D_WB[7:0] <= mem_dat;
												O_WB[7:0] <= O_M;
												IR_WB <= IR_M;
												state <= WB;
												mem_req <=0;
											end
										if(IR_M[15:12]==13)
											begin
												IR_WB <= IR_M;
												mem_dat_st <= data_to_store_M;
												state <= WB;
												mem_req <=0;
											end	
									end
							end
						
						WB:
						begin 
							//count = count + 1;
								if((IR_M[15:12]<11 || IR_M[15:12]==12) && IR_M[15:12]!=0)
									begin
										RF[IR_WB[3:0]]<= O_WB;
										state <= F;
									end
								if(IR_M[15:12]==0)
									begin
										state <= F;
									end
								if(IR_M[15:12]==14)
									begin
										state <= F;
									end
								if(IR_M[15:12]==11)
									begin
										RF[IR_WB[3:0]]<= D_WB;
										state <= F;
									end
								if(IR_M[15:12]==13)
									begin
										state <= F;
									end
								
								if(IR_E[15:12]==15)
									begin
										ready <= 1;
										PC <= 0;
										//count = 0;
										for(integer i = 0; i < 16; i = i + 1) 
											begin	
												ins_mem[i] <= 0;
											end
										state <= RI;	
									end
								
								if (PC_E==15 && (IR_WB[15:12] != 14)) 
									begin
										ready <= 1;
										PC <= 0;
										//count = 0;
										for(integer c = 0; c < 16; c = c + 1) 
											begin	
												ins_mem[c] <= 0;
											end
										state <= RI;
									end // READY
							end
						
					endcase
					
				end
		end
	
endmodule