
import numpy as np
import matplotlib.pyplot as plt

def read_data(filenames):
    # Создаем двумерный массив 64x64
    data = np.zeros((64, 64), dtype=object)  # Изменяем тип на object для хранения чисел и символов
    
    for file_index, filename in enumerate(filenames):
        with open(filename, 'r') as file:
            # Читаем все значения из файла и разбиваем строку на элементы
            elements = file.readline().strip().split()

            # Проверяем, что в файле ровно 256 элементов
            if len(elements) != 256:
                raise ValueError(f"Файл {filename} должен содержать ровно 256 значений.")
            
            # Заполняем столбцы массива
            for col in range(4):  # У нас 4 группы по 64 числа
                start_index = col * 64
                end_index = start_index + 64
                # Заполняем соответствующий столбец в массиве
                data[:, file_index * 4 + col] = elements[start_index:end_index]

    return data

def main():
    filenames = [f'bank_{i}.txt' for i in range(10)] + [f'bank_{chr(i)}.txt' for i in range(ord('a'), ord('g'))]

    # Чтение данных
    pixel_values = read_data(filenames)

    # Печатаем полученный двумерный массив
    print("Созданный двумерный массив 64x64:")
    print(pixel_values)

    # Создаем изображение
    rgb_image = np.zeros((64, 64, 3), dtype=np.uint8)

    for i in range(64):
        for j in range(64):
            value = pixel_values[i, j]
            if value == 'x':
                rgb_image[i, j] = [255, 0, 0]  # Красный цвет
            else:
                value = int(value)  # Преобразуем в целое число
                rgb_image[i, j] = [value, value, value]  # Используем одно и то же значение для R, G и B

    # Показываем изображение
    plt.imshow(rgb_image)
    plt.axis('off')  # Отключаем оси
    plt.savefig('outfile.png')
    print("picture saved in file outfile.png")

if __name__ == "__main__":
    main()
