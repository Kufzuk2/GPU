`include "scheduler/scheduler.v"
`include "shared_memory/shared_memory.v"
`include "core/gpu_core_1.v"



module gpu

(
	input wire clk,
	input wire reset,

    input  wire core_reading,
    input  wire prog_loading,
    output wire frame_being_sent,
    input  wire [DATA_DEPTH  - 1: 0][INSTR_SIZE - 1: 0] data_frames_in,
    input  wire [CORE_NUM    - 1: 0]                        core_ready,  // may be better reverse it
    
    output  reg [BUS_TO_CORE - 1: 0]                      mess_to_core  //




)




endmodule
