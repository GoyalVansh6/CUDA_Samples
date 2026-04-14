#define log2(x) (31 - __builtin_clz(x))

__global__ void prefix_sum_kernel(float* m, int size){
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = 1;

        
}

void prefix_sum(float* m, float* n, int size){
    float* md;
    cudaMalloc((void**) &md, size * sizeof(float));
    cudaMemcpy(md, m, size * sizeof(float), cudaMemcpyHostToDevice);
    
    int block_size = 256;
    int grid_size = (size + block_size - 1) / block_size;

    prefix_sum_kernel<<<grid_size, block_size>>>(md, size);
    cudaDeviceSynchronize();
    cudaMemcpy(n, md, size * sizeof(float), cudaMemcpyDeviceToHost);
    cudaFree(md);
}