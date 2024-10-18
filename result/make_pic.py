
import numpy as np
import matplotlib.pyplot as plt

# Функция для чтения данных из файлов
def read_data(filenames):
    data = np.zeros((64, 64), dtype=int)
    
    for file_index, filename in enumerate(filenames):
        with open(filename, 'r') as file:
            # Читаем единственную строку
            line = file.readline().strip()
            numbers = line.split()
            
            # Проверяем, что количество значений соответствует 256 или есть 'x'
            if len(numbers) != 256:
                raise ValueError(f"Файл {filename} должен содержать ровно 256 значений.")

            # Заполняем данные в массив
            for i in range(64):  # Для каждого из 64 значений
                column_index = file_index * 4 + i // 64  # Индекс столбца
                value = numbers[i]
                if value == 'x':
                    data[i % 64, column_index] = -1  # Используем -1 для обозначения красного пикселя
                else:
                    data[i % 64, column_index] = int(value)

    return data

# Функция для получения цвета по числу
def get_color(value):
    if value == -1:  # Если значение -1, это красный цвет
        return (1.0, 0.0, 0.0)  # RGB (1, 0, 0) - красный
    else:
        return (value / 255, value / 255, value / 255)  # Нормализуем значение в диапазон [0, 1]

# Основная программа
def main():
    # Имена файлов
    filenames = [f'result/bank_{i:x}.txt' for i in range(16)]  # Например: file_0.txt, file_1.txt, ..., file_15.txt

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
    plt.savefig('output.png', bbox_inches='tight', pad_inches=0)
    plt.close()

if __name__ == "__main__":
    main()
