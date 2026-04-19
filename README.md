# MIPS Single-Cycle Processor (Harris & Harris Architecture)

## Overview
This project implements a **Single-Cycle MIPS Processor** based on the architecture described in:

> *Digital Design and Computer Architecture*  
> *David Harris and Sarah Harris*

The design follows the **single-cycle datapath** presented in the textbook. In this architecture, each instruction completes in exactly **one clock cycle**.

All instruction types (**R-type, I-type, J-type**) execute fully within a single rising clock edge.

Because every instruction must complete in one cycle, the **clock period is determined by the longest instruction path (critical path)** — typically the `lw` instruction.

---

## Architecture Characteristics

- **Single-cycle datapath** → CPI (Cycles Per Instruction) = 1  
- **Harvard Architecture** → Separate Instruction Memory and Data Memory  
- **Control Logic** → Purely combinational  
  - Main Decoder  
  - ALU Decoder  
- **No Intermediate Registers**  
  - No IR, MDR, ALUOut  
  - Data flows directly within one cycle  

---

## Supported Instructions (Harris Subset)

### R-Type
- `add`
- `sub`
- `and`
- `or`
- `slt`

### I-Type
- `lw` (Load Word)
- `sw` (Store Word)
- `beq` (Branch if Equal)
- `addi` (Add Immediate)

### J-Type
- `j` (Jump)

All instructions follow the standard **32-bit MIPS encoding**.

---

## Datapath Components

### Core Components
- **Program Counter (PC)**  
  32-bit register holding the current instruction address  

- **Instruction Memory**  
  Read-only memory (initialized via `program.hex`)  

- **Register File**  
  - 32 × 32-bit registers  
  - Dual read ports  
  - Single write port  

- **ALU**  
  Performs arithmetic and logical operations  

- **Data Memory**  
  Read/Write memory for data storage  

- **Sign Extend**  
  Converts 16-bit immediate → 32-bit  

- **Shift Left 2**  
  Used for branch and jump address calculation  

- **Adders**
  - PC + 4  
  - Branch target computation  

---

## Key Multiplexers

- **RegDst** → Selects destination register (`rt` or `rd`)  
- **ALUSrc** → Selects ALU operand (register or immediate)  
- **MemtoReg** → Selects write-back source (ALU or memory)  
- **PCSrc** → Selects next PC (PC+4 or branch target)  

---

## Control Unit Design

The control unit is **purely combinational** and split into:

### 1. Main Decoder
- Takes **opcode**
- Generates primary control signals

### 2. ALU Decoder
- Takes:
  - `ALUOp`
  - `funct` field (for R-type)
- Outputs specific ALU control signal

---

## Main Control Signals

- `RegWrite`
- `RegDst`
- `ALUSrc`
- `Branch`
- `MemWrite`
- `MemtoReg`
- `Jump`
- `ALUOp`

---

## ALU Control (Harris Encoding)

### ALUOp Values

| ALUOp | Meaning                   |
|------|---------------------------|
| 00   | ADD (lw, sw, addi)        |
| 01   | SUB (beq)                 |
| 10   | R-type (use funct field)  |

### ALUControl Output

| Code | Operation |
|------|----------|
| 000  | AND      |
| 001  | OR       |
| 010  | ADD      |
| 110  | SUB      |
| 111  | SLT      |

---

## Instruction Execution Flow

### R-Type
1. Fetch instruction  
2. Read `rs` and `rt`  
3. ALU performs operation based on `funct`  
4. Result written to `rd`  

---

### lw (Load Word)
1. Compute address: `rs + SignExt(offset)`  
2. Read from Data Memory  
3. Write to `rt`  

---

### sw (Store Word)
1. Compute address: `rs + SignExt(offset)`  
2. Write `rt` value to Data Memory  

---

### beq (Branch if Equal)
1. ALU computes `rs - rt`  
2. If Zero flag = 1 → branch taken  
3. PC updated to branch target  

---

### j (Jump)
PC is updated using:
