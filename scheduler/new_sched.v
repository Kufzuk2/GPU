
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
    parameter     FRAME_SIZE  =  256,
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
    
    wire [FRAME_SIZE      - 1: 0]  cur_frame;
    wire [R0_DATA_SIZE   - 1: 0]  cur_r0_data;
    wire [CTRL_DATA_SIZE - 1: 0]  cur_ctrl_data;
/*
    reg [INSTR_SIZE     - 1: 0]  cur_frame1;
    reg [R0_DATA_SIZE   - 1: 0]  cur_r0_data1;
    reg [CTRL_DATA_SIZE - 1: 0]  cur_ctrl_data1;
*/


    reg [CORE_NUM    - 1: 0]                  init_r0_vect;    // only new  data, old not considered here
    reg [CORE_NUM   - 1: 0]                      last_mask;  // cores used by the latest task//
    wire [CORE_NUM   - 1: 0]                     exec_mask;

    reg [ 5: 0]      if_num;//
    reg [ 5: 0] next_if_num;//
    reg [ 9: 0]   global_tp;   // [3:0] = tp, [9:4] = frame //
    reg [ 1: 0]       fence;   // barrier . will be deleted. Now needed only for easy testing
    reg             wait_it;//

    reg no_collision;
    reg rel_stop;
    reg wait_not;
    reg cf;
    /// temporal regs for testing

    wire flag1;
    wire flag2;
    wire no_wait_cf;

    integer k;
    integer j;


    assign cur_frame     = data_frames[global_tp];  //не слишком ли много бесполезных проводов будет? 
/*
    assign cur_frame     = data_frames[global_tp + FRAME_SIZE - 1: global_tp];  //не слишком ли много бесполезных проводов будет? 
                                                                                //или логическим выражением сделать так, чтобы это работало только при CF???
  */  
    
   
    wire [INSTR_SIZE - 1: 0] ctrl_data [                 2: 0]; 
    wire [INSTR_SIZE - 1: 0]   r0_data [INSTR_SIZE / 2 - 1: 0]; 

    reg [INSTR_SIZE - 1: 0] ctrl_data1 [                 2: 0]; 
    reg [INSTR_SIZE - 1: 0]   r0_data1 [INSTR_SIZE / 2 - 1: 0]; 

    genvar a;
    generate
        for (a = 0; a < 3; a = a + 1) begin
            assign ctrl_data[a] = data_frames[global_tp + a];
        end
        
        for (a = 0; a < 8; a = a + 1) begin
            assign r0_data[a] = data_frames[global_tp + a + 8];
        end
    endgenerate

/*
    assign cur_r0_data   =  cur_frames [10: 11 - INSTR_SIZE / 2];
    assign cur_ctrl_data =  cur_frames [2: 0];
*/

    wire [INSTR_SIZE - 1: 0] last_mask_w;
    wire [             1: 0] fence_w;
    
    assign last_mask_w  =  ctrl_data[1];
    assign fence_w      = (ctrl_data[0] & `SCHED_FENCE_MASK) >> 6;



    // rewrire with wires only
    assign flag1 = ((last_mask & exec_mask == 0) || (exec_mask == 0)); 
    assign flag2     = !((fence == `SCHED_FENCE_REL) && exec_mask);

    assign no_wait_cf = flag1 & flag2;
    assign exec_mask = ~core_ready;
    


/// fence   reg  logic
    always @(posedge clk) begin
        if (reset)
           fence <= 0;

        else if (!prog_loading && if_num == 0 && global_tp[3: 0] == 4'h0)
            fence <= fence_w;
        else 
            fence <= fence;
    end

/// last_mask   reg  logic
    always @(posedge clk) begin
        if (reset)
           last_mask <= 0;

        else if (!prog_loading && if_num == 0 && global_tp[3: 0] == 0)  
            last_mask <= last_mask_w;
        else 
            last_mask <= last_mask;
    end



/// init_r0_vect   reg  logic
    always @(posedge clk) begin
        if (reset)
           init_r0_vect <= 0;

        else if (!prog_loading && if_num == 0 && global_tp[3: 0] == 0 && core_reading)  
            init_r0_vect <= ctrl_data[2];
        
        else 
            init_r0_vect <= init_r0_vect;
    end




/// mess_to_core    reg  logic
    always @(posedge clk) begin
        if (reset)
            mess_to_core <= 0;

        else if (!prog_loading && core_reading && if_num == 0 && global_tp[3: 0] == 1) // also was !waiting, but i suppose its useless here

            mess_to_core[15: 0] <= last_mask;

        else if (!prog_loading && core_reading && if_num == 0 && 
                      global_tp[3: 0] == 2) 
            mess_to_core[15: 0] <= init_r0_vect;
        

        else if (!prog_loading && core_reading /*&& if_num == 0*/ 
                && ((global_tp[3: 0] > 4'h2 && if_num == 0) || if_num != 0))
                    mess_to_core[15: 0] <= r0_data[global_tp[3: 0]]; 
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
        
        else if ((!prog_loading) && if_num == 0 && global_tp[3: 0] == 2 && core_reading &&
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
                      /*core_reading &&*/ global_tp[3: 0] == 4'b1111 
                      && (if_num != 1  || !(wait_it && (last_mask & exec_mask != 0)))) begin  // must be 0000, but not enough time then
            if_num <= if_num - 1;

        end else if (!prog_loading && if_num == 0 && global_tp[3: 0] == 4'b1111)
            if_num <= next_if_num;

        else
            if_num <= if_num;
    end



/// next_if_num  reg  logic
    always @(posedge clk) begin
        if (reset) begin
           next_if_num <= 0;
        
       end else if (!prog_loading && if_num == 0 && global_tp[3: 0] == 0)
            next_if_num <= ctrl_data[0] & `SCHED_IFNUM_MASK;

        else
            next_if_num <= next_if_num;
    end

    /// cf reg logic
    always @(posedge clk) begin
        if (reset) begin
           cf <= 1;

        end else if (!prog_loading && if_num == 0 && 
                      core_reading && global_tp[3: 0] == 4'b1111 
                      && !(wait_it && (last_mask & exec_mask != 0))) begin  // must be 0000, but not enough time then
            cf <= 1;

        end else if (!prog_loading && if_num == 1  
                                   && global_tp[3: 0] == 4'b1111) begin
            cf <= 0;
        end else
            cf <= cf;
        end

    /// wait_it   reg  logic
    always @(posedge clk) begin
        if (reset)        
           wait_it <= 0;
                    
        else if (!prog_loading && if_num == 0 && global_tp == 1 &&
            (fence == `SCHED_FENCE_ACQ)) // may be better delete it
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









