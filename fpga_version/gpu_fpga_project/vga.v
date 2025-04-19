module vga
	(
		input wire clock,
		input wire reset,
		
		input  wire [ 7:0] data, 
		
		output wire        hsync,
		output wire        vsync,
      output wire        blank,
      output wire        vga_clock,

		output reg   [11:0] addr,

		output wire  [23:0] rgb

	);
	
	wire [9:0] x;
	wire [9:0] y;
	
	reg [9:0] bar_scale_h;
	reg [9:0] bar_scale_v;
	
	wire bar_scale_v_pulse;
	wire bar_scale_h_pulse;
	
	reg [23:0] rgb_reg;
	
	// video status output from vga_sync to tell when to route out rgb signal to DAC
	wire video_on;

        // instantiate vga_sync
        vga_sync vga_sync_unit (.clk(clock), .reset(reset), .hsync(hsync), .vsync(vsync),
                             .video_on(video_on), .p_tick(vga_clock), .x(x), .y(y));
   
			always @(posedge vga_clock) begin
				if(reset) begin
					bar_scale_h <= 0;
				end
				
				else begin
					bar_scale_h <= (video_on) ? (bar_scale_h < 10 ? bar_scale_h + 1 : 0) : 0;
				end
			end
			
			always @(posedge vga_clock) begin
				if(reset) begin
					bar_scale_v <= 0;
				end
				
				else begin
					bar_scale_v <= (video_on && x == 654) ? (bar_scale_v < 7 ? bar_scale_v + 1 : 0) : bar_scale_v;
				end
			end
			
		assign bar_scale_h_pulse = (bar_scale_h == 10            ) ? 1'b1 : 1'b0;
		assign bar_scale_v_pulse = (bar_scale_v ==  7 && x == 654) ? 1'b1 : 1'b0;

        always @(posedge vga_clock) begin
				if (reset) begin
					addr <= 0;
				end
			
				else begin
					addr <= bar_scale_h_pulse || bar_scale_v_pulse ? addr + 1 : addr;
				end
        end
		  
		  always @(posedge vga_clock) begin
				if(reset) begin
					rgb_reg <= 0;
				end
				
				else begin
					rgb_reg <= {3{data}};
				end
		  end


        assign rgb   = (video_on) ? rgb_reg : 24'b0;
		  
		  assign blank = video_on;
		  
endmodule
