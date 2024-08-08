module bank (
	input   wire        clock,
	input   wire        reset,

	input   wire        read,
	input   wire        write,

	input   wire  [7:0] addr_in,
	input   wire  [7:0] data_in,

	output  reg   [7:0] data_out,
	output  reg         finish
);

reg [7:0] mem [255:0];  // bank memory
reg [7:0] tmp_data;    // temporary data register

always @(posedge clock && write) begin
	mem[addr_in] <= data_in;
end

always @(posedge clock && read) begin
	tmp_data <= mem[addr_in];
end

always @(posedge clock) begin
	finish <= ((read || write) && !reset) ? 1'b1 : 1'b0;
end

assign data_out = read ? tmp_data : 'hz;

endmodule