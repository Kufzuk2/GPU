def hex_to_bin(hex_str):
    # Проверяем наличие префикса "h"
    if "'" not in hex_str or 'h' not in hex_str:
        print(f"Ошибка: {hex_str} не содержит корректного формата.")
        return None
    
    try:
        size_part, value_part = hex_str.split("'")
        size = int(size_part)  # Получаем размер в битах
        
        # Убираем 'h' и все, что после него
        value = value_part.split('h')[1]  # Извлекаем часть после 'h'
        
        # Преобразуем шестнадцатеричное значение в десятичное
        decimal_value = int(value, 16)
        
        # Форматируем двоичное представление с ведущими нулями
        binary_representation = format(decimal_value, f'0{size}b')[-size:]  # Обрезаем до нужного размера
        return binary_representation
    except ValueError as e:
        print(f"Ошибка при преобразовании: {e}")
        return None

# Примеры использования:
print(hex_to_bin("12'h0"))      # Output: "000000000000"
print(hex_to_bin("16'hfffe"))   # Output: "1111111111111110"
print(hex_to_bin("8'h1A"))      # Output: "00011010"
print(hex_to_bin("4'hF"))       # Output: "1111"
print(hex_to_bin("5'h1"))       # Output: "00001"