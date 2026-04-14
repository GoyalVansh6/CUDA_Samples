#include<iostream>
#include<chrono>

int prefix_sum_cpu(float* h_m_cpu, float* h_n_cpu, int size){
    for(int i = 0; i < size; i++){
        h_m_cpu[i] = i;
    }

    h_n_cpu[0] = h_m_cpu[0];

    auto start = std::chrono::high_resolution_clock::now();
    
    for(int i = 1; i < size; i++){
        h_n_cpu[i] = h_m_cpu[i] + h_n_cpu[i - 1];
    }
    
    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> diff = end - start;
    std::cout << "CPU Time: " << diff.count() << " seconds" << std::endl;

    return 0;
}