module sheduler

// Resolution and refresh rate  

#(

)
    //reploace all the magic numbers by parameters
(
    input clock, 
    input data_frames_in   ...  // same as lower
);

    reg [1023: 0] data_frames [ 15: 0];   
    reg [63: 0] data_frames [15: 0][15: 0];   
    // continious instructions
   
    // reg [  63: 0] data_frames [255: 0]; 
    // one frame for 16 instructions
                                        //// ??????????????
                                        //    how to divide into frames



    reg [15: 0]     core_active_vect;   //active cores
    reg [ 1: 0]                fence;   // barrier

    reg [ 5: 0]                   tp;   // task pointer
    reg [ 5: 0]               if_num;
    reg [15: 0]            exec_mask;   // 1 -> 0 if the core is ready


    integer frame;
    always @(posedge clock) begin
        data_frames <= data_frames_in;

        for (frame = 0; frame < ; frame = frame + 1) begin
            if (if_num == 0) begin
                // initially must be CF
                
                // consider fence as if it works only if it is considered only during
                // start of frame exec
                fence  <= data_frames[frame * 256 + 0][7: 6];
                if_num <= data_frames[frame * 256 + 0][5: 0]; 
                // OR
                fence  <= data_frames[frame][0][7: 6];
                if_num <= data_frames[frame][0][5: 0]; 


                // next write or transmit registers data
                
                cores cores (); // here call of cores
                                // must change exec mask
            else
                if_num <= if_num - 1;
                //instr exec

            end // end of if

        end //end of for
end
