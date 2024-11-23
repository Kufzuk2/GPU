
module scheduler
#(
    parameter     DATA_DEPTH  = 1024,
    parameter   R0_DATA_SIZE  =  128,  
    parameter CTRL_DATA_SIZE  =   48,  
    parameter     INSTR_SIZE  =   16,
    parameter     FRAME_SIZE  =  256,
    parameter      FRAME_NUM  =   64,
    parameter       CORE_NUM  =   16,
    parameter    BUS_TO_CORE  =   16,
    parameter       R0_DEPTH  =    8
)


(
    input  wire clk,
    input  wire reset,
    input  wire [15: 0] core_reading,
    input  wire [15: 0] data_input,
    input  wire [DATA_DEPTH  - 1: 0][INSTR_SIZE - 1: 0] data_frames_in,
    input  wire [CORE_NUM    - 1: 0]                        core_ready,  // may be better reverse it
    output  reg [BUS_TO_CORE - 1: 0]                      mess_to_core,  //

    output wire [9:  0] input_addr, 
    output reg          r0_loading,
    output reg   core_mask_loading,
    output reg     r0_mask_loading,
    output reg       instr_loading
//change for wires where possible
);
   
    reg prog_loading;
    reg [15: 0] load_cnt;

    always @(posedge clk) begin
        if (reset)
            prog_loading <= 1;
        else
            prog_loading <= (load_cnt == 4'hf)                                     ? 0 : 
            ((global_tp[3: 0] == 4'hf) | (wait_it & (last_mask & exec_mask != 0))) ? 1 :
                                                                           prog_loading;
    end

    always @(posedge clk) begin
        if (reset)
            load_cnt <= 0;
        else
            load_cnt <= ~prog_loading      ? 0 :
                        (load_cnt == 4'hf) ? 0 : load_cnt + 1;
    end
    
    genvar j;
    generate
    for (j = 0; j < 16; j = j + 1) begin
        always @(posedge clk) begin
            if (reset)
                frame[j] <= 0;
            else
                frame[j] <= (j == load_cnt) & (prog_loading) ? data_input : frame[j];
        end
    end
    endgenerate





    reg  [INSTR_SIZE - 1: 0] data_frames [DATA_DEPTH - 1: 0];   // better change type of memory later
    wire [INSTR_SIZE - 1: 0]  cur_frame  [FRAME_SIZE - 1: 0];
    reg  [INSTR_SIZE - 1: 0]      frame  [16         - 1: 0];



    reg  [CORE_NUM   - 1: 0]                    init_r0_vect;    // only new  data, old not considered here
    reg  [CORE_NUM   - 1: 0]                       last_mask;  // cores used by the latest task//
    wire [CORE_NUM   - 1: 0]                       exec_mask;

    reg [ 5: 0]      if_num;
    reg [ 5: 0] next_if_num;
    reg [ 9: 0]   global_tp;   // [3:0] = tp, [9:4] = frame 
    reg [ 1: 0]       fence;   // barrier . will be deleted. Now needed only for easy testing (about wires)
    reg             wait_it;
    
    wire end_prog;
    assign end_prog = (global_tp == 10'h3ff);

    reg no_collision;
    reg rel_stop;
    reg wait_not;
    /// temporal regs for testing

    wire flag1;
    wire flag2;
    wire no_wait_cf;

    wire write_en;
    wire tmp;
    assign tmp      = ((core_reading & last_mask) == last_mask);
    assign write_en = !prog_loading & (((core_reading & last_mask) == last_mask) | last_mask == 0);

    integer k;
    integer j;
   
    genvar a;
    generate
        for (a = 0; a < FRAME_SIZE; a = a + 1)
            assign cur_frame[a] = data_frames[{global_tp[9: 4], 4'h0} + a];

    endgenerate

