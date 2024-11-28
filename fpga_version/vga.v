module vga (
	input  wire        clock      ,
	input  wire        reset      ,

	input  wire [ 7:0] data       ,	

        output wire        hsync      ,
	output wire        vsync      ,
        output wire        blank_N    ,
        output wire        pixel_clk_N,

	output reg  [11:0] addr       ,

	output reg  [23:0] rgb
);
 
// Horizontal synchronization
localparam H_ACTIVE_VIDEO = 640;
localparam H_FRONT_PORCH  =  16;
localparam H_SYNC_PULSE   =  96;
localparam H_BACK_PORCH   =  48;
localparam H_BLANK_PIX    = H_FRONT_PORCH  + H_SYNC_PULSE + H_BACK_PORCH;
localparam H_TOTAL_PIX    = H_ACTIVE_VIDEO + H_BLANK_PIX                ;
 
// Vertical synchronization
localparam V_ACTIVE_VIDEO = 480;                            
localparam V_FRONT_PORCH  =  10;
localparam V_SYNC_PULSE   =   2;
localparam V_BACK_PORCH   =  33;
localparam V_BLANK_PIX    = V_FRONT_PORCH  + V_SYNC_PULSE + V_BACK_PORCH;
localparam V_TOTAL_PIX    = V_ACTIVE_VIDEO + V_BLANK_PIX                ;
 
// counters
reg [10:0] count_v;
reg [11:0] count_h;
 
assign pixel_clk_N = ~ pixel_clk;
assign blank_N = ~ ((count_V < V_BLANK_PIX) || (count_h < H_BLANK_PIX));
 
assign vsync = (count_v >= V_FRONT_PORCH - 1) && (count_v <= V_FRONT_PORCH + V_SYNC_PULSE - 1);
 

assign hsync = ~ ((count_h >= H_FRONT_PORCH - 1) && (count_h <= H_FRONT_PORCH + H_SYNC_PULSE - 1));
 
always @(posedge pixel_clk) begin
    
	if (count_h < H_TOTAL_PIX)
        	count_h <= count_h + 1'b1;
	else
        	count_h <= 1'b0;
end
 
always @(posedge hsync) begin

	if (count_v < V_TOTAL_PIX)
        	count_v <= count_v + 1'b1;
	else
        	count_v <= 1'b0;
end
endmodule
