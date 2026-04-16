#define BLOCK_SIZE 256

__global__ void substring_matching_kernel(char* text, char* pattern, int text_size, int pattern_size, int* result){
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if(idx >= text_size) return;

    // Initialize result for this index
    result[idx] = 0;

    // Check if match is possible from this index
    if (idx + pattern_size > text_size) return;

    bool match = true;
    for(int i = 0; i < pattern_size; i++){
        if(text[idx + i] != pattern[i]){
            match = false;
            break;
        }
    }
    if(match){
        result[idx] = 1;
    }
}

void substring_matching(char* text, char* pattern, int text_size, int pattern_size, int* result){
    char* td, *pd;
    int* rd;
    cudaMalloc((void**) &td, text_size * sizeof(char));
    cudaMalloc((void**) &pd, pattern_size * sizeof(char));
    cudaMalloc((void**) &rd, text_size * sizeof(int));

    cudaMemcpy(td, text, text_size * sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy(pd, pattern, pattern_size * sizeof(char), cudaMemcpyHostToDevice);

    int grid_size = (text_size + BLOCK_SIZE - 1) / BLOCK_SIZE;
    substring_matching_kernel<<<grid_size, BLOCK_SIZE>>>(td, pd, text_size, pattern_size, rd);

    cudaMemcpy(result, rd, text_size * sizeof(int), cudaMemcpyDeviceToHost);

    cudaFree(td);
    cudaFree(pd);
    cudaFree(rd);
}