# Validation plan

## Contract
Inputs: RGB888, gain_Q4, threshold, and `in_valid`.
Outputs: registered luma, inclusive brightness flag, and registered `out_valid`.
The pipeline does not have `ready`; each asserted input-valid is accepted.

## Directed scenarios
1. Black and white pixels; primary-color weighting.
2. Zero gain, unity gain, and maximum gain; saturation boundary.
3. Threshold equal to computed luminance (inclusive comparison).
4. Low luma and rounding boundary conditions.
5. Output-valid deassertion after a bubble.
6. Reset behavior (can be expanded in testbench).

## Random testing
1000 reproducible random RGB/gain/threshold tuples by default, seed 42.
Golden model emits both luma and bright flag for each input.

## Limitations / next steps
- RTL simulation requires an HDL simulator (Icarus/Verilator); Python-only tests cannot prove RTL correctness.
- Current testbench uses valid on every vector; add random valid gaps and reset-in-flight tests.
- No constraints, synthesis timing reports, functional coverage, or FPGA board measurements.
- Gain and threshold are sampled per accepted pixel; no real register bus.
- No Bayer demosaicing, autofocus, temporal filtering, Sobel edge detection, or full ISP pipeline.
