`include "scheduler/scheduler.v"
`include "shared_memory/shared_memory.v"
`include "core/gpu_core.v"



module gpu(
	input wire clk,
 	input wire reset,

	input  wire prog_loading,
	input  wire [1024  - 1: 0][15: 0] data_frames_in
);

wire [15 : 0] gpu_core_ready;
wire [15 : 0] read;
wire [15 : 0] write;
wire [15 : 0] finish;

wire [191:0] addr_in;
wire [127:0] data_in;
wire [127:0] data_out;

wire [15:0] gpu_core_reading;
wire        final_core_reading;
wire        instruction;
wire [ 3:0] masks;


genvar i;

generate
	for(i = 0; i < 16; i = i + 1) begin: gen_cores
		gpu_core gpu_core_i ( .clk(clk), .reset(reset), .val_ins(masks[0]), .val_mask_R0(masks[1]), .val_mask_ac(masks[2]), 
		.val_R0(masks[3]), .val_data(finish[8 * i[3:0]]), .instruction(instruction), .addr_shared_memory(addr_in[11 + 12 * i[3:0] : 12 * i[3:0]]),
		.mem_dat(data_out[7 + 8 * i[3:0] : 8 * i[3:0]]), .mem_dat_st(data_in[7 + 8 * i[3:0] : 8 * i[3:0]]),
		.core_id(i[3:0]), .rtr(gpu_core_reading[i[3:0]]), .mem_req_ld(read[i[3:0]]), .mem_req_st(write[i[3:0]]), .ready(gpu_core_ready[i[3:0]]));
	end
endgenerate

generate
	for(i = 0; i < 16; i = i + 1) begin: gen_bank_arbiters
	bank_arbiter arbiter_i ( .clock(clk), .reset(reset), .read(read), .write(write),
 	.bank_n(i[3:0]), .addr_in(addr_in), .data_in(data_in), .data_out(data_out), .finish(finish));
	end
endgenerate

assign final_core_reading = gpu_core_reading[ 0] & gpu_core_reading[ 1] & gpu_core_reading[ 2] & gpu_core_reading[ 3] & gpu_core_reading[ 4] & 
			    gpu_core_reading[ 5] & gpu_core_reading[6 ] & gpu_core_reading[ 7] & gpu_core_reading[ 8] & gpu_core_reading[ 9] & 
			    gpu_core_reading[10] & gpu_core_reading[11] & gpu_core_reading[12] & gpu_core_reading[13] & gpu_core_reading[14] & 
			    gpu_core_reading[15];

 

scheduler gpu_scheduler ( .clk(clk), .reset(reset), .val_ins(masks[0]), .val_mask_R0(masks[1]), .val_mask_ac(masks[2]),
	.val_R0(masks[3]), .core_reading(final_core_reading), .prog_loading(prog_loading),
 .frame_being_sent(), .data_frames_in(data_frames_in), .core_ready(gpu_core_ready), .mess_to_core(instruction));


endmodule