`include "pseudo_asm.v"
`timescale 1ns/100ps

module gpu_test;
    parameter  DATA_DEPTH = 1024;

    reg clk;
    reg reset;
    reg [DATA_DEPTH - 1: 0][15: 0] data_frames_in;
    wire               frame_being_sent;

    integer i; 
    integer k; 
    integer file;
    integer status;

    reg [15:0]              instruction;     
    reg                    prog_loading;
    reg [15: 0]                 tm_line;


/// for outfiles
	reg [8 * 29: 1] output_file;
	reg [     3: 0]    bank_num;
	reg [     1: 0]        flag;
    reg [15:0] temp_data;

	integer h, out_dsp, infile;
/// for outfiles

    always 
        #1 clk = ~clk;
 


    task send_tm_line(input [15:0] instruction, input integer j);
        begin
            // Проверка на допустимый индекс
            if (j >= 0 && j <= 1023) begin
                $display ("before write: instruction: %h , number %d", instruction, j);
                data_frames_in[j] = instruction; // Запись инструкции в массив
                $display ("after writing     data_frames_in[%d] = %h ", j, data_frames_in[j]);
            end else begin
                $display("Ошибка: индекс вне диапазона!");
            end
        end
    endtask


    gpu gpu (
             .clk             (             clk),
             .reset           (           reset),
             .prog_loading    (    prog_loading),
             .data_frames_in  (  data_frames_in)
    );


    initial begin
        clk          <= 0;
        reset        <= 1;
        prog_loading <= 1;
    end

    initial begin
        // Открываем входной файл
        infile = $fopen("src_data/bin_shader.bin", "r");
        if (infile == 0) begin
            $display("Ошибка: не удалось открыть файл.");
            $finish;
        end

        // Считываем данные из файла
        for (i = 0; i < DATA_DEPTH; i = i + 1) begin
            // Читаем одно 16-битное число в temp_data
            if ($fscanf(infile, "%b\n", temp_data) != 1) begin
                $display("Ошибка при чтении данных. Возможно, файл закончился, i = %d", i);
                i = DATA_DEPTH; // Выходим из цикла, если данных больше нет
            end
            
            // Записываем считанное значение в массив
            data_frames_in[i] = temp_data;
        end
        
        // Закрываем файл
        $fclose(infile);
        $display("Данные успешно загружены.");
    end
	

    initial begin 
		$dumpfile("dump.vcd"); $dumpvars(0, gpu_test);
        #10;
        reset = 0;
        #10;

        for (i = 288; i < 1024; i = i + 1) begin
            data_frames_in[i] = 0;
        end
        #20;
        prog_loading = 0;
        #190;
        #450;
        #450;
        #450;
        #450;
        #450;
        #450;
        #450;
        #450;
        #450;
        #450;
        #450;
        #450;


        #40500;
        reset = 1;
        #450;
        $finish;
    end
endmodule

