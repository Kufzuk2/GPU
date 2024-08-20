`timescale 1ns/100ps

module testbench;
    parameter  DATA_DEPTH = 1024;

    reg clk;
    reg reset;
    reg core_reading;
    reg [DATA_DEPTH - 1: 0][15: 0] data_frames_in;
    reg [15: 0]              core_ready;
    reg                    prog_loading;
    wire               frame_being_sent;
    integer i; 
    
    integer file;
    integer status;
    reg [15:0] instruction;     

    always 
        #1 clk = ~clk;
/*
    always
        #3 core_reading = $random; 
*/

 task send_tm_line(input [15:0] instruction, input integer j);
        begin
            // Проверка на допустимый индекс
            if (j >= 0 && j <= 1023) begin
                data_frames_in[j] = instruction; // Запись инструкции в массив
            end else begin
                $display("Ошибка: индекс вне диапазона!");
            end
        end
    endtask

    scheduler #(.DATA_DEPTH(1024), .R0_DATA_SIZE(128), .CTRL_DATA_SIZE(48), 
                .INSTR_SIZE(16),   .FRAME_SIZE(256),   .FRAME_NUM(64),
                .CORE_NUM(16),     .BUS_TO_CORE(16),   .R0_DEPTH(8))       scheduler
                        (
                         .clk             (             clk),
                         .reset           (           reset),
                         .core_ready      (      core_ready),
                         .core_reading    (    core_reading),
                         .prog_loading    (    prog_loading),
                         .data_frames_in  (  data_frames_in)

    );
    /*
initial begin
        // Загрузка данных из hex-файла
        $readmemh("task_memory.hex", data_frames_in);
    end
*/

    initial begin
        clk          <= 0;
        reset        <= 1;
        core_ready   <= 16'hffff;
        core_reading <= 1;
        prog_loading <= 1;
/*
        file = $fopen("instructions.txt", "r");
        if (file == 0) begin
            $display("Ошибка: не удалось открыть файл!");
            $finish;
        end

        // Чтение инструкций из файла и загрузка в массив
        for (i = 0; i < 1024; i = i + 1) begin
            status = $fscanf(file, "%h\n", instruction); // Чтение 16-битной инструкции в шестнадцатеричном формате
            
            if (status != 1) begin
                $display("Ошибка: не удалось прочитать инструкцию %0d.", i);
                $finish;
            end
            
            send_tm_line(instruction, i); // Загружаем инструкцию в массив
        end

        // Закрытие файла после чтения
        $fclose(file);
*/

    end

	initial begin 
		$dumpfile("dump.vcd"); $dumpvars(0, testbench);
        #10;
        reset = 0;
        #10;
        data_frames_in[0]  =  16'h0043;  // new task must not start
        data_frames_in[1]  =  16'h000f;
        data_frames_in[2]  =  16'h000f;

        for (i = 3; i < 64; i = i + 1) begin
            data_frames_in[i] = $random;
        end

        

        data_frames_in[64]  =  16'h0003;
        data_frames_in[65]  =  16'h00f0; // must wait previous. add changin ready flag
        data_frames_in[66]  =  16'h00f0;

        for (i = 67; i < 128; i = i + 1) begin
            data_frames_in[i] = $random;
        end



        data_frames_in[128]  =  16'h0007;
        data_frames_in[129]  =  16'h00f0; // cllision of masks, must wait
        data_frames_in[130]  =  16'h00f0;

        for (i = 131; i < 256; i = i + 1) begin
            data_frames_in[i] = $random;
        end

        data_frames_in[256]  =  16'h008f;  // must not start before every core is free
        data_frames_in[257]  =  16'h0f00;
        data_frames_in[258]  =  16'h0f00;

        for (i = 259; i < 1024; i = i + 1) begin
            data_frames_in[i] = $random;
        end



        #10;
        prog_loading = 0;

        #20;
        core_ready   = 16'hfff0;

        #35;

        #85;
        core_ready = 16'hff00;

        #60; // 190
        core_ready = 16'hff0f;

        #450;
        core_ready = 16'hffff;

        #12;
        core_ready = 16'hff0f;

        #240;
        core_ready = 16'hffff;
        #2;
        core_ready = 16'hff0f;

        #340;
        core_ready = 16'hffff;
/*

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
//        data_frames_in[DATA_DEPTH - 1: 192] = 0;
        #190;
        #450;
        #450;
        $finish;
	end

    




endmodule 
