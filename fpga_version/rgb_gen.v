module rgb_gen (
	input  wire clock   	,
	input  wire reset       ,

	input  wire [ 7:0] data ,
	input  wire        blank,
	input  wire [ 9:0]  x_pos,
	input  wire [ 9:0]  y_pos,

	output reg  [11:0] addr ,
	output reg  [23:0] rgb
);


localparam MAX_NUM = 8'd6;

reg [3:0] h_count_rgb;
reg [3:0] v_count_rgb;

always @(posedge clock) begin
	if( reset )
		addr <= 12'b0;
	else begin
		addr <= (h_count_rgb == MAX_NUM     ) ? addr + (1 << 8)     : 
			(x_pos       == 448         ) ? addr & {4'b0, 8'b1} :
			(x_pos       == 640         ) ? addr + 12'b1        :
			(x_pos == 640 & y_pos == 480) ?        12'b0        :
		       	addr;	
	end

end

always @(posedge clock) begin
	if( reset )
		rgb <= 24'b0;
	else begin
		rgb <= blank & (x_pos < 448) & (y_pos < 448) ? {3{data}} : 24'b0;
	end

end

always @(posedge clock) begin
	if( reset )
		h_count_rgb <= 3'b0;
	else begin
		h_count_rgb <= (h_count_rgb == MAX_NUM) | (x_pos >= 448) ? 4'b0 : h_count_rgb + 4'b1;
	end
end

always @(posedge clock) begin
	if( reset )
		v_count_rgb <= 3'b0;

	else begin
		if(x_pos == 640)
			v_count_rgb <= (v_count_rgb == MAX_NUM) | (y_pos >= 448) ? 4'b0 : v_count_rgb + 4'b1;
		else
			v_count_rgb <= v_count_rgb;
	end
end

endmodule
