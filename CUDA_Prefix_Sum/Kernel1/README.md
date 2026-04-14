# Kernel 1: Hierarchical Multi-Block Prefix Sum (Scan)

This directory contains a CUDA implementation of a **Hierarchical Inclusive Prefix Sum** algorithm, designed to handle large datasets that exceed the limits of a single thread block.

## Overview

To support arrays larger than 1024 elements, this implementation uses a **Hierarchical Scan (Scan-and-Add)** strategy:
1.  **Block-level Scan**: Each thread block (1024 threads) computes a prefix sum of its own elements. The total sum of each block is stored in an auxiliary `sums` array.
2.  **Global Scan**: A single-block scan is performed on the `sums` array to calculate the global offset for each block.
3.  **Offset Addition**: Each block is updated by adding the corresponding offset from the scanned `sums` array.

### Key Implementation Details:
- **Scalability**: Capable of handling up to ~1 million elements (1024 blocks of 1024 threads).
- **Race Condition Prevention**: Uses local registers and dual-sync points within the kernel loop.
- **High-Precision Timing**: Utilizes **CUDA Events** to measure GPU execution time across all kernel launches.
- **Validation**: Uses relative tolerance (`1e-3`) to account for floating-point accumulation differences between the CPU (sequential) and GPU (parallel).

## Files
- `kernal1.cu`: Contains the `scan_block_with_sums`, `simple_scan`, and `add_block_sums` kernels.
- `test.cu`: The test harness, now configured for 1,000,000 elements.
- `../CPU/prefix_sum.cpp`: Reference sequential implementation.

## How to Run
```bash
nvcc -arch=sm_89 test.cu -o prefix_sum && ./prefix_sum
```

## Results (1,000,000 elements)
```text
GPU Time: 0.25952 ms
CPU Time: 4.3052 ms
```
The GPU shows a significant performance advantage (~16x speedup) over the CPU at this scale.
