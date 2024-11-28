commands = {
    "NOP": "0000",
    "ADD": "0001",
    "SUB": "0010",
    "MUL": "0011",
    "DIV": "0100",
    "CMPGE": "0101",
    "RSHFT": "0110",
    "LSHFT": "0111",
    "AND": "1000",
    "OR": "1001",
    "XOR": "1010",
    "LD": "1011",
    "LD_SYNC": "1011",
    "SET_CONST": "1100",
    "ST": "1101",
    "ST_SYNC": "1101",
    "BNZ": "1110",
    "READY": "1111"
}

# Сопоставление регистров с двоичными значениями
registers = {
    "R0": "0000",
    "R1": "0001",
    "R2": "0010",
    "R3": "0011",
    "R4": "0100",
    "R5": "0101",
    "R6": "0110",
    "R7": "0111",
    "R8": "1000",
    "R9": "1001",
    "R10": "1010",
    "R11": "1011",
    "R12": "1100",
    "R13": "1101",
    "R14": "1110",
    "R15": "1111"
}

def binary_code_str(binary_list):
    binary_str = ''

    for binary_element in binary_list:
        binary_str += binary_element

    return binary_str

def hex_to_bin(hex_str):
    size_part, value_part = hex_str.split("'")
    size = int(size_part)  # Получаем размер в битах

        # Убираем 'h' и все, что после него
    value = value_part.split('h')[1]  # Извлекаем часть после 'h'

        # Преобразуем шестнадцатеричное значение в десятичное
    decimal_value = int(value, 16)

        # Форматируем двоичное представление с ведущими нулями
    binary_representation = format(decimal_value, f'0{size}b')[-size:]  # Обрезаем до нужного размера
    return binary_representation

def translate_asm_to_bin(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:

        counter = 0

        for line in infile:
            binary_list = []

            if line[0] == '#':
                continue

            parts = line.strip().split()
            #print(parts)

            if not parts:
                continue

            else:
                counter += 1
                for part in parts:
                    if part in commands:
                        list.append(binary_list, commands[part])
                    elif part in registers:
                        list.append(binary_list, registers[part])
                    else:
                        hex_number = hex_to_bin(part)
                        list.append(binary_list, hex_number)

            binary_code = binary_code_str(binary_list)

            #print(binary_code, counter)
            outfile.write(binary_code + '\n')

if __name__ == "__main__":
    input_filename = "src_data/shaders/shader2.v"  # Укажите имя входного файла здесь
    output_filename = "src_data/bin_shader.bin"  # Имя выходного файла

    translate_asm_to_bin(input_filename, output_filename)
