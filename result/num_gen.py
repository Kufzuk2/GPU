import random

# Количество файлов и строк
num_files = 16
num_lines = 4
num_numbers_per_line = 64

for i in range(num_files):
    filename = f'file_{i + 1}.txt'
    with open(filename, 'w') as f:
        for _ in range(num_lines):  # 4 строки
            numbers = [str(random.randint(0, 255)) for _ in range(num_numbers_per_line)]  # 64 случайных числа
            f.write(' '.join(numbers) + '\n')
    
    print(f"Файл {filename} успешно создан.")
