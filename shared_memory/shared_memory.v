module shared_memory (
	input wire clock,
	input wire reset,

	input wire read_0 , input wire write_0 , input wire core_val_0 ,
	input wire read_1 , input wire write_1 , input wire core_val_1 ,
	input wire read_2 , input wire write_2 , input wire core_val_2 ,
	input wire read_3 , input wire write_3 , input wire core_val_3 ,
	input wire read_4 , input wire write_4 , input wire core_val_4 ,
	input wire read_5 , input wire write_5 , input wire core_val_5 ,
	input wire read_6 , input wire write_6 , input wire core_val_6 ,
	input wire read_7 , input wire write_7 , input wire core_val_7 ,
	input wire read_8 , input wire write_8 , input wire core_val_8 ,
	input wire read_9 , input wire write_9 , input wire core_val_9 ,
	input wire read_10, input wire write_10, input wire core_val_10,
	input wire read_11, input wire write_11, input wire core_val_11,
	input wire read_12, input wire write_12, input wire core_val_12,
	input wire read_13, input wire write_13, input wire core_val_13,
	input wire read_14, input wire write_14, input wire core_val_14,
	input wire read_15, input wire write_15, input wire core_val_15,

	input  wire [11:0] addr_in_0 , input  wire [7:0] data_in_0 ,
	input  wire [11:0] addr_in_1 , input  wire [7:0] data_in_1 ,
	input  wire [11:0] addr_in_2 , input  wire [7:0] data_in_2 ,
	input  wire [11:0] addr_in_3 , input  wire [7:0] data_in_3 ,
	input  wire [11:0] addr_in_4 , input  wire [7:0] data_in_4 ,
	input  wire [11:0] addr_in_5 , input  wire [7:0] data_in_5 ,
	input  wire [11:0] addr_in_6 , input  wire [7:0] data_in_6 ,
	input  wire [11:0] addr_in_7 , input  wire [7:0] data_in_7 ,
	input  wire [11:0] addr_in_8 , input  wire [7:0] data_in_8 ,
	input  wire [11:0] addr_in_9 , input  wire [7:0] data_in_9 ,
	input  wire [11:0] addr_in_10, input  wire [7:0] data_in_10,
	input  wire [11:0] addr_in_11, input  wire [7:0] data_in_11,
	input  wire [11:0] addr_in_12, input  wire [7:0] data_in_12,
	input  wire [11:0] addr_in_13, input  wire [7:0] data_in_13,
	input  wire [11:0] addr_in_14, input  wire [7:0] data_in_14,
	input  wire [11:0] addr_in_15, input  wire [7:0] data_in_15,


	output reg [7:0] data_out_0 , output reg finish_0 ,
	output reg [7:0] data_out_1 , output reg finish_1 ,
	output reg [7:0] data_out_2 , output reg finish_2 ,
	output reg [7:0] data_out_3 , output reg finish_3 ,
	output reg [7:0] data_out_4 , output reg finish_4 ,
	output reg [7:0] data_out_5 , output reg finish_5 ,
	output reg [7:0] data_out_6 , output reg finish_6 ,
	output reg [7:0] data_out_7 , output reg finish_7 ,
	output reg [7:0] data_out_8 , output reg finish_8 ,
	output reg [7:0] data_out_9 , output reg finish_9 ,
	output reg [7:0] data_out_10, output reg finish_10,
	output reg [7:0] data_out_11, output reg finish_11,
	output reg [7:0] data_out_12, output reg finish_12,
	output reg [7:0] data_out_13, output reg finish_13,
	output reg [7:0] data_out_14, output reg finish_14,
	output reg [7:0] data_out_15, output reg finish_15
);

wire [15:0] read;
wire [15:0] write;
wire [15:0] core_val;

assign read = {read_15, read_14, read_13, read_12, read_11, read_10, read_9 , read_8 , read_7 , 
read_6 , read_5 , read_4 , read_3 , read_2 , read_1 , read_0};

assign write = {write_15, write_14, write_13, write_12, write_11, write_10, write_9 , write_8 , 
write_7 , write_6 , write_5 , write_4 , write_3 , write_2 , write_1 , write_0};

assign core_val = {core_val_15, core_val_14, core_val_13, core_val_12, core_val_11, core_val_10, 
core_val_9 , core_val_8 , core_val_7 , core_val_6 , core_val_5 , core_val_4 , core_val_3, 
core_val_2, core_val_1 , core_val_0};


wire [191:0] addr_in;
wire [127:0] data_in;

assign addr_in = {addr_in_15, addr_in_14, addr_in_13, addr_in_12, addr_in_11, addr_in_10, addr_in_9 , 
addr_in_8 , addr_in_7 , addr_in_6 , addr_in_5 , addr_in_4 , addr_in_3 , addr_in_2 , addr_in_1 , addr_in_0};

assign data_in = {data_in_15, data_in_14, data_in_13, data_in_12, data_in_11, data_in_10, data_in_9 , 
data_in_8 , data_in_7 , data_in_6 , data_in_5 , data_in_4 , data_in_3 , data_in_2 , data_in_1 , data_in_0};


wire [127:0] data_out;
wire [ 15:0] finish;

assign data_out_0  = data_out[  7:  0]; assign finish_0 = finish[ 0];
assign data_out_1  = data_out[ 15:  8]; assign finish_1 = finish[ 1];
assign data_out_2  = data_out[ 23: 16]; assign finish_1 = finish[ 2];
assign data_out_3  = data_out[ 31: 24]; assign finish_1 = finish[ 3];
assign data_out_4  = data_out[ 39: 32]; assign finish_1 = finish[ 4];
assign data_out_5  = data_out[ 47: 40]; assign finish_1 = finish[ 5];
assign data_out_6  = data_out[ 55: 48]; assign finish_1 = finish[ 6];
assign data_out_7  = data_out[ 63: 56]; assign finish_1 = finish[ 7];
assign data_out_8  = data_out[ 71: 64]; assign finish_1 = finish[ 8];
assign data_out_9  = data_out[ 79: 72]; assign finish_1 = finish[ 9];
assign data_out_10 = data_out[ 87: 80]; assign finish_1 = finish[10];
assign data_out_11 = data_out[ 95: 88]; assign finish_1 = finish[11];
assign data_out_12 = data_out[103: 96]; assign finish_1 = finish[12];
assign data_out_13 = data_out[111:104]; assign finish_1 = finish[13];
assign data_out_14 = data_out[119:112]; assign finish_1 = finish[14];
assign data_out_15 = data_out[127:120]; assign finish_1 = finish[15];


bank_arbiter arbiter_0  ( .clock(clock), .reset(reset), .read(read), .write(write),
 .bank_n(4'd0 ), .core_val(core_val), .addr_in(addr_in), .data_in(data_in), .data_out(data_out), .finish(finish));

bank_arbiter arbiter_1  ( .clock(clock), .reset(reset), .read(read), .write(write),
 .bank_n(4'd1 ), .core_val(core_val), .addr_in(addr_in), .data_in(data_in), .data_out(data_out), .finish(finish));

bank_arbiter arbiter_2  ( .clock(clock), .reset(reset), .read(read), .write(write),
 .bank_n(4'd2 ), .core_val(core_val), .addr_in(addr_in), .data_in(data_in), .data_out(data_out), .finish(finish));

bank_arbiter arbiter_3  ( .clock(clock), .reset(reset), .read(read), .write(write),
 .bank_n(4'd3 ), .core_val(core_val), .addr_in(addr_in), .data_in(data_in), .data_out(data_out), .finish(finish));

bank_arbiter arbiter_4  ( .clock(clock), .reset(reset), .read(read), .write(write),
 .bank_n(4'd4 ), .core_val(core_val), .addr_in(addr_in), .data_in(data_in), .data_out(data_out), .finish(finish));

bank_arbiter arbiter_5  ( .clock(clock), .reset(reset), .read(read), .write(write),
 .bank_n(4'd5 ), .core_val(core_val), .addr_in(addr_in), .data_in(data_in), .data_out(data_out), .finish(finish));

bank_arbiter arbiter_6  ( .clock(clock), .reset(reset), .read(read), .write(write),
 .bank_n(4'd6 ), .core_val(core_val), .addr_in(addr_in), .data_in(data_in), .data_out(data_out), .finish(finish));

bank_arbiter arbiter_7  ( .clock(clock), .reset(reset), .read(read), .write(write),
 .bank_n(4'd7 ), .core_val(core_val), .addr_in(addr_in), .data_in(data_in), .data_out(data_out), .finish(finish));

bank_arbiter arbiter_8  ( .clock(clock), .reset(reset), .read(read), .write(write),
 .bank_n(4'd8 ), .core_val(core_val), .addr_in(addr_in), .data_in(data_in), .data_out(data_out), .finish(finish));

bank_arbiter arbiter_9  ( .clock(clock), .reset(reset), .read(read), .write(write),
 .bank_n(4'd9 ), .core_val(core_val), .addr_in(addr_in), .data_in(data_in), .data_out(data_out), .finish(finish));

bank_arbiter arbiter_10 ( .clock(clock), .reset(reset), .read(read), .write(write),
 .bank_n(4'd10), .core_val(core_val), .addr_in(addr_in), .data_in(data_in), .data_out(data_out), .finish(finish));

bank_arbiter arbiter_11 ( .clock(clock), .reset(reset), .read(read), .write(write),
 .bank_n(4'd11), .core_val(core_val), .addr_in(addr_in), .data_in(data_in), .data_out(data_out), .finish(finish));

bank_arbiter arbiter_12 ( .clock(clock), .reset(reset), .read(read), .write(write),
 .bank_n(4'd12), .core_val(core_val), .addr_in(addr_in), .data_in(data_in), .data_out(data_out), .finish(finish));

bank_arbiter arbiter_13 ( .clock(clock), .reset(reset), .read(read), .write(write),
 .bank_n(4'd13), .core_val(core_val), .addr_in(addr_in), .data_in(data_in), .data_out(data_out), .finish(finish));

bank_arbiter arbiter_14 ( .clock(clock), .reset(reset), .read(read), .write(write),
 .bank_n(4'd14), .core_val(core_val), .addr_in(addr_in), .data_in(data_in), .data_out(data_out), .finish(finish));

bank_arbiter arbiter_15 ( .clock(clock), .reset(reset), .read(read), .write(write),
 .bank_n(4'd15), .core_val(core_val), .addr_in(addr_in), .data_in(data_in), .data_out(data_out), .finish(finish));

endmodule