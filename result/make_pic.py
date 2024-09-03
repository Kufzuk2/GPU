import numpy as np
import matplotlib.pyplot as plt

# Функция для чтения данных из файлов
def read_data(filenames):
    data = np.zeros((64, 64), dtype=int)
    for file_index, filename in enumerate(filenames):
        with open(filename, 'r') as file:
            lines = file.readlines()
            for row_index, line in enumerate(lines):
                numbers = list(map(int, line.split()))
                column_index = (file_index * 4 + row_index) % 64
                data[column_index] = numbers
    return data

# Функция для получения цвета по числу
def get_color(value):
    return (value / 255, value / 255, value / 255)  # Нормализуем значение в диапазон [0, 1]

# Основная программа
def main():
    # Имена файлов
    filenames = [f'file_{i+1}.txt' for i in range(16)]  # Например: file_1.txt, file_2.txt, ..., file_16.txt
    
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
    plt.show()

if __name__ == "__main__":
    main()

