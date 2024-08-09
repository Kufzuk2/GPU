#include <iostream>
#include <ctime>
#include  <random>
int main()
{
    int num = 0;
    std::cout << "type number of symbols" << std::endl;
    std::cin  >> num;
    srand(time(0));
    for (int i = 0; i < num; i++)
    {
        std::cout << rand() % 10;
    }
    std::cout << std::endl;

}




