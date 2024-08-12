
`include "gpu_def.v"
`include "sched_func.v"

`define SCHED_FENCE (data_frames[global_tp] & 16'b0000000011000000) >> 6

`define WAITING (((data_frames[global_tp + 1] & exec_mask) != 16'h0) || wait_it || \
                ((data_frames[global_tp    ] & `SCHED_FENCE_MASK) >> 6 == `SCHED_FENCE_REL  && exec_mask)) 

//TODO     send r0 data + core and r0 mask
// move waiting earlier
// remove tp && tp + 1 && tp + 2 at the same time
module new_sched
#(
    parameter  DATA_DEPTH = 1024,
    parameter  INSTR_SIZE =   16,
    parameter  FRAME_SIZE =   16,
    parameter    CORE_NUM =   16,
    parameter BUS_TO_CORE =   16,
    parameter    R0_DEPTH =    8
)
// Resolution and refresh rate  
    
    //reploace all the magic numbers by parameters
(
    input  wire clk,
    input  wire reset,
    input  wire core_reading,
    input  wire prog_loading,
    output wire frame_being_sent,
    input  wire [DATA_DEPTH  - 1: 0][INSTR_SIZE - 1: 0] data_frames_in,
    input  wire [CORE_NUM    - 1: 0]                        core_ready,  // may be better reverse it
    
    output  reg [BUS_TO_CORE - 1: 0]                      mess_to_core  //

//change for wires where possible
);

    reg [INSTR_SIZE - 1: 0] data_frames [DATA_DEPTH - 1: 0];   // better change type of memory later

    reg [CORE_NUM    - 1: 0]                  init_r0_vect;    // only new  data, old not considered here
//    reg [CORE_NUM   - 1: 0]                      exec_mask;//
    reg [CORE_NUM   - 1: 0]                      last_mask;  // cores used by the latest task//
    wire [CORE_NUM   - 1: 0]                     exec_mask;

    reg [ 5: 0]    if_num;//
    reg [ 9: 0] global_tp;   // [3:0] = tp, [9:4] = frame //
    reg [ 1: 0]     fence;   // barrier . will be deleted. Now needed only for easy testing
    reg           wait_it;//
    reg         r0_loaded;

    integer k;
    integer j;


    assign exec_mask = ~core_ready;

    sched_funcs sched_funcs();
    

/// fence   reg  logic
    always @(posedge clk) begin
        if (reset)
           fence <= 0;

        else if (!prog_loading && if_num == 0 && global_tp[3: 0] == 4'h0)
            fence <= (data_frames[global_tp] & `SCHED_FENCE_MASK) >> 6;
    end

/// last_mask   reg  logic
    always @(posedge clk) begin
        if (reset)
           last_mask <= 0;

        else if (!prog_loading && if_num == 0 && global_tp[3: 0] == 1)  
            last_mask <= data_frames[global_tp];
    end



/// init_r0_vect   reg  logic
    always @(posedge clk) begin
        if (reset)
           init_r0_vect <= 0;

        else if (!prog_loading && if_num == 0 && global_tp[3: 0] == 2 && core_reading)  
            init_r0_vect <= data_frames[global_tp];
    end




/// mess_to_core    reg  logic
    always @(posedge clk) begin
        if (reset)
            mess_to_core <= 0;

        else if (!prog_loading && core_reading && if_num != 0) begin // also was !waiting, but i suppose its useless here

            mess_to_core[15: 0] <= data_frames[global_tp];

        end else if (!prog_loading && core_reading && if_num == 0 && 
                      global_tp[3: 0] == 2) 
            mess_to_core[15: 0] <= data_frames[global_tp];

        else if (!prog_loading && core_reading /*&& if_num == 0*/ 
                && ((global_tp[3: 0] > 4'h2 && if_num == 0) || if_num != 0))
                    mess_to_core[15: 0] <= data_frames[global_tp]; 
    end
    
// seems may be deleted
    /// r0_loaded reg logic
    always @(posedge clk) begin
        if (reset)
            r0_loaded <= 0;
        else if (!prog_loading && if_num == 0 && global_tp[3: 0] == 4'b1111)
            r0_loaded <= 1;

        else if (!prog_loading && global_tp[3: 0] == 4'b1111 && if_num == 1)  // must be enough condition. must be checked
            r0_loaded <= 0;
    end



/// global_tp  reg  logic
    always @(posedge clk) begin
        if (reset)
           global_tp <= 0;
        
        else if ((!prog_loading) && (if_num == 0) && global_tp[3: 0] == 2 && (core_reading /*|| global_tp[3: 0] < 8)*/  ) ) //gtp == 2 => jump to 16   // AB + ~B  == A + ~B
            global_tp <= global_tp + 10'h6;  //step over empty space
        
        else if (!prog_loading && core_reading)
            global_tp <= global_tp + `SCHED_MSG_BUS_WIDTH; // step over 1 msg
    end // must work as for r0 load as for instr mes


/// if_num  reg  logic
    always @(posedge clk) begin
        if (reset) begin
           if_num <= 0;

        end else if (!prog_loading && if_num && 
                      core_reading && global_tp[3: 0] == 4'b1111) begin  // must be 0000, but not enough time then
            if_num <= if_num - 1;

        end else if (!prog_loading && if_num == 0  
                                   && global_tp[3: 0] == 4'b1111) begin
            if_num <= data_frames[global_tp - 10'hf] & `SCHED_IFNUM_MASK; 
        end
    end

/*
    /// exec_mask   reg  logic
    always @(posedge clk) begin
        if (reset)        
           exec_mask <= 0;
                    
        else if (!prog_loading) begin
            exec_mask <= (~core_ready) & exec_mask; // will be deleted
            if (if_num == 0)            
                exec_mask <= exec_mask | data_frames[global_tp + 1]; // to be deleted 
        end
    end  /// may be easily changed for exec_mask2  
*/


    /// wait_it   reg  logic
    always @(posedge clk) begin
        if (reset)        
           wait_it <= 0;
                    
        else if (!prog_loading && if_num == 0 && global_tp == 1 &&
            (fence == `SCHED_FENCE_ACQ))
            wait_it <= 1;

        else if (global_tp[3:0] > 1 && (last_mask & exec_mask == 0))
            wait_it <= 0;
    end


    /// data_frames   reg  logic
    always @(posedge clk) begin
        if (prog_loading) begin
            for (j = 0; j < DATA_DEPTH; j++) begin
                data_frames[j] <= data_frames_in[j];
            end
        end
    end

        
    reg func_wait;
    always @(posedge clk) begin
        if (reset)
            func_wait <= 0;
        else 
            func_wait <= sched_funcs.waiting(fence, last_mask, exec_mask, wait_it);
    end


    endmodule










