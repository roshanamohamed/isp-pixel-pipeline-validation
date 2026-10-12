# ISP Pixel Pipeline: RTL Design & Validation

A small, reproducible **image signal processor (ISP)-inspired digital design and verification project**. It uses synthesizable SystemVerilog RTL and a Python bit-exact golden model to exercise realistic hardware-validation workflows.

> **Scope:** This is a learning project, not a complete camera ISP, silicon bring-up, or physical-hardware validation. No FPGA/ASIC results are claimed. The brightness flag is a threshold comparator, **not an edge detector**.

## Features
- RGB888 to 8-bit luma using integer BT.601-like coefficients: `(77R + 150G + 29B + 128) >> 8`.
- Configurable Q4 gain (`16 = 1x`) and 8-bit saturation.
- Configurable inclusive brightness threshold output.
- Registered output and `out_valid` signal (one clock-edge latency); no backpressure.
- Directed corner cases, seeded random test vectors, and a scoreboard-style SystemVerilog testbench.
- Python `unittest` suite for the software golden model.

## Repository layout
```text
rtl/isp_pixel_pipeline.sv          Synthesizable datapath
 tb/tb_isp_pixel_pipeline.sv       Self-checking HDL testbench
 tb/vectors.txt                    Generated stimulus and expected results
 tools/golden_model.py            Golden pixel math
 tools/make_vectors.py            Deterministic stimulus generator
 tests/test_golden_model.py       Python unit tests
 docs/VALIDATION_PLAN.md          Test plan and known limitations
```

## Quick start (Python 3.10+)
```bash
python -m unittest discover -s tests -v
python tools/make_vectors.py --count 1000 --seed 42
```

## RTL simulation (requires Icarus Verilog)
```bash
iverilog -g2012 -s tb_isp_pixel_pipeline -o isp_tb.vvp rtl/isp_pixel_pipeline.sv tb/tb_isp_pixel_pipeline.sv
vvp isp_tb.vvp +VECTORS=tb/vectors.txt
```
Expected output: `PASS: 1010 ISP pixel vectors`.

The testbench has **not** been claimed to pass HDL simulation unless you actually run it with a simulator. Python unit tests and generated vectors are independent of RTL simulation.

## Hardware option
After a successful RTL simulation, integrate the module with an FPGA development board by providing a clock, reset, RGB input stream, and access to the gain/threshold signals. A real board demo requires **board-specific pin mapping and timing constraints**, not included here.

## Potential resume description (use only after running/understanding it)
"Developed an ISP-inspired SystemVerilog pixel pipeline with programmable gain and brightness threshold, and created a Python golden model and self-checking RTL testbench for directed and randomized functional verification."

## License
MIT — see `LICENSE`.
