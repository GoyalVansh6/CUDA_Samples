# Kernel 1: Exclusive Kogge-Stone Scan

This directory contains a high-performance implementation of the **Exclusive Prefix Sum** using the Kogge-Stone (Hillis-Steele) algorithm.

## Algorithm Overview
The Kogge-Stone scan is a parallel prefix sum algorithm that performs $O(n \log n)$ work but has a very low step complexity ($O(\log n)$), making it highly efficient for GPU execution.

## Implementation Details
*   **Exclusive Mode**: This implementation produces an exclusive scan where `output[i]` is the sum of all elements `input[0]` to `input[i-1]`.
*   **Hierarchical Strategy**:
    - **Phase 1**: Local inclusive scan per block. The total sum of each block is stored.
    - **Phase 2**: Global scan of block-level sums.
    - **Phase 3**: Block-level offsets are added to the local results.
*   **Optimization**: The exclusive shift is performed during data loading from host to device to maximize throughput.

## System Performance
Measured on an NVIDIA GPU (sm_89):

**Test Size: 1,000,000 elements**
- **GPU Time**: 0.35376 ms
- **CPU Time**: 4.47337 ms
- **Status**: Correct (Verified against CPU)

## Build and Run
```bash
nvcc -arch=sm_89 test.cu -o prefix_sum_exclusive
./prefix_sum_exclusive
```
