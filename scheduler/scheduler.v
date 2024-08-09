`include "gpu_def.v"

`define SCHED_FENCE (data_frames[global_tp] & 16'b0000000011000000) >> 6

`define WAITING (((data_frames[global_tp + 1] & exec_mask) != 16'h0) || wait_it || \
                ((data_frames[global_tp    ] & `SCHED_FENCE_MASK) >> 6 == `SCHED_FENCE_REL  && exec_mask)) 

//TODO     send r0 data + core and r0 mask
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
    reg [INSTR_SIZE - 1: 0] data_frames2 [DATA_DEPTH - 1: 0];   // better change type of memory later

    reg [CORE_NUM   - 1: 0]                      exec_mask;
    reg [CORE_NUM   - 1: 0]                      last_mask;  // cores used by the latest task
    wire [CORE_NUM   - 1: 0]                    exec_mask2;

    reg [ 5: 0]    if_num;
    reg [ 9: 0] global_tp;   // [3:0] = tp, [9:4] = frame
    reg [ 1: 0]     fence;   // barrier . will be deleted. Now needed only for easy testing
    reg           wait_it;

    integer i; // chacnge for a smaller reg???
    integer k;
    integer j;


    assign exec_mask2 = ~core_ready;


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

        for (j = 0; j < DATA_DEPTH; j++) begin
            data_frames2[j] <= data_frames_in[j];
        end


        if (!prog_loading) begin
            exec_mask <= (~core_ready) & exec_mask; // will be deleted

            if (if_num == 0) begin
                
                if (!(`WAITING)) begin
                    fence        <= (data_frames[global_tp    ] & `SCHED_FENCE_MASK) >> 6;
                    if_num       <=  data_frames[global_tp    ] & `SCHED_IFNUM_MASK; 
                    init_r0_vect <=  data_frames[global_tp + 2];
                    last_mask    <=  data_frames[global_tp + 1];


                    for (i = 0; i < 16; i = i + 1) begin
                        if (init_r0_vect[i])
                            r0_data[i] <= data_frames[global_tp + i + 16]; //change for wires. works strange
                    end

                    exec_mask <= exec_mask | data_frames[global_tp + 1]; // to be deleted 

                    if ((data_frames[global_tp] & `SCHED_FENCE_MASK) >> 6 == `SCHED_FENCE_ACQ) begin
                        wait_it <= 1;
                    end

                    global_tp <= global_tp + 10'h10;  
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









