#include <iostream>
#include "kernal1.cu"
#include "../CPU/prefix_sum.cpp"

int main(){
    int size = 1000000;
    float* h_m = new float[size];
    float* h_n = new float[size];

    for(int i = 0; i < size; i++){
        h_m[i] = i;
    }

    prefix_sum(h_m, h_n, size);

    float* h_m_cpu = new float[size];
    float* h_n_cpu = new float[size];
    prefix_sum_cpu(h_m_cpu, h_n_cpu, size);

    bool correct = true;
    for(int i = 0; i < size; i++){
        float rel_err = abs(h_n[i] - h_n_cpu[i]) / std::max(1.0f, abs(h_n_cpu[i]));
        if(rel_err > 1e-3){
            std::cout << "Incorrect at index " << i << ": GPU=" << h_n[i] << ", CPU=" << h_n_cpu[i] << " (RelErr: " << rel_err << ")" << std::endl;
            correct = false;
            break;
        }
    }

    if(correct){
        std::cout << "Correct" << std::endl;
    }

    delete[] h_m;
    delete[] h_n;
    delete[] h_m_cpu;
    delete[] h_n_cpu;

    return 0;
}