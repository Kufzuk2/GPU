#include <stdio.h>

int main() {
    int n = 288;
    FILE *file;



    file = fopen("output.txt", "w");
    if (file == NULL) {
        printf("Не удалось открыть файл для записи.\n");
        return 1;
    }

    for (int i = 0; i < n; i++) {
        fprintf(file, "%d\n", i);
    }

    fclose(file);


    return 0;
}