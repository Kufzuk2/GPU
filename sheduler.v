`define frame global_tp[9: 4]

module sheduler

// Resolution and refresh rate  
    
    //reploace all the magic numbers by parameters
(
    input  wire clk, 
    input  wire core_read_f,
    input  wire data_frames_in [1023: 0][15: 0],
    
    output  reg [15: 0]        new_act_core,
    output  reg [15: 0]        init_r0_vect,  // only new  data, old not considered here
    output  reg [31: 0]        mess_to_core.
    output  reg [ 7: 0][15: 0]      r0_data
//change for wires where possible
);

    reg   data_frames    [1023: 0][15: 0];   // better change type of memory later
    

    reg [ 5: 0] if_num    =  6'b0;
    reg [ 9: 0] global_tp = 10'b0;   // [3:0] = tp, [9:4] = frame
    reg [ 1: 0]             fence;   // barrier
    reg [15: 0]         exec_mask;   // 1 -> 0 if the core is ready

    always @(posedge clk) begin
        data_frames <= data_frames_in;

        if (if_num == 0) begin
            // initially must be CF
            
            new_act_core      = data_frames[frame * 256 + 1][15: 0];

            if (exec_mask & new_act_core == 0) begin
                fence        <= data_frames[frame * 256 + 0][ 7: 6];
                if_num       <= data_frames[frame * 256 + 0][ 5: 0]; 
                init_r0_vect <= data_frames[frame * 256 + 2][15: 0];
                r0_data      <= data_frames[frame * 256 + 31: frame * 256 + 16][15: 0];

                exec_mask    <= exec_mask | data_frames[frame * 256 + 1][15: 0]; // ??? or change for new_act_core???
                
                frame <= frame + 1;   // === global tp += 10'd16
            end 

        else if (core_read_f = 1) begin

            mess_to_core[15:  0] <= data_frames[global_tp    ][15: 0];
            mess_to_core[31: 16] <= data_frames[global_tp + 1][15: 0]; //delete it, just change gp

            global_tp <= global_tp + 2; 
            if_num    <= if_num    - 1;

        end // end of if

endmodule
