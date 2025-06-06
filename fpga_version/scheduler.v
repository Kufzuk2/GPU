
`ifdef ALL
    `include "scheduler/sched_def.v"
`endif    
`ifndef ALL
    `include "sched_def.v"
`endif    


//TODO     send r0 data + core and r0 mask
// move waiting earlier
// remove tp && tp + 1 && tp + 2 at the same time
module scheduler
#(
    parameter     DATA_DEPTH  = 1024,
    parameter   R0_DATA_SIZE  =  128,  
    parameter CTRL_DATA_SIZE  =   48,  
    parameter     INSTR_SIZE  =   16,
    parameter     FRAME_SIZE  =   16,
    parameter      INSTR_NUM  =  288,
    parameter      FRAME_NUM  =   64,
    parameter       CORE_NUM  =   16,
    parameter    BUS_TO_CORE  =   16,
    parameter       R0_DEPTH  =    8
)
    
(
    input  wire clk,
    input  wire reset,
    input  wire [15: 0] core_reading,
    input  wire [CORE_NUM    - 1: 0]   core_ready,  // may be better reverse it

    input  wire  repeat_frame,
    input  wire end_repeating,

    output  reg [BUS_TO_CORE - 1: 0] mess_to_core,  //

    output reg         r0_loading,
    output reg  core_mask_loading,
    output reg    r0_mask_loading,
    output reg      instr_loading
//change for wires where possible
//   input  wire [DATA_DEPTH  - 1: 0][INSTR_SIZE - 1: 0] data_frames_in,
);

	wire [INSTR_SIZE - 1: 0] /*[INSTR_SIZE - 1: 0]*/ data_frames  [INSTR_NUM - 1: 0];   // better change type of memory later
    wire [INSTR_SIZE - 1: 0]  cur_frame  [FRAME_SIZE - 1: 0];


    wire [INSTR_NUM * INSTR_SIZE - 1: 0] line_data;


    load_asm 
    #(
        .INSTR_SIZE ( INSTR_SIZE),
        .INSTR_NUM  ( INSTR_NUM ),
        .FULL_DEPTH ( DATA_DEPTH)
    )
    load_asm
    (
        .clk              (      clk),
        .rst              (    reset),
        .data_frames_line (line_data)
    );
    
    genvar b;
    generate
        for (b = 0; b < INSTR_NUM; b = b + 1) begin: data_line_norm_view
            assign data_frames[b] = line_data[INSTR_SIZE * (b + 1) - 1: INSTR_SIZE * b];
        end
    endgenerate


    wire   prog_loading;
    assign prog_loading = reset;


    reg  [CORE_NUM   - 1: 0]                    init_r0_vect;    // only new  data, old not considered here
    reg  [CORE_NUM   - 1: 0]                       last_mask;  // cores used by the latest task//
    wire [CORE_NUM   - 1: 0]                       exec_mask;

    reg [ 5: 0]      if_num;
    reg [ 5: 0] next_if_num;
    reg [ 9: 0]   global_tp;   // [3:0] = tp, [9:4] = frame 
    reg [ 1: 0]       fence;   // barrier . will be deleted. Now needed only for easy testing (about wires)
    reg             wait_it;
    
    wire end_prog;
    assign end_prog = (global_tp == (INSTR_NUM - 1));

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
        for (a = 0; a < FRAME_SIZE; a = a + 1) begin: data_assign
            assign cur_frame[a] = data_frames[{global_tp[9: 4], 4'h0} + a];
		  end
    endgenerate


    wire [INSTR_SIZE - 1: 0]    last_mask_w;
    wire [             1: 0]        fence_w;
    
    assign last_mask_w    =    cur_frame[1];
    assign fence_w        =   (cur_frame[0]  & `SCHED_FENCE_MASK) >> 6;

    assign flag1 = (((last_mask_w & exec_mask) == 0) | (exec_mask == 0)); 
    assign flag2 =  !((fence_w == `SCHED_FENCE_REL) & exec_mask != 0 );

    assign no_wait_cf     =   flag1 & flag2;
    assign exec_mask      =     ~core_ready;
    


/// fence   reg  logic
    always @(posedge clk) begin
        if (reset)
           fence <= 0;

        else begin
            fence <= (!prog_loading & (if_num == 0) & global_tp[3: 0] == 0) ?
            fence_w  :  fence;        
            `ifdef TR
                $display("fence  ");
            `endif
        end
    end


/// last_mask   reg  logic
    always @(posedge clk) begin
        if (reset)
           last_mask <= 0;

        else
            last_mask <= (!prog_loading & if_num == 0 & global_tp[3: 0] == 0) ?
            last_mask_w : last_mask;
    end



/// init_r0_vect   reg  logic
    always @(posedge clk) begin
        if (reset)
           init_r0_vect <= 0;

        else
            init_r0_vect <= (write_en & if_num == 0 & global_tp[3: 0] == 0) ?
            cur_frame[2] : init_r0_vect;
    end


    // noramal analog with if else if in the end of code
/// mess_to_core    reg  logic
    always @(posedge clk) begin // mb better add if(r0_mask, but easier not too and seems pointless)
        if (reset)
            mess_to_core <= 0;

        else 
            mess_to_core <= !(write_en) | ((if_num == 0) & (global_tp[3: 0] == 0))                     ? 
            mess_to_core                                                                               :

            ((if_num == 0 & global_tp[3: 0] != 1 & global_tp[3: 0] != 2) | if_num != 0)                ?
            cur_frame[global_tp[3: 0]]                                                                 :
            
            (if_num == 0 & global_tp[3: 0] == 1)                                                       ?
            last_mask                                                                                  : 
            init_r0_vect                                                                               ;
    end

    
    `ifdef REG_D
    always @(posedge clk) begin
        if (!prog_loading & global_tp != 10'h40 ) begin
            $display("******************************************************************** ");
            $display("fence        = %h , if_num    = %h ", fence, if_num);
            $display("last_mask    = %h , exec_mask = %h ", last_mask, exec_mask);
            $display("init_r0_vect = %h , global_tp = %h ", init_r0_vect, global_tp);
            $display("cur_frame[0] = %h ", cur_frame[0]);
            $display("******************************************************************** ");
        end
    end // must work as for r0 load as for instr mes
    `endif

    
    `ifdef CUR_FR_D
      
    always @(posedge clk) begin

        if (!prog_loading & (global_tp[3: 0] == 4'h0) & global_tp != 10'h40) begin

            $display("============================================================================ ");
            for (integer n = 0; n < 16; n = n + 1) begin
                $display("cur_frame[%d] = %h , must_be data_frames[%h]  %h", n, cur_frame[n], {global_tp[9: 4], 4'd0} + n, data_frames[{global_tp[9: 4], 4'd0} + n]);
                $display("global_tp[9: 4] = %h, %h, %d , data_frames[%d] = %h", global_tp[9: 4], 4'h0, n, global_tp + n, data_frames[global_tp + n]);
            end

            $display("============================================================================ ");
        end 
    `endif





//r0_loading flag reg logic
    
    always @(posedge clk) begin
        if (reset)
            r0_loading <= 0;
        else
            r0_loading <= (write_en &   if_num == 0 & 
                            global_tp[3: 0] != 0 & global_tp[3: 0] != 1 & 
                            global_tp[3: 0] != 2)                       ?
            1: 0;
    end    


//////////////////////////////////
    //instr_loading flag reg logic
    wire   val_ins_end;
    reg    val_ins_end_ff;

    assign val_ins_end = (if_frame_end && !if_end_no_wait);

    
    always @(posedge clk) begin
        if (reset)
            val_ins_end_ff <= 0;
        else
            val_ins_end_ff <= val_ins_end;
    end

    
    always @(posedge clk) begin
        if (reset)
            instr_loading <= 0;
        else
            instr_loading <= (write_en & if_num != 0) && (!val_ins_end_ff || !val_ins_end) ?   // || ifnum[] == 0??????
            1: 0;
    end    
// instr_loading <= (write_en & if_num != 0) ? 1: 0;
// assign write_en = !prog_loading & (((core_reading & last_mask) == last_mask) | last_mask == 0);



//r0_mask_loading flag reg logic
    
    always @(posedge clk) begin
        if (reset)
            r0_mask_loading <= 0;
        else
            r0_mask_loading <= (write_en & if_num == 0 & 
                                global_tp[3: 0] == 2)  ?
                                                   1: 0;
    end    
        
//core_mask_loading flag reg logic
    
    always @(posedge clk) begin
        if (reset)
            core_mask_loading <= 0;
        else
            core_mask_loading <= (write_en & if_num == 0 & 
                                  global_tp[3: 0] == 1)  ?
                                                     1: 0;
    end    
    


wire   if_frame_end;
reg    if_end_no_wait_ff;
assign if_frame_end   = (if_num == 1) && (global_tp[3: 0] == 4'hf);

always @(posedge clk) begin
    if (reset)
        if_end_no_wait_ff <= 0;
    else 
        if_end_no_wait_ff <= if_end_no_wait;
end


wire   core_collision;
wire         cf_start;

assign core_collision = (last_mask & exec_mask != 0);

assign cf_start       = (if_num == 0) && (global_tp[3: 0] ==    0);

/// global_tp  reg  logic
    always @(posedge clk) begin
        if (reset)
           global_tp <= 0;
        
        else if ((write_en) & if_num == 0 & global_tp[3: 0] == 2)
            global_tp <= global_tp + 10'h6;  //step over empty space
        
        else if (~end_prog & write_en & (if_num != 0 | global_tp[3: 0] != 2)

                 &&   !(if_frame_end && wait_it       && core_collision )
                 && ( !(if_frame_end && repeat_fence) || finish_needed  )   /// new line to be checked
                 &&  
                 (cf_start     && no_wait_cf 
                 ||  if_num != 0 
                 ||  global_tp[3: 0] != 0 )) 

            global_tp <= global_tp + `SCHED_MSG_BUS_WIDTH; // step over 1 msg

        else if (!prog_loading && if_frame_end && repeat_fence && repeat_en)
            global_tp <= global_tp - 4'hf;
        else 
            global_tp <= global_tp;
    end // must work as for r0 load as for instr mes



wire   if_end_no_wait;
assign if_end_no_wait = (!(wait_it & core_collision) && (!(if_frame_end && repeat_fence) || finish_needed) );


/// if_num  reg  logic
    always @(posedge clk) begin
        if (reset) begin
           if_num <= 0;

        end else if (!prog_loading & if_num != 0 
                      & global_tp[3: 0] == 4'b1111 
                      & (if_num != 1 || if_end_no_wait)) begin  // must be 0000, but not enough time then
            if_num <= if_num - 1;

        end else if (!prog_loading & if_num == 0 & global_tp[3: 0] == 4'b1111)
            if_num <= next_if_num;

        else
            if_num <= if_num;
    end



/// next_if_num  reg  logic
    always @(posedge clk) begin
        if (reset) 
           next_if_num <= 0;

        else
            next_if_num <= (!prog_loading & if_num == 0 & global_tp[3: 0] == 0) ?
            cur_frame[0] & `SCHED_IFNUM_MASK                                    :
            next_if_num                                                         ;
    end



//////////////////////////////
///  repeat/wait controll  ///
//////////////////////////////

    reg        wait_repeat;
    reg      repeat_needed;
    wire fence_load_moment;
    wire      repeat_fence;
    wire         repeat_en;

    assign fence_load_moment = (if_num == 0) && (global_tp[3: 0] == 1);
    assign repeat_fence      = (fence == 1`SCHED_FENCE_REPEAT);

assign repeat_en = !prog_loading && if_frame_end && repeat_needed && !(last_mask & exec_mask != 0);

    always @(posedge clk) begin
        if (reset)
            wait_repeat <= 0;
            
        else if (!prog_loading && fence_load_moment && repeat_fence)
            wait_repeat <= 1;

        else if (repeat_en)
            wait_repeat <= 0;

        else
            wait_repeat <= wait_repeat;
    end


    always @(posedge clk) begin
        if (reset)
            repeat_needed <= 0;

        else if (!prog_loading && repeat_frame)
            repeat_needed <= 1;

        else if (repeat_en)
            repeat_needed <= 0;

        else
            repeat_needed <= repeat_needed;
    end

/// finish of repea logic

reg finish_needed;

    always @(posedge clk) begin
        if (reset)
            finish_needed <= 0;

        else if (!prog_loading && end_repeating)
            finish_needed <= 1;

        else if (!prog_loading &&if_frame_end)
            finish_needed <= 0;

        else
            finish_needed <= finish_needed;
    end


///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////



    /// wait_it   reg  logic
    always @(posedge clk) begin
        if (reset)        
           wait_it <= 0;
                    
        else if (!prog_loading & if_num == 0 & global_tp[3: 0] == 1 &
            (fence == `SCHED_FENCE_ACQ)) // may be better delete it
            wait_it <= 1;

        else if (if_num == 0 & global_tp[3:0] == 0)
            wait_it <= 0;
        else
            wait_it <= wait_it;
    end

/*
    /// data_frames   reg  logic
    always @(posedge clk) begin
        if (prog_loading) begin
            for (j = 0; j < DATA_DEPTH; j++) begin
                data_frames[j] <= data_frames_in[j];

            end
        end
    end
*/

            `ifdef DATA_IN

    always @( negedge prog_loading) begin
            for (integer p = 0; p < DATA_DEPTH; p++) begin
                $display("data_frames[%d]    = %h", p, data_frames[p]);
                $display("data_frames_in[%d] = %h", p, data_frames_in[p]);
            end
    end

                `endif 




    endmodule

