`define FENCE_ACQ   2'h1 
`define FENCE_REL   2'h2 
`define FENCE_MASK 16'b0000000011000000 
`define FENCE_MASK 16'b0000000011000000 
`define IFNUM_MASK 16'b0000000000111111
`define FENCE (data_frames[global_tp] & 16'b0000000011000000) >> 6

module scheduler
#(
    parameter  DATA_DEPTH = 1024,
    parameter  INSTR_SIZE =   16,
    parameter  FRAME_SIZE =   16,
    parameter    CORE_NUM =   16,
    parameter BUS_TO_CORE =   32,
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
    
    output  reg [CORE_NUM    - 1: 0]                      init_r0_vect,  // only new  data, old not considered here
    output  reg [BUS_TO_CORE - 1: 0]                      mess_to_core,

    output  reg [15: 0]        tmp_mess_to_core,
    output  reg [ 7: 0][15: 0]          r0_data
//change for wires where possible
);

    reg [DATA_DEPTH - 1: 0][INSTR_SIZE - 1: 0] data_frames;   // better change type of memory later
    reg [CORE_NUM   - 1: 0]                      exec_mask;
    reg [CORE_NUM   - 1: 0]                      last_mask;  // cores used by the latest task

    reg [ 5: 0]    if_num;
    reg [ 9: 0] global_tp;   // [3:0] = tp, [9:4] = frame
    reg [ 1: 0]     fence;   // barrier
    wire          waiting;
    reg           wait_it;

    integer i;
    integer k;


/*
    //fence
    always @(posedge clk) begin //if_num == 0
        if (fence == 0) begin
            waiting <= (exec_mask & data_frames[global_tp + 1]) == 0 ? 0 : 1;

        end else if (fence == 2'h1) begin
            waiting <= (exec_mask & last_mask) == 0 ? 0 : 1;

        end else if (fence == 2'h2) begin
            waiting <= (exec_mask == 0) ? 0 : 1;
        end // else will mean to save previous cond or better -> 0
    end
*/

//    assign fence0  = exec_mask & data_frames[global_tp + 1] != 0;
    assign fence2  = (data_frames[global_tp] & `FENCE_MASK) == 2'h2 && !exec_mask;
    assign waiting = wait_it || fence2;

//    assign waiting = (!if_num && ( !(exec_mask & data_frames[global_tp + 1]) || (wait_it && exec_mask & last_mask) || ((data_frames[global_tp] & `FENCE_MASK == 2'h2) && exec_mask == 0) )  ) ? 0: 1;
    
    always @(posedge clk) begin
        if (!(last_mask & exec_mask)) begin
            wait_it <= 0;
        end
    end

    always @(posedge clk) begin

        if (reset) begin
           if_num    <= 0;
           global_tp <= 0;
           exec_mask <= 0;
           wait_it   <= 0;
        end else begin 
        

        data_frames <= data_frames_in;
            
        if (!prog_loading) begin
            exec_mask <= (~core_ready) & exec_mask;

            if (if_num == 0) begin
                

                if (!(((data_frames[global_tp + 1] & exec_mask) != 16'h0) || wait_it ||   // need macros
                      ((data_frames[global_tp    ] & `FENCE_MASK) >> 6 == `FENCE_REL  && exec_mask)
                    )) begin 
                    fence        <= (data_frames[global_tp    ] & `FENCE_MASK) >> 6;
                    if_num       <=  data_frames[global_tp    ] & `IFNUM_MASK; 
                    init_r0_vect <=  data_frames[global_tp + 2];
                    last_mask    <=  data_frames[global_tp + 1];


                    for (i = 0; i < 16; i = i + 1) begin
                        if (init_r0_vect[i])
                            r0_data[i] <= data_frames[global_tp + i + 16]; //change for wires. works strange
                    end

                    exec_mask <= exec_mask | data_frames[global_tp + 1]; 

                    if ((data_frames[global_tp] & `FENCE_MASK) >> 6 == `FENCE_ACQ) begin
                        wait_it <= 1;
                    end

                    global_tp <= global_tp + 10'h10;   // === global tp += 10'd16
                end 

            end else if (core_reading) begin

                /*
                mess_to_core[15:  0] <= data_frames[global_tp    ];
                mess_to_core[31: 16] <= data_frames[global_tp + 1]; //delete it, just change gp
                global_tp <= global_tp + 2; 
                */ // return later, temporally changed
                
                tmp_mess_to_core[15:  0] <= data_frames[global_tp];
                global_tp <= global_tp + 1; 

                if (global_tp[3: 0] == 4'b1111) begin  // must be 0000, but not enough time then
                    if_num <= if_num - 1;
                end

            end // end of if
        end // prog loading
        end // of reset    
    end // for always
endmodule
