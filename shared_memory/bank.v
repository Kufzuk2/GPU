`define SIMUL_MODE

module bank (
	input   wire        clock,
	input   wire        reset,

	input   wire        read,
	input   wire        write,

	input   wire  [7:0] addr_in,
	input   wire  [7:0] data_in,

	`ifdef SIMUL_MODE
	input   wire  [3:0] bank_n,
	`endif

	output  reg   [7:0] data_out,
	output  reg         finish
);

reg [7:0] mem [255:0];  // bank memory

always @(posedge clock) begin
	mem[addr_in] <= write ? data_in : mem[addr_in];
end

always @(posedge clock) begin
	casex(read)
		1'b0:
			data_out <= 8'b0;
		1'b1:
			data_out <= mem[addr_in];
		default:
			data_out <= 8'b0;
	endcase
end

always @(posedge clock) begin
	finish <= !reset & (write | read) ? 1'b1 : 1'b0;
end

`ifdef SIMUL_MODE
	reg [8 * 29:1] output_file;

	reg [3:0] bank_num;

	//reg 	  was_posedge_rst;
	reg	  was_negedge_rst;

	integer k, out_dsp;

	initial begin
		
		bank_num        = bank_n;
		//was_posedge_rst = 1'b0;
		was_negedge_rst = 1'b0;

	end


       always @(negedge reset) begin
	       was_negedge_rst <= 1'b1;	
       end

       always @(posedge reset) begin
       //         $display("0");

	       if(was_negedge_rst) begin
		       for(k = 0; k < 16; k = k + 1) begin
			       if(k[3:0] == bank_num) begin
				       if(k[3:0] < 10)
					       output_file = {"result/bank_", "0" + k[7:0]        , ".txt"};
				       else
					       output_file = {"result/bank_", "a" + k[7:0] - 8'd10, ".txt"};
				       k = 16;
				end
			end
          //      $display("0");

			out_dsp = $fopen(output_file);

			for(k = 0; k < 256; k = k + 1) begin
				if((k[7:0] + 1) % 64)
					$fwrite(out_dsp, " ");

				$fwrite(out_dsp, "%d ", mem[k[7:0]]);
			end
		
			$fclose(out_dsp);
		    end
        end // of always


`endif

endmodule
