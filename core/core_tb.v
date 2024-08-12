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
reg reset;
reg val_data;
reg val_ins;
reg [15:0]instruction;
wire [11:0]addr_shared_memory;
reg [7:0]mem_dat;
wire [7:0]mem_dat_st;
wire [3:0]core_id;
wire rtr;
wire mem_req;
wire ready;


 always 
        #0.5 clk = ~clk;

	gpu_core_1 core_tb (
		.clk(clk),
		.reset(reset),
		.val_data(val_data),
		.val_ins(val_ins),
		.instruction(instruction),
		.addr_shared_memory(addr_shared_memory),
		.mem_dat(mem_dat),
		.mem_dat_st(mem_dat_st),
		.core_id(core_id),
		.rtr(rtr),
		.mem_req(mem_req),
		.ready(ready));
initial begin
	clk <= 1;
	reset <=1;
	#5
	reset <= 0;
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
	instruction <= `ins2|12'b000000110000;
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