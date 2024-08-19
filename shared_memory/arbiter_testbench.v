`timescale 1 ns / 100 ps

module arbiter_testbench ();

reg clk = 1'b1;
always begin
	#1 clk = ~clk;
end

reg rst = 1'b1;

reg [15:0] core_read  = 16'b1001000000001000;
reg [15:0] core_write = 16'b0100000001000101;

reg [11:0] core_addr_in [15:0];
reg [ 7:0] core_data_in [15:0];

wire [191:0] addr;
wire [127:0] data_in;
wire [127:0] data_out;
wire [ 15:0] finish;

wire [7:0] data_out_core_3;

assign addr = {core_addr_in[15], core_addr_in[14], core_addr_in[13], core_addr_in[12], core_addr_in[11],
core_addr_in[10], core_addr_in[9], core_addr_in[8], core_addr_in[7], core_addr_in[6], core_addr_in[5],
core_addr_in[4], core_addr_in[3], core_addr_in[2], core_addr_in[1], core_addr_in[0] };

assign data_in = {core_data_in[15], core_data_in[14], core_data_in[13], core_data_in[12], core_data_in[11],
core_data_in[10], core_data_in[9], core_data_in[8], core_data_in[7], core_data_in[6], core_data_in[5],
core_data_in[4], core_data_in[3], core_data_in[2], core_data_in[1], core_data_in[0] } ;

assign data_out_core_3 = data_out[31:24];

bank_arbiter arbiter_0 ( .clock(clk), .reset(rst), .read(core_read), .write(core_write),
 .bank_n(4'b0), .addr_in(addr), .data_in(data_in), .data_out(data_out), .finish(finish));



initial begin
	core_addr_in[ 0] = 12'b000000000001;
	core_addr_in[ 2] = 12'b000000000010;
	core_addr_in[ 3] = 12'b000000000001;
	core_addr_in[ 6] = 12'b000010000001;
	core_addr_in[12] = 12'b000010000001;
	core_addr_in[14] = 12'b000100000001;
	core_addr_in[15] = 12'b000000000010;

	core_data_in[ 0] = 8'b00000100;
	core_data_in[ 2] = 8'b00000011;
	core_data_in[ 6] = 8'b10000000;
	core_data_in[14] = 8'b00000111;

	#1; rst = 0;
	#45;
	$finish;
end

endmodule