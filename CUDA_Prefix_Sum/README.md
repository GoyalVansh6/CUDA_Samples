# CUDA Prefix Sum (Scan) Optimization

This repository contains high-performance CUDA implementations of the Prefix Sum (Scan) algorithm, exploring both **Kogge-Stone** and **Blelloch** methods for large-scale data processing.

## Project Structure
- **/CPU**: Sequential C++ reference implementation for verification.
- **/Kernel1**: High-performance **Exclusive Kogge-Stone** (Hillis-Steele) scan. Optimized for latency ($O(\log n)$ steps).
- **/Kernel2**: Work-efficient **Exclusive Blelloch** scan. Optimized for throughput and compute-efficiency ($O(n)$ work).

## Key Features
*   **Hierarchical Multi-Block Design**: Both kernels support arrays of any size (tested up to 10,000,000 elements) by using a grid-wide synchronization strategy.
*   **Shared Memory Acceleration**: Uses on-chip shared memory for intra-block communication to minimize global memory bandwidth bottle-necks.
*   **Numerical Stability**: Optimized for `float` precision with relative error checks to handle floating-point accumulation at scale.
*   **Zero Padding**: Correctly handles input sizes that are not powers of 2.

## Performance Comparison (1M elements)
| Implementation   | Work Efficiency | Step Complexity | GPU Time    | Speedup  |
| :--------------- | :-------------- | :-------------- | :---------- | :------- |
| CPU (Sequential) | $O(n)$          | $O(n)$          | ~3.0 ms     | 1x       |
| **Kernel 1**     | $O(n \log n)$   | $O(\log n)$     | **0.17 ms** | **~17x** |
| **Kernel 2**     | $O(n)$          | $O(\log n)$     | **0.16 ms** | **~18x** |

## How to Run
### Kernel 1 (Kogge-Stone)
```bash
cd Kernel1
nvcc -arch=sm_89 test.cu -o prefix_sum && ./prefix_sum
```

### Kernel 2 (Blelloch)
```bash
cd Kernel2
nvcc -arch=sm_89 test.cu -o prefix_sum && ./prefix_sum
```