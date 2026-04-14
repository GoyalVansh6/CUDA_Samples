# Kernel 2: Work-Efficient (Blelloch) Scan

This directory contains a high-performance implementation of the **Work-Efficient Exclusive Prefix Sum** (also known as the Blelloch Scan) using CUDA.

## Algorithm Overview
The Blelloch scan is an $O(n)$ work algorithm that uses a balanced tree structure. It operates in two main phases:
1.  **Upsweep (Reduction)**: Similar to a parallel reduction, this phase computes partial sums up the levels of the tree.
2.  **Downsweep**: This phase distributes values back down the tree to compute the final exclusive results.

## Implementation Details
*   **Shared Memory Tiling**: Each block loads its data into shared memory to minimize global memory bandwidth.
*   **Zero Padding**: Correctly handles input sizes that are not a power of 2 by padding the shared memory tree nodes with identity elements (0).
*   **Hierarchical Strategy**:
    - **Phase 1**: Every block performs a local exclusive scan and stores its total sum.
    - **Phase 2**: The auxiliary array of block sums is scanned globally.
    - **Phase 3**: Block-level offsets are added to the local results to produce the final global exclusive scan.

## Performance
Blelloch scan is mathematically more efficient than the Hillis-Steele algorithm ($O(n)$ vs $O(n \log n)$ additions), making it significantly faster for very large datasets where the GPU is compute-bound.

## Build and Run
```bash
nvcc -arch=sm_89 test.cu -o prefix_sum_blelloch
./prefix_sum_blelloch
```
