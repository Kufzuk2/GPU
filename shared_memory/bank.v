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
			data_out <= 8'hx;
		1'b1:
			data_out <= mem[addr_in];
		default:
			data_out <= 8'hx;
	endcase
end

always @(posedge clock) begin
	finish <= !reset & (write | read) ? 1'b1 : 1'b0;
end


`ifdef SIMUL_MODE
	reg [8 * 29:1] output_file;

	reg [3:0] bank_num;
	reg [1:0]     flag;

	integer k, out_dsp;

	initial begin
		
		//prev_reset = 1'b1;
		//while(!reset) was_reset = 1'b0;
		
		flag = 2'b0;
		bank_num = bank_n;
		for(k = 0; k < 16; k = k + 1) begin
			if(k[3:0] == bank_n) begin
				if(k[3:0] < 10)
					output_file = {"shared_memory/data/bank_", "0" + k[7:0]        , ".txt"};
				else
					output_file = {"shared_memory/data/bank_", "a" + k[7:0] - 8'd10, ".txt"};
				
				k = 16;
			end
		end

		while(flag < 2'b01) k = 0;
		out_dsp = $fopen(output_file);
		for(k = 0; k < 256; k = k + 1) begin
			if((k[7:0] + 1) % 64)
				$fwrite(out_dsp, " ");

			$fwrite(out_dsp, "%d %t\n", mem[k[7:0]], $time);
		end
		
		$fclose(out_dsp);
	end

	/*always @(posedge clock) begin
		if(prev_reset == 1'b0 & reset == 1'b1) begin
			out_dsp = $fopen(output_file);
			if(out_dsp == 0) begin
				$display("Cannot open file %s!\n", output_file);
				$finish;
			end

			for(k = 0; k < 256; k = k + 1) begin
				if((k[7:0] + 1) % 64)
					$fwrite(out_dsp, " ");

				$fwrite(out_dsp, "%d %t\n", mem[k[7:0]], $time);
			end
		
			$fclose(out_dsp);
		end
	end*/

       always @(posedge reset) begin
		flag <= flag + 1;	
       end


`endif

endmodule
