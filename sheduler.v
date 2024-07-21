`define frame global_tp[9: 4]

module sheduler

// Resolution and refresh rate  

#(
    
)
    //reploace all the magic numbers by parameters
(
    input wire clk, 
    input wire data_frames_in [1023: 0][15: 0]  // same as lower
);

    reg   data_frames    [1023: 0][15: 0];   // better change type of memory later
//    reg [63: 0] data_frames [15: 0][15: 0];   // one big more than many small
//    ones


    // continious instructions
   
    // reg [  63: 0] data_frames [255: 0]; 
    // one frame for 16 instructions
                                        //// ??????????????
                                        //    how to divide into frames
    reg [ 3: 0]     tp = 4'b0;   // task pointer
    reg [ 5: 0] if_num = 6'b0;
//    reg [ 5: 0]  frame = 6'b0;   // frame pointer

    
    reg [ 1: 0]         fence;   // barrier
    reg [ 9: 0]     global_tp;   // [3:0] = tp, [9:4] = frame
    reg [15: 0]     exec_mask;   // 1 -> 0 if the core is ready
    reg [15: 0]  init_r0_vect;
    reg [31: 0]  mess_to_core;

    always @(posedge clk) begin
        data_frames <= data_frames_in;
        cores cores (); // exec_mask, r0, mess_to_core, core_read_f
                            // must change exec mask

        if (if_num == 0) begin
            // initially must be CF
            
            // consider fence as if it works only if it is considered only during
            // start of frame exec
            fence        <= data_frames[frame * 256 + 0][ 7: 6];
            if_num       <= data_frames[frame * 256 + 0][ 5: 0]; 
            exec_mask    <= data_frames[frame * 256 + 1][15: 0];
            init_r0_vect <= data_frames[frame * 256 + 2][15: 0]; // ?? better send it straigtly

            // next write or transmit registers data
            frame <= frame + 1;
        else if (core_read_f == 1) begin

            mess_to_core[15:  0] <= data_frames[global_tp    ];
            mess_to_core[31: 16] <= data_frames[global_tp + 1]; //delete it, just change gp

            global_tp <= global_tp + 2; 
            if_num    <= if_num    - 1;

                //instr exec
        end // end of if

endmodule
