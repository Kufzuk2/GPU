module scheduler
#(
    parameter DATA_DEPTH = 1023
)
// Resolution and refresh rate  
    
    //reploace all the magic numbers by parameters
(
    input  wire clk,
    input  wire reset,
    input  wire core_read_f,
    input  wire [1023: 0][15: 0] data_frames_in,
    input  wire                    prog_loading,
    
    output  reg [15: 0]            new_act_core,
    output  reg [15: 0]            init_r0_vect,  // only new  data, old not considered here
    output  reg [31: 0]            mess_to_core,
    output  reg [ 7: 0][15: 0]          r0_data,
    output wire                frame_being_sent
//change for wires where possible
);

    reg [1023: 0][15: 0] data_frames;   // better change type of memory later
    

    reg [ 5: 0]    if_num;
    reg [ 9: 0] global_tp;   // [3:0] = tp, [9:4] = frame
    reg [ 1: 0]     fence;   // barrier
    reg [15: 0] exec_mask;   // 1 -> 0 if the core is ready
    integer i;
    integer k;

    always @(posedge clk) begin

        if (reset) begin
           if_num    <= 0;
           global_tp <= 0;
           exec_mask <= 0;
       end else begin 

        data_frames <= data_frames_in;
            
        if (!prog_loading) begin

        if (if_num == 0) begin
            // initially must be CF
            new_act_core     <= data_frames[global_tp + 1];

            if ((exec_mask & new_act_core) == 0) begin // might be mistake. new_act_core not changed yet
                fence        <= (data_frames[global_tp    ] & 16'b0000000011000000) >> 6;
                if_num       <= data_frames[global_tp    ] & 16'b0000000000111111; 
                init_r0_vect <= data_frames[global_tp + 2];


                for (i = 0; i < 16; i = i + 1) begin
                    r0_data[i] <= data_frames[global_tp + i + 16];
                end

                exec_mask    <= exec_mask | data_frames[global_tp + 1]; // ??? or change for new_act_core???
                
                global_tp <= global_tp + 10'h10;   // === global tp += 10'd16
            end 

            end else if (core_read_f) begin

            mess_to_core[15:  0] <= data_frames[global_tp    ];
            mess_to_core[31: 16] <= data_frames[global_tp + 1]; //delete it, just change gp
            global_tp <= global_tp + 2; 

            if (global_tp[3: 0] == 4'b1110) begin  // must be 0000, but ZZ
                if_num <= if_num - 1;
            end

        end // end of if
        end // prog loading
            end // of reset    
    end // for always
endmodule
