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

always @(posedge clock) begin
	mem[addr_in] <= write ? data_in : mem[addr_in];
end

always @(posedge clock) begin
	data_out <= read ? mem[addr_in] : 'hz;
end

always @(posedge clock) begin
	finish <= !reset && (write || read) ? 1'b1 : 1'b0;
end

endmodule