#define log2(x) (31 - __builtin_clz(x))
#define BLOCK_SIZE 1024

__global__ void simple_scan(float* m, int size) {
    int tx = threadIdx.x;
    if (tx >= size) return;
    
    int log_count = log2(2 * BLOCK_SIZE - 1);

    for (int i = 0; i < log_count; i++) {
        float val = 0;
        int stride = 1 << i;
        if (tx >= stride) {
            val = m[tx - stride];
        }
        __syncthreads();
        m[tx] += val;
        __syncthreads();
    }
}

__global__ void add_block_sums(float* m, float* sums, int size){
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if(idx >= size || blockIdx.x == 0) return;

    m[idx] += sums[blockIdx.x - 1];
}

__global__ void scan_block_with_sums(float* m, float* sums, int size){
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int tx = threadIdx.x;

    __shared__ float temp[BLOCK_SIZE];
    temp[tx] = (idx < size) ? m[idx] : 0;
    __syncthreads();

    int log_count = log2(2 * BLOCK_SIZE - 1);

    for(int i = 0; i < log_count; i++){
        int stride = 1 << (i + 1);
        if((tx + 1) % stride == 0){
            temp[tx] += temp[tx - (stride >> 1)];
        }
        __syncthreads();
    }

    if(idx < size){
        m[idx] = temp[tx];
    }
    
    if(tx == BLOCK_SIZE - 1){
        sums[blockIdx.x] = m[idx];
    }
}

__host__ void upsweep(float* m, float* sums, int size, int grid_size){
    scan_block_with_sums<<<grid_size, BLOCK_SIZE>>>(m, sums, size);
}


__global__ void scan_block_downsweep_sum(float* m, float* sums, int size){
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int tx = threadIdx.x;
    
    __shared__ float temp[BLOCK_SIZE];
    temp[tx] = (idx < size) ? m[idx] : 0;
    __syncthreads();

    if(tx == BLOCK_SIZE - 1){
        temp[tx] = 0;
    }

    int log_count = log2(2 * BLOCK_SIZE - 1);

    for(int i = log_count - 1; i >= 0; i--){
        int stride = 1 << (i + 1);
        if((tx + 1) % stride == 0){
            float val = temp[tx];
            temp[tx] += temp[tx - (stride >> 1)];
            temp[tx - (stride >> 1)] = val;
        }
        __syncthreads();
    }

    if(idx < size){
        m[idx] = temp[tx];
    }
}

__host__ void downsweep(float* m, float* sums, int size, int grid_size){
    scan_block_downsweep_sum<<<grid_size, BLOCK_SIZE>>>(m, sums, size);
    simple_scan<<<1, BLOCK_SIZE>>>(sums, grid_size);
    add_block_sums<<<grid_size, BLOCK_SIZE>>>(m, sums, size);
}

void prefix_sum(float* m, float* n, int size){
    float *md, *sums;
    cudaMalloc((void**) &md, size * sizeof(float));
    cudaMemcpy(md, m, size * sizeof(float), cudaMemcpyHostToDevice);

    int grid_size = (size + BLOCK_SIZE - 1) / BLOCK_SIZE;
    cudaMalloc((void**) &sums, grid_size * sizeof(float));

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);
    
    upsweep(md, sums, size, grid_size);
    downsweep(md, sums, size, grid_size);
    
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);
    std::cout << "GPU Time: " << milliseconds << " ms" << std::endl;

    cudaMemcpy(n, md, size * sizeof(float), cudaMemcpyDeviceToHost);
    
    // std::cout << "GPU: ";
    // for(int i = 0; i < 10; i++){
    //     std::cout << n[i] << " ";
    // }
    // std::cout << std::endl;
    
    cudaFree(md);
    cudaFree(sums);
}