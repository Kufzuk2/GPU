
module gpu(
	input wire clk,  // ASSIGN CLOCK_50
 	input wire KEY0, // ASSIGN KEY_0

    // sdram for prog_loading
    input  wire [15: 0]data_input, // ASSIGN SDRAM DQ_[15: 0]
    output wire [9:  0]input_addr, // ASSIGN SDRAM_ADDR_[9: 0]
    
    output wire mem_clk, // ASSIGN DRAM_CLK
    // ????
    output wire mem_cke, // ASSIGN DRAM_CKE

	input  wire [1024  - 1: 0][15: 0] data_frames_in //// sdram
);
    wire [15 : 0] core_ready;
    wire [15 : 0] read;
    wire [15 : 0] write;
    wire [15 : 0] finish;
    wire [15 : 0] finish_array [15 : 0];

    wire [191:0] addr_in;
    wire [127:0] data_in;
    wire [127:0] data_out;

    wire [15:0] gpu_core_reading;
    wire        final_core_reading;
    wire [15:0]       instruction;
    wire [ 3:0] masks;

    wire         r0_loading;
    wire  core_mask_loading;
    wire    r0_mask_loading;
    wire val_ins;


    button 
    rst_but
           (
               .clk(clk),
               .KEY(KEY0),
               .skey(reset)
           );



assign finish = finish_array[ 0] |  finish_array[ 1] |  finish_array[ 2] | finish_array[ 3] | finish_array[ 4] | finish_array[ 5] | finish_array[ 6] | finish_array[ 7] | 
		finish_array[ 8] |  finish_array[ 9] |  finish_array[10] | finish_array[11] | finish_array[12] | finish_array[13] | finish_array[14] | finish_array[15] ; 

genvar i;

generate
	for(i = 0; i < 16; i = i + 1) begin: gen_cores
		gpu_core_1 gpu_core_i 
                        ( .clk(clk), .reset(reset),           .val_ins(val_ins),    .val_mask_R0(r0_mask_loading), 
                          .val_mask_ac(core_mask_loading),    .val_R0(r0_loading),  .val_data(finish[i[3:0]]),       // initially was 8 * i[3:0]
                          .instruction(instruction), .addr_shared_memory(addr_in[11 + 12 * i[3:0] : 12 * i[3:0]]),

                          .mem_dat(data_out[7 + 8 * i[3:0] : 8 *  i[3:0]]),  .mem_dat_st(data_in[7 + 8 * i[3:0] : 8 * i[3:0]]),
                          .core_id(i[3:0]), .rtr(gpu_core_reading[i[3:0]]), .mem_req_ld(read[i[3:0]]), 
                          .mem_req_st(write[i[3:0]]), .ready(core_ready[i[3:0]])
                        );
	end
endgenerate

generate
	for(i = 0; i < 16; i = i + 1) begin: gen_bank_arbiters
	bank_arbiter arbiter_i 
                    (.clock(clk), .reset(reset), .read(read), .write(write),
                     .bank_n(i[3:0]), .addr_in(addr_in), .data_in(data_in), 
                     .data_out(data_out), .finish(finish_array[i[3:0]])
                    );
	end
endgenerate




scheduler gpu_scheduler 
                    ( .clk(clk), .reset(reset),  .instr_loading(val_ins),
                      .r0_mask_loading(r0_mask_loading),     .core_mask_loading(core_mask_loading),
                      .r0_loading(r0_loading),             .core_reading(gpu_core_reading), 
                      .prog_loading(prog_loading),
                      .data_frames_in(data_frames_in), 
                      .core_ready(core_ready), .mess_to_core(instruction)
                    );
    input  wire [15: 0] data_input,
    output wire [9:  0] input_addr,


endmodule
