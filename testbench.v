`timescale 1ns/100ps

module testbench;

    reg clk;
    reg reset;
    reg core_read_f;
    reg [1023: 0][15: 0] data_frames_in;
    reg                    prog_loading;
    wire               frame_being_sent;
    integer i; 
    

    always 
        #1 clk = ~clk;


    scheduler scheduler (
                         .clk             (             clk),
                         .reset           (           reset),
                         .core_read_f     (     core_read_f),
                         .prog_loading    (    prog_loading),
                         .data_frames_in  (  data_frames_in),
                         .frame_being_sent(frame_being_sent)

    );
    

    initial begin
        clk          <= 0;
        reset        <= 1;
        core_read_f  <= 1;
        prog_loading <= 1;
    end

	initial begin 
		$dumpfile("dump.vcd"); $dumpvars(0, testbench);
        #10;
        reset = 0;
        #10;
        data_frames_in[0]  =  16'h0003;
        data_frames_in[1]  =  16'h000f;
        data_frames_in[2]  =  16'h000f;

        for (i = 3; i < 1024; i = i + 1) begin
            data_frames_in[i] = $random;
        end
        #10;
        prog_loading = 0;

    

/*
        data_frames_in[66: 64]  =  48'h000f000f0003;
        data_frames_in[79: 67] = 208'h1373155187753233769575848246214661179909884209798945;  // 1 frame readay
        //now 3 if: 48 instrs
        data_frames_in[127: 80] = 768'h909349783518983001342480463695987813001572382692929389525816505418711888217498902051905706357098961069882743753078170660315226012310218614980287216204456170791124167120519739573313858667656760
        

        data_frames_in[130: 128]  =  48'hf000f0000003;
        data_frames_in[143: 131] = 208'h1373155187753233769575848246214661179909884209798945;  // 1 frame readay
        //now 3 if: 48 instrs1
        data_frames_in[191: 144] = 768'h909349783518983001342480463695987813001572382692929389525816505418711888217498902051905706357098961069882743753078170660315226012310218614980287216204456170791124167120519739573313858667656760
*/
//        data_frames_in[1023: 192] = 0;
        #90;
        $finish;
	end

    




endmodule 
