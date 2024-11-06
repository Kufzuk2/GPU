`timescale 1ns/100ps 
`define ins0  16'b0000000000000000
`define ins1  16'b0001000000000000
`define ins2  16'b0010000000000000
`define ins3  16'b0011000000000000
`define ins4  16'b0100000000000000
`define ins5  16'b0101000000000000
`define ins6  16'b0110000000000000
`define ins7  16'b0111000000000000
`define ins8  16'b1000000000000000
`define ins9  16'b1001000000000000
`define ins10 16'b1010000000000000
`define ins11 16'b1011000000000000
`define ins12 16'b1100000000000000
`define ins13 16'b1101000000000000
`define ins14 16'b1110000000000000
`define ins15 16'b1111000000000000


module Core_tb;


reg clk;
reg [3:0] core_id;
reg reset;
reg val_data;
reg val_ins;
reg val_mask_R0;
reg val_mask_ac;
reg val_R0;
reg [15:0]instruction;
wire [11:0]addr_shared_memory;
reg [7:0]mem_dat;
wire [7:0]mem_dat_st;
wire rtr;
wire mem_req_st;
wire mem_req_ld;
wire ready;



 always 
	 #0.5 clk = ~clk;

	gpu_core_1 core_tb (
		.clk(clk),
		.reset(reset),
		.core_id(core_id),
		.val_data(val_data),
		.val_mask_R0(val_mask_R0),
	    .val_mask_ac(val_mask_ac),
		.val_ins(val_ins),
		.val_R0(val_R0)	,
		.instruction(instruction),
		.addr_shared_memory(addr_shared_memory),
		.mem_dat(mem_dat),
		.mem_dat_st(mem_dat_st),
		.rtr(rtr),
		.mem_req_ld(mem_req_ld),
		.mem_req_st(mem_req_st),
		.ready(ready));
initial begin
	core_id <= 4;
	clk <= 1;
	reset <=1;
	#5
	reset <= 0;
	val_mask_ac<=1;
	instruction <=0;
	#1
	val_mask_ac<=0;
	#1
	val_mask_ac<=1;
	instruction <=16;
	#1
	val_mask_ac<=0;
	#1
	val_mask_R0<=1;
	instruction <=16;
	#1
	val_mask_R0<=0;
	val_R0<=1;
	instruction <= 16'b0000010000000000;
	#1
	instruction <=5;
	#1			   
	instruction <=6;
	#1				
	instruction <=7;
	#1				
	instruction <=8;
	#1				
	instruction <=9;
	#1				
	instruction <=1;
	#1				
	instruction <=2;
	#1
	val_R0<=0;
	val_ins <= 1;
	instruction <= `ins12|0;
	#1
	instruction <= `ins12|1;
	#1
	instruction <= `ins12|2;
	#1
	instruction <= `ins12|3;
	#1
	instruction <= `ins12|4;
	#1
	instruction <= `ins12|5;
	#1
	instruction <= `ins12|6;
	#1
	instruction <= `ins12|7;
	#1
	instruction <= `ins12|8;
	#1
	instruction <= `ins12|9;
	#1				
	instruction <= `ins12|10;
	#1
	instruction <= `ins12|11;
	#1
	instruction <= `ins12|12;
	#1
	instruction <= `ins12|13;
	#1
	instruction <= `ins12|14;
	#1
	instruction <= `ins12|15;
	#1
	val_ins <= 0;
	#100
	val_ins <= 1;
	instruction <= `ins1|12'b000000010010;
	#1
	instruction <= `ins1|12'b000000011000;
	#1
	instruction <= `ins3|12'b100010001001;
	#1
	instruction <= `ins4|12'b100100101100;
	#1
	instruction <= `ins2|12'b001000001101;
	#1
	instruction <= `ins5|12'b100100101111;
	#1
	instruction <= `ins6|12'b100100001110;
	#1
	instruction <= `ins7|12'b100100001110;
	#1
	instruction <= `ins8|12'b000000100111;
	#1
	instruction <= `ins9|12'b000000100111;
	#1
	instruction <= `ins10|12'b000100000111;
	#1				
	instruction <= `ins11|12'b000000000000;
	#1
	instruction <= `ins13|12'b000000000000;
	#1
	instruction <= `ins2|12'b000011110000;
	#1
	instruction <= `ins14|12'b000011011101;
	#1
	instruction <= `ins15|12'b000000000000;
	#1
	val_ins <= 0;
	#200
	val_data <= 1;
	mem_dat <=7;
	end


	

endmodule