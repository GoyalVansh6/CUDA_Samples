#include <iostream>
#include <vector>
#include <string>
#include <cuda_runtime.h>
#include "../CPU/KMP.h"
#include "kernel1.cu"

int main(){
    std::string text = "ABABDABACDABABCABABABABDABACDABABCABAB";
    std::string pattern = "ABABCABAB";
    int n = text.length();
    int m = pattern.length();

    std::cout << "Text size: " << n << ", Pattern size: " << m << std::endl;

    std::vector<int> cpu_results = KMPSearch(text, pattern);

    std::vector<int> gpu_results(n);
    substring_matching((char*)text.c_str(), (char*)pattern.c_str(), n, m, gpu_results.data());

    bool success = true;
    for(int i = 0; i < n; i++){
        if(cpu_results[i] != gpu_results[i]){
            std::cout << "Mismatch at index " << i << ": CPU=" << cpu_results[i] << ", GPU=" << gpu_results[i] << std::endl;
            success = false;
        }
    }

    if(success){
        std::cout << "ALL TESTS PASSED!" << std::endl;
    }
    else{
        std::cout << "TESTS FAILED!" << std::endl;
    }

    std::cout << "Text:    " << text << std::endl;
    std::cout << "Matches: ";
    for(int val : gpu_results){
        std::cout << val;
    }
    std::cout << std::endl;

    return 0;
}
