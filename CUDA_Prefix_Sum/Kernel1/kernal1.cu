#define log2(x) (31 - __builtin_clz(x))

__global__ void scan_block_with_sums(float* m, float* sums, int size){
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx >= size) return;

    int block_size = blockDim.x;
    int log_size = 0;
    while ((1 << log_size) < block_size) log_size++;

    for(int i = 0; i < log_size; i++){
        float val = 0;
        int stride = 1 << i;
        if(threadIdx.x >= stride){
            val = m[idx - stride];
        }
        __syncthreads();
        m[idx] += val;
        __syncthreads();
    }

    if(threadIdx.x == blockDim.x - 1 || idx == size - 1){
        sums[blockIdx.x] = m[idx];
    }
}

__global__ void simple_scan(float* m, int size){
    int idx = threadIdx.x;
    if (idx >= size) return;

    int log_size = 0;
    while ((1 << log_size) < size) log_size++;

    for(int i = 0; i < log_size; i++){
        float val = 0;
        int stride = 1 << i;
        if(idx >= stride){
            val = m[idx - stride];
        }
        __syncthreads();
        m[idx] += val;
        __syncthreads();
    }
}

__global__ void add_block_sums(float* m, float* sums, int size){
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx >= size || blockIdx.x == 0) return;

    m[idx] += sums[blockIdx.x - 1];
}

void prefix_sum(float* m, float* n, int size){
    float* md;
    cudaMalloc((void**) &md, size * sizeof(float));
    cudaMemcpy(md, m, size * sizeof(float), cudaMemcpyHostToDevice);

    int block_size = 1024;
    int grid_size = (size + block_size - 1) / block_size;
    
    float* sums;
    cudaMalloc((void**) &sums, grid_size * sizeof(float));

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);
    
    scan_block_with_sums<<<grid_size, block_size>>>(md, sums, size);
    
    simple_scan<<<1, 1024>>>(sums, grid_size);
    
    add_block_sums<<<grid_size, block_size>>>(md, sums, size);
    
    cudaEventRecord(stop);

    cudaEventSynchronize(stop);
    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);
    std::cout << "GPU Time: " << milliseconds << " ms" << std::endl;
    
    cudaMemcpy(n, md, size * sizeof(float), cudaMemcpyDeviceToHost);
    
    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    cudaFree(md);
    cudaFree(sums);
}