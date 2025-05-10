def generate_verilog_module(binary_file_path, output_file_path):
    # Чтение бинарного файла
    with open(binary_file_path, 'r') as f:
        lines = [line.strip() for line in f if line.strip()]
    
    instr_num = len(lines)
    
    # Генерация заголовка модуля
    verilog_code = f"""module load_asm
#(
    parameter INSTR_SIZE = 16,
    parameter INSTR_NUM  = {instr_num},
    parameter FULL_DEPTH = 1024
)
(
    input wire clk,
    input wire rst,

    output wire [INSTR_NUM * INSTR_SIZE - 1: 0] data_frames_line
);
    reg [INSTR_SIZE - 1: 0] data_frames [INSTR_NUM - 1: 0];
    

    genvar a;
    generate
        for (a = 0; a < INSTR_NUM; a = a + 1) begin : data_assign
            assign data_frames_line [INSTR_SIZE * (a + 1) - 1: INSTR_SIZE * a] = data_frames[a];
        end
    endgenerate


    always @(posedge clk) begin
        if (rst) begin
"""

    # Добавление присваиваний при сбросе
    for i, line in enumerate(lines):
        verilog_code += f"            data_frames[{i:3}] <= 16'b{line};\n"
    
    verilog_code += "        end else begin\n"
    
    # Добавление присваиваний в обычном режиме
    for i in range(instr_num):
        verilog_code += f"            data_frames[{i:3}] <= data_frames[{i:3}];\n"
    
    verilog_code += """        end
    end

endmodule
"""

    # Запись в выходной файл
    with open(output_file_path, 'w') as f:
        f.write(verilog_code)

# Пример использования
input_file = "src_data/bin_shader.bin"  # путь к вашему входному файлу
output_file = "load_asm.v"  # путь для выходного Verilog файла
generate_verilog_module(input_file, output_file)