# Pipelined MIPS Processor in VHDL

A 32-bit MIPS processor with a classic 5-stage pipeline (IF, ID, EX, MEM, WB), written in VHDL and designed to run on a Digilent FPGA development board. The processor executes a program stored in its instruction memory that counts the **positive odd numbers** in an array held in data memory and writes the result back to memory.

## Features

- 32-bit datapath, 32 general-purpose registers (`$0` hardwired to zero)
- 5-stage pipeline with dedicated IF/ID, ID/EX, EX/MEM and MEM/WB registers
- Hazards handled in software (NOPs inserted by the programmer)
- Register file written on the falling clock edge, read asynchronously
- Step-by-step execution using a debounced button, with internal signals shown on the 7-segment display and LEDs

## Instruction Set

| Instruction | Type | Opcode   | Funct    | Operation                                   |
|-------------|------|----------|----------|---------------------------------------------|
| `add`       | R    | `000000` | `100000` | `rd = rs + rt`                              |
| `sll`       | R    | `000000` | `000000` | `rd = rt << sa` (encoding `0x00000000` = NOP) |
| `addi`      | I    | `001000` | –        | `rt = rs + SignExt(imm)`                    |
| `andi`      | I    | `001100` | –        | `rt = rs & ZeroExt(imm)`                    |
| `lw`        | I    | `100011` | –        | `rt = M[rs + SignExt(imm)]`                 |
| `sw`        | I    | `101011` | –        | `M[rs + SignExt(imm)] = rt`                 |
| `beq`       | I    | `000100` | –        | `if (rs == rt) PC = PC + 4 + (imm << 2)`    |
| `bne`       | I    | `000101` | –        | `if (rs != rt) PC = PC + 4 + (imm << 2)`    |
| `bgtz`      | I    | `000111` | –        | `if (rs > 0) PC = PC + 4 + (imm << 2)`      |
| `j`         | J    | `000010` | –        | `PC = (PC + 4)[31:28] & target & "00"`      |

## Pipeline and Hazards

There is no forwarding or hazard detection unit, so the program avoids hazards through instruction scheduling:

| Hazard              | Resolved in | Required delay slots                               |
|---------------------|-------------|----------------------------------------------------|
| Conditional branch  | MEM         | 3 instructions after the branch                    |
| Jump                | ID          | 1 instruction after the jump                       |
| Data (RAW)          | WB → ID     | 2 instructions between producer and consumer       |

Data hazards need only two slots because the register file is written on the falling edge, so a value written in WB can be read in ID during the same cycle.

## The Program

The program counts how many elements of an array of `N` words are both positive and odd.

```text
count = 0
for i = 0 to N - 1:
    x = A[i]
    if x > 0 and (x & 1) != 0:
        count = count + 1
M[0] = count
```

Register usage:

| Register | Purpose                        |
|----------|--------------------------------|
| `$1`     | `N` (number of elements)       |
| `$2`     | loop index `i`                 |
| `$3`     | byte offset of the current element |
| `$4`     | result counter                 |
| `$5`     | current element                |
| `$6`     | `$5 & 1` (odd test)            |

When it finishes, the program enters an infinite `j` loop on itself, so the result stays stable.

### Data Memory Layout

| Address        | Content                     |
|----------------|-----------------------------|
| `0x00`         | result (written by the program) |
| `0x04`         | `N`                         |
| `0x08` onwards | array elements              |

With the default data `[9, 6, 14, 25, -2, 33, -9, 22]` (`N = 8`), the expected result is **3** (9, 25 and 33).

## Project Structure

| File            | Description                                                      |
|-----------------|------------------------------------------------------------------|
| `TEST_ENV.vhd`  | Top-level entity: stages, pipeline registers, board I/O           |
| `IFetch.vhd`    | Program counter, instruction ROM (holds the program), next-PC logic |
| `ID.vhd`        | Instruction decode and immediate extension                       |
| `REG_FILE.vhd`  | 32 × 32-bit register file                                        |
| `UC.vhd`        | Main control unit                                                |
| `EX.vhd`        | ALU control, ALU, branch address and destination register selection |
| `MEM.vhd`       | 64 × 32-bit data memory (holds the input array)                  |
| `MPG.vhd`       | Mono pulse generator (button debouncer)                          |
| `SSD.vhd`       | 8-digit 7-segment display driver                                 |

## Running on the Board

1. Create a new project in Xilinx Vivado and add all `.vhd` files.
2. Set `test_env` as the top-level entity.
3. Add the constraints file (`.xdc`) for your board.
4. Generate the bitstream and program the FPGA.

### Controls

| Input       | Function                                   |
|-------------|--------------------------------------------|
| `btn[0]`    | Execute one clock step                     |
| `btn[1]`    | Reset (PC and pipeline)                    |
| `sw[7:5]`   | Select the value shown on the display      |

| `sw[7:5]` | Displayed value                    |
|-----------|------------------------------------|
| `000`     | Current instruction (IF)           |
| `001`     | PC + 4                             |
| `010`     | Read data 1 (ID/EX)                |
| `011`     | Read data 2 (ID/EX)                |
| `100`     | Extended immediate (ID/EX)         |
| `101`     | ALU result                         |
| `110`     | Memory read data                   |
| `111`     | Write-back data                    |

LEDs `led[11:0]` show the control signals of the instruction in the ID stage:

| LED     | 11–10   | 9      | 8     | 7      | 6      | 5    | 4     | 3    | 2        | 1        | 0        |
|---------|---------|--------|-------|--------|--------|------|-------|------|----------|----------|----------|
| Signal  | `ALUOp` | `RegDst` | `ExtOp` | `ALUSrc` | `Branch` | `Brne` | `Brgtz` | `Jump` | `MemWrite` | `MemtoReg` | `RegWrite` |

To check the result, step through the program until `sw $4, 0($0)` reaches the MEM stage, then read the value with `sw[7:5] = 101` or `110`. The expected value is `00000003`.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
