`ifdef ALL
`include "shared_memory/bank.v"
`include "shared_memory/round_robin.v"
`endif
`ifndef ALL
`include "bank.v"
`include "round_robin.v"
`endif


`timescale 1 ns / 100 ps
`define SIMUL_MODE

module bank_arbiter (
	input wire clock,
	input wire reset,

	input wire [15:0] read,
	input wire [15:0] write,
	input wire [ 3:0] bank_n,     // bank number

	input  wire [191:0] addr_in,
	input  wire [127:0] data_in,

	output reg [127:0] data_out,
	output reg [ 15:0] finish    // signal for core from arbiter
);

wire 	   addr_cor;     // core has address from this bank
wire       core_serv;    // current core in service
wire [3:0] sel_core;    // kernel selection
wire       bank_finish; // signal for arbiter from bank

// additional wires for input and addr_cor multiplexers
wire [7:0] data_in_mux    [15:0];
wire [7:0] addr_in_mux    [15:0];
wire       addr_cor_mux   [15:0];

// enable/disable read/write for bank
wire b_read;
wire b_write;

// transfer/receive data from bank
wire [7:0] b_addr_in;
wire [7:0] b_data_in;
wire [7:0] b_data_out;

// import bank and round robin algorithm modules
round_robin round_robin ( .clock(clock), .reset(reset), .core_serv(core_serv), .core_val(read | write), .core_cnt(sel_core));

bank bank ( .clock(clock), .reset(reset), .read(b_read), .write(b_write), .addr_in(b_addr_in), .data_in(b_data_in), `ifdef SIMUL_MODE .bank_n(bank_n), `endif .data_out(b_data_out), .finish(bank_finish) );

// define core_serv signal
assign core_serv = addr_cor & !bank_finish ? 1'b1 : 1'b0;

// define read/write signals for bank
assign b_read  = core_serv ? read [sel_core] : 1'b0;
assign b_write = core_serv ? write[sel_core] : 1'b0;


// input and addr_cor multiplexers
assign addr_cor_mux[0] = sel_core == 0 ? (addr_in [11:8] == bank_n) : 1'b0;
assign addr_in_mux [0] = sel_core == 0 ?  addr_in [ 7:0]            : 8'b0;
assign data_in_mux [0] = sel_core == 0 ?  data_in [ 7:0]            : 8'b0;

genvar i;

generate
	for(i = 1; i < 16; i = i + 1) begin: gen_input_mux
		assign addr_cor_mux[i[3:0]] = sel_core == i[3:0] ? (addr_in [11 + i[3:0] * 12 : 8 + i[3:0] * 12] == bank_n) : addr_cor_mux[i[3:0] - 1];
		assign addr_in_mux [i[3:0]] = sel_core == i[3:0] ?  addr_in [ 7 + i[3:0] * 12 : 0 + i[3:0] * 12]            : addr_in_mux [i[3:0] - 1];
		assign data_in_mux [i[3:0]] = sel_core == i[3:0] ?  data_in [ 7 + i[3:0] *  8 : 0 + i[3:0] *  8]            : data_in_mux [i[3:0] - 1];
	end
endgenerate

// define addr_cor signal and input data for bank
assign addr_cor  = addr_cor_mux[15];
assign b_addr_in = addr_in_mux [15];
assign b_data_in = data_in_mux [15];


// connecting data_out from bank with correct part of general data_out bus
generate
	for(i = 0; i < 16; i = i + 1) begin: gen_output_mux
		always @(posedge clock) begin
			data_out[7 + i[3:0] * 8 : 0 + i[3:0] * 8] <= sel_core == i[3:0] ? b_data_out : 8'b0;
		end
	end
endgenerate

// define general finish signal for cores
always @(posedge clock) begin
	if(reset)
		finish <= 16'b0;
	else if(bank_finish)
		finish <= 16'b1 << sel_core;
	else
		finish <= 16'b0;
		
end

`ifdef SIMUL_MODE
	reg [8 * 36:1] output_file;

	reg [3:0] bank_num;

	reg was_posedge_rst;
	reg was_negedge_rst;

	integer k, out_dsp;

	initial begin

		bank_num 	= bank_n;
		was_posedge_rst = 1'b0;
		was_negedge_rst = 1'b0;
	end

	always @(posedge clock) begin

		if(was_negedge_rst & !was_posedge_rst)
		$fdisplay(out_dsp, "Core: %d, status(serv): %d, read: %d, write: %d, addr_in: %d, data_in: %d, data_out: %d, finish: %d at %0t.\n",
		sel_core, core_serv, read[sel_core], write[sel_core], b_addr_in, b_data_in, b_data_out, finish[sel_core], $time);
	end

	always @(negedge reset) begin

		//if(!was_posedge_rst) begin
			for(k = 0; k < 16; k = k + 1) begin
				if(k[3:0] == bank_num) begin
					if(k[3:0] < 10)
						output_file = {"shared_memory/tracing/bank_", "0" + k[7:0]        , "_trc.txt"};
					else
						output_file = {"shared_memory/tracing/bank_", "a" + k[7:0] - 8'd10, "_trc.txt"};
				
					k = 16;
				end
			end

			out_dsp = $fopen(output_file);
			/*if(out_dsp == 0) begin
				$display("Cannot open file %s!\n", output_file);
				$finish;
			end*/

		       was_negedge_rst = 1'b1;
	       //end

	       //else begin
		 //      was_negedge_rst <= 1'b1;
	       //end
	end

	always @(posedge reset) begin
		if(was_negedge_rst) begin
			was_posedge_rst <= 1'b1;

			$fclose(out_dsp);
		end
		/*

		else begin
			was_posedge_rst <= 1'b1;
		end*/
	end

`endif

endmodule
