module ts_to_core (
	input wire clk,
	input wire  [15:0] active_core,
	input wire [15:0] mess_from_ts,
	input wire cf_val,
	input wire if_val,
	
	
	output reg [15:0] ready_bus,
	output reg [15:0] rtr_bus,
	output reg cf_val_c0,
	output reg if_val_c0,
	output reg [15:0] mess_to_c0,
	input  wire ready_c0,
	input  wire rtr_c0,
	
	output reg cf_val_c1,
	output reg if_val_c1,
	output reg  [15:0] mess_to_c1,
	input  wire ready_c1,
	input  wire rtr_c1,
	
	output reg cf_val_c2,
	output reg if_val_c2,
	output reg [15:0] mess_to_c2,
	input  wire ready_c2,
	input  wire rtr_c2,
	
	output reg cf_val_c3,
	output reg if_val_c3,
	output reg [15:0] mess_to_c3,
	input  wire ready_c3,
	input  wire rtr_c3,
	
	output reg cf_val_c4,
	output reg if_val_c4,
	output reg [15:0] mess_to_c4,
	input  wire ready_c4,
	input  wire rtr_c4,
	
	output reg cf_val_c5,
	output reg if_val_c5,
	output reg [15:0] mess_to_c5,
	input  wire ready_c5,
	input  wire rtr_c5,
	
	output reg cf_val_c6,
	output reg if_val_c6,
	output reg [15:0] mess_to_c6,
	input  wire ready_c6,
	input  wire rtr_c6,
	
	output reg cf_val_c7,
	output reg if_val_c7,
	output reg [15:0] mess_to_c7,
	input  wire ready_c7,
	input  wire rtr_c7,
	
	output reg cf_val_c8,
	output reg if_val_c8,
	output reg [15:0] mess_to_c8,
	input  wire ready_c8,
	input  wire rtr_c8,
	
	output reg cf_val_c9,
	output reg if_val_c9,
	output reg [15:0] mess_to_c9,
	input  wire ready_c9,
	input  wire rtr_c9,
	
	output reg cf_val_c10,
	output reg if_val_c10,
	output reg [15:0] mess_to_c10,
	input  wire ready_c10,
	input  wire rtr_c10,
	
	output reg cf_val_c11,
	output reg if_val_c11,		  
	output reg [15:0] mess_to_c11,
	input  wire ready_c11,
	input  wire rtr_c11,
	
	output reg cf_val_c12,
	output reg if_val_c12,		  
	output reg [15:0] mess_to_c12,
	input  wire ready_c12,
	input  wire rtr_c12,
	
	output reg cf_val_c13,
	output reg if_val_c13,		  
	output reg [15:0] mess_to_c13,
	input  wire ready_c13,
	input  wire rtr_c13,
	
	output reg cf_val_c14,
	output reg if_val_c14,		  
	output reg [15:0] mess_to_c14,
	input  wire ready_c14,
	input  wire rtr_c14,
	
	output reg cf_val_c15,
	output reg if_val_c15,		  
	output reg [15:0] mess_to_c15,
	input  wire ready_c15,
	input  wire rtr_c15
	);
gpu_core_0 c0 (	
.val_ins(if_val_c0),
.instruction(mess_to_c0),
.ready(ready_c0),
.rtr(rtr_c0)
);

gpu_core_1 c1 (	
.val_ins(if_val_c1),
.instruction(mess_to_c1),
.ready(ready_c1),
.rtr(rtr_c1)
);

gpu_core_2 c2 (	
.val_ins(if_val_c2),
.instruction(mess_to_c2),
.ready(ready_c2),
.rtr(rtr_c2)
);

gpu_core_3 c3 (	
.val_ins(if_val_c3),
.instruction(mess_to_c3),
.ready(ready_c3),
.rtr(rtr_c3)
); 

gpu_core_4 c4 (	
.val_ins(if_val_c4),
.instruction(mess_to_c4),
.ready(ready_c4),
.rtr(rtr_c4)
);

gpu_core_5 c5 (	
.val_ins(if_val_c5),
.instruction(mess_to_c5),
.ready(ready_c5),
.rtr(rtr_c5)
);

gpu_core_6 c6 (	
.val_ins(if_val_c6),
.instruction(mess_to_c6),
.ready(ready_c6),
.rtr(rtr_c6)
); 

gpu_core_7 c7 (	
.val_ins(if_val_c7),
.instruction(mess_to_c7),
.ready(ready_c7),
.rtr(rtr_c7)
);

gpu_core_8 c8 (	
.val_ins(if_val_c8),
.instruction(mess_to_c8),
.ready(ready_c8),
.rtr(rtr_c8)
);

gpu_core_9 c9 (	
.val_ins(if_val_c9),
.instruction(mess_to_c9),
.ready(ready_c9),
.rtr(rtr_c9)
);

gpu_core_10 c10 (	
.val_ins(if_val_c10),
.instruction(mess_to_c10),
.ready(ready_c10),
.rtr(rtr_c10)
);

gpu_core_11 c11 (	
.val_ins(if_val_c11),
.instruction(mess_to_c11),
.ready(ready_c11),
.rtr(rtr_c11)
); 

gpu_core_12 c12 (	
.val_ins(if_val_c12),
.instruction(mess_to_c12),
.ready(ready_c12),
.rtr(rtr_c12)
);

gpu_core_13 c13 (	
.val_ins(if_val_c13),
.instruction(mess_to_c13),
.ready(ready_c13),
.rtr(rtr_c13)
); 

gpu_core_14 c14 (	
.val_ins(if_val_c14),
.instruction(mess_to_c14),
.ready(ready_c14),
.rtr(rtr_c14)
);

gpu_core_15 c15 (	
.val_ins(if_val_c15),
.instruction(mess_to_c15),
.ready(ready_c15),
.rtr(rtr_c15)
);

always @(posedge clk)
	begin
		ready_bus[0] <= ready_c0;
		rtr_bus[0]   <= rtr_c0;
		if (if_val)
		mess_to_c0 <= mess_from_ts;
			begin
				if (active_core[0])
					begin
						if_val_c0  <= if_val;
					end
				else
					begin
						if_val_c0 <= 0;
					end
			end
	end

always @(posedge clk)
	begin
		ready_bus[1] <= ready_c1;
		rtr_bus[1]   <= rtr_c1;
		if (if_val)
		mess_to_c1 <= mess_from_ts;
			begin
				if (active_core[1])
					begin
						if_val_c1  <= if_val;
					end
				else
					begin
						if_val_c1 <= 0;
					end
			end
	end

always @(posedge clk)
	begin
		ready_bus[2] <= ready_c2;
		rtr_bus[2]   <= rtr_c2;
		if (if_val)
		mess_to_c2 <= mess_from_ts;
			begin
				if (active_core[2])
					begin
						if_val_c2  <= if_val;
					end
				else
					begin
						if_val_c2 <= 0;
					end
			end
	end

	
always @(posedge clk)
	begin  
		ready_bus[3] <= ready_c3;
		rtr_bus[3]   <= rtr_c3;
		if (if_val)
		mess_to_c3 <= mess_from_ts;
			begin
				if (active_core[3])
					begin
						if_val_c3  <= if_val;
					end
				else
					begin
						if_val_c3 <= 0;
					end
			end
	end	

always @(posedge clk)
	begin 
		ready_bus[4] <= ready_c4;
		rtr_bus[4]   <= rtr_c4;
		if (if_val)
		mess_to_c4 <= mess_from_ts;
			begin
				if (active_core[4])
					begin
						if_val_c4  <= if_val;
					end
				else
					begin
						if_val_c4 <= 0;
					end
			end
	end
	
always @(posedge clk)
	begin
		ready_bus[5] <= ready_c5;
		rtr_bus[5]   <= rtr_c5;
		if (if_val)
		mess_to_c5 <= mess_from_ts;
			begin
				if (active_core[5])
					begin
						if_val_c5  <= if_val;
					end
				else
					begin
						if_val_c5 <= 0;
					end
			end
	end
	
	always @(posedge clk)
	begin 
		ready_bus[6] <= ready_c6;
		rtr_bus[6]   <= rtr_c6;
		if (if_val)
		mess_to_c6 <= mess_from_ts;
			begin
				if (active_core[6])
					begin
						if_val_c6  <= if_val;
					end
				else
					begin
						if_val_c6 <= 0;
					end
			end
	end
	
	always @(posedge clk)
	begin
		ready_bus[7] <= ready_c7;
		rtr_bus[7]   <= rtr_c7;
		if (if_val)
		mess_to_c7 <= mess_from_ts;
			begin
				if (active_core[7])
					begin
						if_val_c7  <= if_val;
					end
				else
					begin
						if_val_c7 <= 0;
					end
			end
	end
	
	always @(posedge clk)
	begin
		ready_bus[8] <= ready_c8;
		rtr_bus[8]   <= rtr_c8;
		if (if_val)
		mess_to_c8 <= mess_from_ts;
			begin
				if (active_core[8])
					begin
						if_val_c8  <= if_val;
					end
				else
					begin
						if_val_c8 <= 0;
					end
			end
	end
	
	always @(posedge clk)
	begin
		ready_bus[9] <= ready_c9;
		rtr_bus[9]   <= rtr_c9;
		if (if_val)
		mess_to_c9 <= mess_from_ts;
			begin
				if (active_core[9])
					begin
						if_val_c9  <= if_val;
					end
				else
					begin
						if_val_c9 <= 0;
					end
			end
	end
	
	always @(posedge clk)
	begin
		ready_bus[10] <= ready_c10;
		rtr_bus[10]   <= rtr_c10;
		if (if_val)
		mess_to_c10 <= mess_from_ts;
			begin
				if (active_core[10])
					begin
						if_val_c10  <= if_val;
					end
				else
					begin
						if_val_c10 <= 0;
					end
			end
	end
	
	always @(posedge clk)
	begin		  
		ready_bus[11] <= ready_c11;
		rtr_bus[11]   <= rtr_c11;
		if (if_val)
		mess_to_c11 <= mess_from_ts;
			begin
				if (active_core[11])
					begin
						if_val_c11  <= if_val;
					end
				else
					begin
						if_val_c11 <= 0;
					end
			end
	end
	
	always @(posedge clk)
	begin
		ready_bus[12] <= ready_c12;
		rtr_bus[12]   <= rtr_c12;
		if (if_val)
		mess_to_c12 <= mess_from_ts;
			begin
				if (active_core[12])
					begin
						if_val_c12  <= if_val;
					end
				else
					begin
						if_val_c12 <= 0;
					end
			end
	end
	
	always @(posedge clk)
	begin
		ready_bus[13] <= ready_c13;
		rtr_bus[13]   <= rtr_c13;
		if (if_val)
		mess_to_c13 <= mess_from_ts;
			begin
				if (active_core[13])
					begin
						if_val_c13  <= if_val;
					end
				else
					begin
						if_val_c13 <= 0;
					end
			end
	end
	
	always @(posedge clk)
	begin
		ready_bus[14] <= ready_c14;
		rtr_bus[14]   <= rtr_c14;
		if (if_val)
		mess_to_c14 <= mess_from_ts;
			begin
				if (active_core[14])
					begin
						if_val_c14  <= if_val;
					end
				else
					begin
						if_val_c14 <= 0;
					end
			end
	end
	
	always @(posedge clk)
		
	begin  
		ready_bus[15] <= ready_c15;
		rtr_bus[15]   <= rtr_c15;
		if (if_val)
		mess_to_c15 <= mess_from_ts;
			begin
				if (active_core[15])
					begin
						if_val_c15  <= if_val;
					end
				else
					begin
						if_val_c15 <= 0;
					end
			end
	end
endmodule
