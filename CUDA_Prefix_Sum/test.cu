#include "PS.cu"
#include <iostream>

int main(){
    float m[10] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    float n[10];
    prefix_sum(m, n, 10);
    for(int i = 0; i < 10; i++){
        std::cout << n[i] << " ";
    }
    std::cout << std::endl;
    return 0;
}