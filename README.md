# INT8 NPU Accelerator Using Verilog

## Overview

This project implements a simple **8×8 INT8 Neural Processing Unit (NPU)** using Verilog HDL. The design performs signed matrix multiplication using an INT8 multiply-accumulate (MAC) datapath, with DMA-based data transfer, quantization, and output saturation.

The project follows a hardware accelerator development approach, starting with basic MAC operations and progressing to an integrated NPU architecture.

**Current status:** Stage 2 — Completed functional simulation and verification.

## Objectives

- Design a basic multiply-accumulate (MAC) unit.
- Develop a 4×4 matrix multiplication accelerator.
- Integrate DMA-based data transfer with an 8×8 NPU.
- Support signed INT8 operands and INT32 accumulation.
- Implement configurable output quantization and signed INT8 saturation.
- Verify functionality using Verilog testbenches in Xilinx Vivado.

## Architecture

The current system uses the following functional data path:

```text
        External Memory Model
                 |
                 v
          DMA Controller
                 |
                 v
         Local Input Storage
                 |
                 v
          8×8 INT8 NPU
                 |
                 v
       Quantization and Saturation
                 |
                 v
          Output Storage
                 |
                 v
          Output Read Port
```

The external memory model supplies the input matrices through the DMA interface. The NPU computes the matrix product, and the output interface provides the resulting signed 8-bit values.

## Technology Stack

- **Hardware Description Language:** Verilog HDL
- **Simulation and RTL Development:** Xilinx Vivado
- **Target FPGA:** AMD/Xilinx Zynq-7000, PYNQ-Z2 (`xc7z020clg400-1`)
- **Data format:** Signed INT8 inputs and outputs
- **Accumulator:** Signed INT32
- **Design type:** Digital hardware accelerator

*Note: The target FPGA is selected for future implementation. FPGA synthesis, placement, routing, and bitstream generation have not yet been completed.*

## Project Stages

### Stage 1: Basic MAC and 4×4 NPU — Completed

- Developed the basic multiply-accumulate datapath.
- Built a 4×4 matrix multiplication design.
- Verified matrix multiplication using a Verilog testbench.
- Checked the expected output values.

### Stage 2: DMA-Integrated 8×8 INT8 NPU — Completed

#### 1. DMA Integration

- Integrated the DMA controller with the NPU.
- Tested memory-to-local-storage data transfer.
- Verified the DMA transfer using a testbench and a combinational external memory model.

#### 2. 8×8 Matrix Multiplication

- Implemented an 8×8 matrix multiplication engine.
- Used signed 8-bit matrix operands.
- Accumulated multiplication results in a signed 32-bit accumulator.
- Verified all 64 output elements using a testbench.

#### 3. Quantization

- Implemented arithmetic right-shift quantization.
- Made the quantization shift configurable through the RTL parameter.
- Tested positive and negative values, including arithmetic shift behavior.

#### 4. Saturation

- Implemented signed INT8 saturation.
- Limited output values to the range −128 to +127.
- Verified the standalone quantization and saturation logic.

#### 5. Functional Verification

The following functional tests have passed:

| Test | Result |
|---|---|
| 4×4 matrix multiplication | PASS |
| Standalone DMA transfer | PASS |
| Integrated DMA + 8×8 NPU, all-ones test | PASS |
| Signed 8×8 matrix multiplication | PASS |
| Standalone quantization and saturation | PASS |
| Integrated NPU saturation test | PASS |

The integrated `QUANT_SHIFT=2` test is being finalized separately and is not included in the completed-test list above.

## Input and Output Data Format

- **Matrix A:** 8×8 signed INT8 matrix.
- **Matrix B:** 8×8 signed INT8 matrix.
- **Accumulation:** Signed INT32.
- **Output:** Signed INT8 after quantization and saturation.

The mathematical operation is:
<span style="font-size: 20px;">**𝐂ᵢ,ⱼ = ∑ₖ₌₀⁷ 𝐀ᵢ,ₖ𝐁ₖ,ⱼ**</span>


The final output is obtained by applying the configured arithmetic right shift and limiting the result to the signed INT8 range.

<span style="font-size: 20px;">**𝐘ᵢ,ⱼ = sat_{[₋₁₂₈, ₁₂₇]} (𝐂ᵢ,ⱼ >>> s)**</span>


Here, \(s\) is the quantization shift parameter.

## Verification Approach

The design has been verified through behavioral simulation using Verilog testbenches.

The tests cover:

- Matrix multiplication with known expected outputs.
- DMA data transfer and integration.
- Positive and negative operand handling.
- Quantization using arithmetic right shifts.
- Signed INT8 output saturation.
- Comparison of all 64 output values against expected results.

These results establish functional correctness for the tested configurations. They do not yet establish FPGA timing closure, hardware performance, power consumption, or ASIC readiness.

## Current Limitations

- FPGA synthesis and implementation have not yet been completed.
- BRAM and DSP inference have not yet been confirmed from synthesis reports.
- Hardware-level testing on the PYNQ-Z2 has not yet been completed.
- Power, area, and timing measurements are not yet available.

## Conclusion

The project has progressed from a basic MAC and 4×4 accelerator to an integrated DMA-based 8×8 INT8 NPU. Functional simulations have verified matrix multiplication, signed arithmetic, quantization logic, and saturation behavior.

This provides a foundation for subsequent memory architecture optimization, FPGA implementation, and hardware performance evaluation.

## Author

**Sujanmulk Nikash Kalyankumar**

Electronics and Communication Engineering  
Mahatma Gandhi Institute of Technology (MGIT), Hyderabad
