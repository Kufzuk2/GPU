def hex_to_bin(hex_str):
    # Удаляем префиксы и конвертируем шестнадцатиричное число в двоичное
    if "h" in hex_str:
        size = int(hex_str.split("'")[0])  # Получаем размер (например, 4, 8, 12, 16)
        value = int(hex_str.split("'")[1], 16)  # Преобразуем Y в десятичное число
        return format(value, f'0{size}b')  # Форматируем в двоичное с ведущими нулями
    return None

def translate_asm_to_bin(input_file, output_file):
    try:
        with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
            for line in infile:
                parts = line.strip().split()  # Разделяем строку по пробелам
                
                if not parts:
                    continue  # Пропускаем пустые строки
                
                command = parts[0]
                if command in commands:
                    opcode = commands[command]
                    
                    if len(parts) == 4:  # Например, ADD R0 R1 R2 или ADD 6'h5 8'hf ...
                        reg1 = registers.get(parts[1], "0000")  # Значение по умолчанию
                        reg2 = registers.get(parts[2], "0000") 
                        
                        # Проверяем, является ли третий аргумент числом в разрешенном формате
                        reg3 = None
                        if parts[3].startswith("0x") or parts[3].startswith("0H"):  
                            reg3 = hex_to_bin(parts[3][2:])
                        elif any(parts[3].startswith(prefix) for prefix in ["4'h", "6'h", "8'h", "12'h", "16'h"]):
                            reg3 = hex_to_bin(parts[3])
                        else:
                            reg3 = registers.get(parts[3], "0000")

                        if reg3 is None:
                            print(f"Ошибка: Неверный формат числа: {parts[3]}")
                            continue

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
    except FileNotFoundError:
        print(f"Ошибка: файл {input_file} не найден.")
    except IOError as e:
        print(f"Ошибка ввода-вывода: {e}")

if __name__ == "__main__":
    input_filename = "shader.v"  # Укажите имя входного файла здесь
    output_filename = "bin_shader.bin"  # Имя выходного файла

    translate_asm_to_bin(input_filename, output_filename)