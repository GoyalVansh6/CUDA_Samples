#define log2(x) (31 - __builtin_clz(x))
#define BLOCK_SIZE 256

__global__ void blelloch_kernel(float* m, int size){
    int tx = threadIdx.x;
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    
    __shared__ float shared_mem[BLOCK_SIZE];

    
    shared_mem[tx] = idx < size ? m[idx] : 0;
    __syncthreads();

    for(int i = 2; i >= 0; i <<= 1){
        
    }
}

void prefix_sum(float* m, int size){
    float* md;
    cudaMalloc((void**) &md, m, size * sizeof(float));
    cudaMemcpy(md, m, size * sizeof(float), cudaMemcpyHostToDevice);

    
}