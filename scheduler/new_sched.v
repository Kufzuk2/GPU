
`include "../gpu_def.v"

//TODO     send r0 data + core and r0 mask
// move waiting earlier
// remove tp && tp + 1 && tp + 2 at the same time
module new_sched
#(
    parameter     DATA_DEPTH  = 1024,
    parameter   R0_DATA_SIZE  =  128,  
    parameter CTRL_DATA_SIZE  =   48,  
    parameter     INSTR_SIZE  =   16,
    parameter     FRAME_SIZE  =   16,
    parameter      FRAME_NUM  =   64,
    parameter       CORE_NUM  =   16,
    parameter    BUS_TO_CORE  =   16,
    parameter       R0_DEPTH  =    8
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
    
    output  reg [BUS_TO_CORE - 1: 0]                      mess_to_core,  //

    output reg         r0_loading,
    output reg         if_loading,
    output reg  core_mask_loading,
    output reg    r0_mask_loading
//change for wires where possible
);

    reg [INSTR_SIZE - 1: 0] data_frames [DATA_DEPTH - 1: 0];   // better change type of memory later
    
    wire [FRAME_NUM      - 1: 0]  cur_frame;
    wire [R0_DATA_SIZE   - 1: 0]  cur_r0_data;
    wire [CTRL_DATA_SIZE - 1: 0]  cur_ctrl_data;

    reg [FRAME_NUM      - 1: 0]  cur_frame1;
    reg [R0_DATA_SIZE   - 1: 0]  cur_r0_data1;
    reg [CTRL_DATA_SIZE - 1: 0]  cur_ctrl_data1;


    always @(posedge clk) begin
    cur_frame1 <= cur_frame;
    cur_r0_data1 <= cur_r0_data;    
    cur_ctrl_data1 <= cur_ctrl_data;    



    end



    assign cur_frame     = data_frames[global_tp];
    assign cur_r0_data   =  cur_frame [global_tp];
    assign cur_ctrl_data =  cur_frame [global_tp];


    reg [CORE_NUM    - 1: 0]                  init_r0_vect;    // only new  data, old not considered here
    reg [CORE_NUM   - 1: 0]                      last_mask;  // cores used by the latest task//
    wire [CORE_NUM   - 1: 0]                     exec_mask;

    reg [ 5: 0]    if_num;//
    reg [ 9: 0] global_tp;   // [3:0] = tp, [9:4] = frame //
    reg [ 1: 0]     fence;   // barrier . will be deleted. Now needed only for easy testing
    reg           wait_it;//

    reg no_collision;
    reg rel_stop;
    reg wait_not;
    /// temporal regs for testing


    wire flag1;
    wire flag2;
    wire no_wait_cf;

    integer k;
    integer j;

    assign flag1 = ((last_mask & exec_mask == 0) || (exec_mask == 0)); 
    assign flag2     = !((fence == `SCHED_FENCE_REL) && exec_mask);

    assign no_wait_cf = flag1 & flag2;

    assign exec_mask = ~core_ready;

    

/// fence   reg  logic
    always @(posedge clk) begin
        if (reset)
           fence <= 0;

        else if (!prog_loading && if_num == 0 && global_tp[3: 0] == 4'h0)
            fence <= (data_frames[global_tp] & `SCHED_FENCE_MASK) >> 6;
        else 
            fence <= fence;
    end

/// last_mask   reg  logic
    always @(posedge clk) begin
        if (reset)
           last_mask <= 0;

        else if (!prog_loading && if_num == 0 && global_tp[3: 0] == 1)  
            last_mask <= data_frames[global_tp];
        else 
            last_mask <= last_mask;
    end



/// init_r0_vect   reg  logic
    always @(posedge clk) begin
        if (reset)
           init_r0_vect <= 0;

        else if (!prog_loading && if_num == 0 && global_tp[3: 0] == 2 && core_reading)  
            init_r0_vect <= data_frames[global_tp];
        
        else 
            init_r0_vect <= init_r0_vect;
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
        else 
            mess_to_core <= mess_to_core;
    end
    
/*
    /// r0_loading reg logic
    always @(posedge clk) begin
        if (reset)
            r0_loading <= 0;
        else if (!prog_loading && if_num == 0 && global_tp[3: 0] == 2)
            r0_loading <= 1;

        else if (!prog_loading && global_tp[3: 0] == 4'b1111 && if_num == 0)  // must be enough condition. must be checked
            r0_loading <= 0;
        else
            r0_loading <= r0_loading;
    end

    
    /// if_loading reg logic
    always @(posedge clk) begin
        if (reset)
            if_loading <= 0;
        else if (!prog_loading && if_num == 0 && global_tp[3: 0] == 4'b1111)
            if_loading <= 1;

        else if (!prog_loading && global_tp[3: 0] == 4'b1111 && if_num == 1)  // must be enough condition. must be checked
            if_loading <= 1;
        else
            if_loading <= if_loading;
    end

    /// mask1_loading reg logic
    always @(posedge clk) begin
        if (reset)
            core_mask_loading <= 0;
        else if (!prog_loading && if_num == 0 && global_tp[3: 0] == 4'b1111)
            core_mask_loading <= 1;

        else if (!prog_loading && global_tp[3: 0] == 4'b1111 && if_num == 1)  // must be enough condition. must be checked
            core_mask_loading <= 1;
        else
            core_mask_loading <= if_loading;
    end

    /// mask_loading

*/


    always @(posedge clk) begin
        if (reset) begin
           no_collision <= 0;
           rel_stop     <= 0;

           end else begin
            no_collision  <= ((last_mask & exec_mask == 0) || (exec_mask == 0));
            rel_stop      <= !((fence == `SCHED_FENCE_REL) && exec_mask);
            end
        end

    always @(posedge clk) begin
        if (reset) begin
           wait_not <= 1;
           end else if (if_num == 0 && global_tp[3: 0] == 1) begin
               wait_not <= no_wait_cf;
           end else if (if_num == 0 && global_tp[3: 0] == 2) begin
               wait_not <= 1;
            end
        end

/// global_tp  reg  logic
    always @(posedge clk) begin
        if (reset)
           global_tp <= 0;
        
        else if ((!prog_loading) && (if_num == 0) && global_tp[3: 0] == 2 && core_reading &&
           /* ((last_mask & exec_mask == 0) || (exec_mask == 0)) && !((fence == `SCHED_FENCE_REL) && exec_mask)) */
           no_wait_cf)
            //gtp == 2 => jump to 16   // AB + ~B  == A + ~B
            //last mask here works as current

            global_tp <= global_tp + 10'h6;  //step over empty space
        
        else if (!prog_loading && core_reading && (if_num != 0 || global_tp[3: 0] != 2)
                 && !(if_num == 1 && global_tp[3: 0] == 4'hf && wait_it && (last_mask & exec_mask != 0))) 
            global_tp <= global_tp + `SCHED_MSG_BUS_WIDTH; // step over 1 msg

        else 
            global_tp <= global_tp;
    end // must work as for r0 load as for instr mes


/// if_num  reg  logic
    always @(posedge clk) begin
        if (reset) begin
           if_num <= 0;

        end else if (!prog_loading && if_num && 
                      core_reading && global_tp[3: 0] == 4'b1111 
                      && (if_num != 1  || !(wait_it && (last_mask & exec_mask != 0)))) begin  // must be 0000, but not enough time then
            if_num <= if_num - 1;

        end else if (!prog_loading && if_num == 0  
                                   && global_tp[3: 0] == 4'b1111) begin
            if_num <= data_frames[global_tp - 10'hf] & `SCHED_IFNUM_MASK; 
        end else
            if_num <= if_num;
    end


    /// wait_it   reg  logic
    always @(posedge clk) begin
        if (reset)        
           wait_it <= 0;
                    
        else if (!prog_loading && if_num == 0 && global_tp == 1 &&
            (fence == `SCHED_FENCE_ACQ))
            wait_it <= 1;

        else if (if_num == 0 && global_tp[3:0] == 0)
            wait_it <= 0;
        else
            wait_it <= wait_it;
    end


    /// data_frames   reg  logic
    always @(posedge clk) begin
        if (prog_loading) begin
            for (j = 0; j < DATA_DEPTH; j++) begin
                data_frames[j] <= data_frames_in[j];
            end
        end
    end



    endmodule










