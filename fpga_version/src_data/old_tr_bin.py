
# Словарь для сопоставления команд с двоичными значениями
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

def translate_asm_to_bin(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            parts = line.strip().split()  # Разделяем строку по пробелам
            
            if not parts:
                continue  # Пропускаем пустые строки
            
            command = parts[0]
            if command in commands:           
                opcode = commands[command]
                
                # Предполагаем, что следующие части - это регистры
                if len(parts) == 4:  # Например, ADD R0 R1 R2
                    reg1 = registers.get(parts[1], "0000")  # Значение по умолчанию
                    reg2 = registers.get(parts[2], "0000")
                    reg3 = registers.get(parts[3], "0000")
                    
                    # Формируем бинарный код
                    binary_code = f"{opcode}{reg1}{reg2}{reg3}"
                else:
                    print(f"Неверное количество аргументов для {command}: {line.strip()}")
                    continue
                
                # Дополняем строку до 16 бит нулями, если нужно
                binary_code = binary_code.zfill(16)
                
                # Проверка длины бинарного кода
                if len(binary_code) != 16:
                    print(f"Ошибка: Бинарный код не имеет 16 бит для: {line.strip()}")
                    continue
                
                # Записываем в выходной файл
                outfile.write(binary_code + '\n')
            else:
                print(f"Неизвестная команда: {command}")

if __name__ == "__main__":
    input_filename = "shader.v"  # Укажите имя входного файла здесь
    output_filename = "bin_shader.bin"  # Имя выходного файла
    translate_asm_to_bin(input_filename, output_filename)
