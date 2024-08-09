module bank_arbiter (
	input wire clock,
	input wire clock2,
	input wire reset,

	input wire [15:0] read,
	input wire [15:0] write,
	input wire [ 3:0] bank_n,     // bank number
	input wire [15:0] core_val,   // core needs in memory access

	input  wire [191:0] addr_in,
	input  wire [127:0] data_in,

	output reg [127:0] data_out,
	output reg [ 15:0] finish    // signal for core from arbiter
);
reg [15:0] core_cnt;     // core counter
reg        addr_cor;     // core has address from this bank

wire        core_serv;    // current core in service
wire [15:0] sel_core;    // kernel selection
wire        bank_finish; // signal for arbiter from bank

wire b_read;
wire b_write;

reg  [ 7:0] b_addr_in;
reg  [ 7:0] b_data_in;
wire [ 7:0] b_data_out;


bank bank ( .clock(clock), .reset(reset), .read(b_read), .write(b_write), .addr_in(b_addr_in), .data_in(b_data_in), .data_out(b_data_out), .finish(bank_finish) );

always @(posedge clock) begin
	if(reset) begin
		core_cnt  <= 16'b0;

	end

	else begin
		core_cnt  <= core_serv ? core_cnt : core_cnt + 1;
	end
end

assign core_serv = core_val[core_cnt] && addr_cor && !bank_finish ? 1'b1 : 1'b0;

assign sel_core = core_cnt;

assign b_read  = core_serv ? read [core_cnt] : 1'b0;
assign b_write = core_serv ? write[core_cnt] : 1'b0;

always @(sel_core) begin
	case(sel_core)
		16'd0 :	begin
				addr_cor   = (addr_in [ 11:  8] == bank_n);
				b_addr_in  =  addr_in [  7:  0];
				b_data_in  =  data_in [  7:  0];

			end
		16'd1 :	begin
				addr_cor   = (addr_in [ 23: 20] == bank_n);
				b_addr_in  =  addr_in [ 19: 12];
				b_data_in  =  data_in [ 15:  8];

			end
		16'd2 :	begin
				addr_cor   = (addr_in [ 35: 32] == bank_n);
				b_addr_in  =  addr_in [ 31: 24];
				b_data_in  =  data_in [ 23: 16];

			end
		16'd3 :	begin
				addr_cor   = (addr_in [ 47: 44] == bank_n);
				b_addr_in  =  addr_in [ 43: 36];
				b_data_in  =  data_in [ 31: 24];
						
			end
		16'd4 :	begin
				addr_cor   = (addr_in [ 59: 56] == bank_n);
				b_addr_in  =  addr_in [ 55: 48];
				b_data_in  =  data_in [ 39: 32];

			end
		16'd5 :	begin
				addr_cor   = (addr_in [ 71: 68] == bank_n);
				b_addr_in  =  addr_in [ 67: 60];
				b_data_in  =  data_in [ 47: 40];

			end
		16'd6 :	begin
				addr_cor   = (addr_in [ 83: 80] == bank_n);
				b_addr_in  =  addr_in [ 79: 72];
				b_data_in  =  data_in [ 55: 48];

			end
		16'd7 :	begin
				addr_cor   = (addr_in [ 95: 92] == bank_n);
				b_addr_in  =  addr_in [ 91: 84];
				b_data_in  =  data_in [ 63: 56];

			end
		16'd8 :	begin
				addr_cor   = (addr_in [107:104] == bank_n);
				b_addr_in  =  addr_in [103: 96];
				b_data_in  =  data_in [ 71: 64];

			end
		16'd9 :	begin
				addr_cor   = (addr_in [119:116] == bank_n);
				b_addr_in  =  addr_in [115:108];
				b_data_in  =  data_in [ 79: 72];
			end
		16'd10:	begin
				addr_cor   = (addr_in [131:128] == bank_n);
				b_addr_in  =  addr_in [127:120];
				b_data_in  =  data_in [ 87: 80];
			end
		16'd11:	begin
				addr_cor   = (addr_in [143:140] == bank_n);
				b_addr_in  =  addr_in [139:132];
				b_data_in  =  data_in [ 95: 88];
			end
		16'd12:	begin
				addr_cor   = (addr_in [155:152] == bank_n);
				b_addr_in  =  addr_in [151:144];
				b_data_in  =  data_in [103: 96];
			end
		16'd13:	begin
				addr_cor   = (addr_in [167:164] == bank_n);
				b_addr_in  =  addr_in [163:156];
				b_data_in  =  data_in [111:104];
			end
		16'd14:	begin
				addr_cor   = (addr_in [179:176] == bank_n);
				b_addr_in  =  addr_in [175:168];
				b_data_in  =  data_in [119:112];
			end
		16'd15:	begin
				addr_cor   = (addr_in [191:188] == bank_n);
				b_addr_in  =  addr_in [187:180];
				b_data_in  =  data_in [127:120];
			end

		default:
			begin
				addr_cor  = 1'b0;
				b_addr_in = 'hz;
				b_data_in = 'hz;
			end
	endcase
end

always @(posedge clock) begin
	case(sel_core)
		16'd0 :
			data_out[  7:  0] <= b_data_out;
		16'd1 :
			data_out[ 15:  8] <= b_data_out;
		16'd2 :
			data_out[ 23: 16] <= b_data_out;
		16'd3 :
			data_out[ 31: 24] <= b_data_out;
		16'd4 :
			data_out[ 39: 32] <= b_data_out;
		16'd5 :
			data_out[ 47: 40] <= b_data_out;
		16'd6 :
			data_out[ 55: 48] <= b_data_out;
		16'd7 :
			data_out[ 63: 56] <= b_data_out;
		16'd8 :
			data_out[ 71: 64] <= b_data_out;
		16'd9 :
			data_out[ 79: 72] <= b_data_out;
		16'd10:
			data_out[ 87: 80] <= b_data_out;
		16'd11:
			data_out[ 95: 88] <= b_data_out;
		16'd12:
			data_out[103: 96] <= b_data_out;
		16'd13:
			data_out[111:104] <= b_data_out;
		16'd14:
			data_out[119:112] <= b_data_out;
		16'd15:
			data_out[127:120] <= b_data_out;
		default:
			data_out <= 'hz;
	endcase

end

always @(posedge clock) begin
	if(reset)
		finish <= 16'b0;
	else if(bank_finish)
		finish <= 16'b1 << core_cnt;
	else
		finish <= 16'b0;
		
end

endmodule