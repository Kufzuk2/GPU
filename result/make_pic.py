import sys
import numpy as np
import matplotlib.pyplot as plt

def read_data(filenames):
    data = np.zeros((64, 64), dtype=int)

    column = 0
    for file_index, filename in enumerate(filenames):
        with open(filename, 'r') as file:

            line = file.readline().strip()
            numbers = line.split()

            string = 0
            for num in numbers:
                if string == 64:
                    string = 0
                    column += 1
                #print(f"file_index = {file_index}, value = {num}, string = {string}, column = {column}")
                if num == 'x':
                    data[string, column] = -1  # Используем -1 для обозначения красного пикселя
                else:
                    data[string, column] = int(num)
                string += 1
            column += 1

    np.set_printoptions(threshold=sys.maxsize)
    #print(data)
    return data

def get_color(value):
    if value == -1:  # Если значение -1, это красный цвет
        return 1.0, 0.0, 0.0  # RGB (1, 0, 0) - красный
    else:
        return value / 255, value / 255, value / 255  # Нормализуем значение в диапазон [0, 1]

def main():
    # Имена файлов
    filenames = [f'result/bank_{i:x}.txt' for i in range(16)]  # Например: file0.txt, file1.txt, ..., file15.txt
    # Чтение данных
    pixel_values = read_data(filenames)

    # Создаем массив цветов
    color_array = np.zeros((64, 64, 3))  # Для хранения RGB значений
    for i in range(64):
        for j in range(64):
            color_array[i, j] = get_color(pixel_values[i, j])

    # Визуализация
    plt.imshow(color_array, interpolation='nearest')
    plt.axis('off')  # Убираем оси
    plt.savefig('result/output.png', bbox_inches='tight', pad_inches=0)
    plt.close()

if __name__ == "__main__":
    main()
