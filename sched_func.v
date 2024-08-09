`ifndef SCHED_FUNC
`define SCHED_FUNC

module sched_funcs;
function  [15: 0] sched_fence
   (input [15: 0]  data_frame);
   
   begin
        sched_fence = data_frame & 16'b0000000011000000 >> 6;
    end
endfunction


function waiting
    (input [15: 0]  cur_data_frame,
     input [15: 0] next_data_frame,
     input [15: 0]       exec_mask,
     input                 wait_it
    );

    begin
        waiting = ((next_data_frame & exec_mask) != 16'h0) || wait_it || 
                  (( cur_data_frame & `SCHED_FENCE_MASK) >> 6 == `SCHED_FENCE_REL && exec_mask);
    end
endfunction
endmodule

`endif
