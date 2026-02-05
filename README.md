# MIPS Single-Cycle Processor (Harris & Harris Architecture)

## Overview

This project implements a **Single-Cycle MIPS Processor** based on the architecture described in:

Digital Design and Computer Architecture  
David Harris and Sarah Harris

The design follows the single-cycle datapath presented in the book. In this architecture, **each instruction completes in one clock cycle**. All instruction types (R-type, I-type, J-type) execute fully within a single rising clock edge.

Because every instruction must complete in one cycle, the clock period is determined by the longest instruction path (typically `lw`).

---

## Architecture Characteristics

- Single-cycle datapath
- One clock cycle per instruction
- Separate Instruction Memory and Data Memory
- Combinational control unit (Main Decoder + ALU Decoder)
- No intermediate registers like IR, MDR, A, B, ALUOut (unlike multi-cycle)

---

## Supported Instructions (Harris Subset)

### R-Type
- add
- sub
- and
- or
- slt

### I-Type
- lw
- sw
- beq
- addi

### J-Type
- j

All instruction formats follow standard MIPS encoding.

---

## Datapath Components (As per Harris & Harris)

### Core Components
- Program Counter (PC)
- Instruction Memory
- Register File (32 × 32-bit)
- ALU
- Data Memory
- Sign Extend
- Shift Left 2 (for branch offset)
- Adder (PC + 4)
- Adder (Branch target calculation)

---

## Key Multiplexers

- RegDst
- ALUSrc
- MemtoReg
- PCSrc

---

## Control Unit Design

The control unit is combinational and divided into:

1. Main Decoder
2. ALU Decoder

### Main Control Signals

- RegWrite
- RegDst
- ALUSrc
- Branch
- MemWrite
- MemtoReg
- Jump
- ALUOp

---

## ALU Control (Harris Encoding)

### ALUOp Values

| ALUOp | Meaning |
|-------|--------|
| 00    | Add (lw, sw, addi) |
| 01    | Subtract (beq) |
| 10    | R-type (use funct field) |

The ALU Decoder uses:
- ALUOp
- funct field (for R-type)

to generate:
- ALUControl signal

---

## Instruction Execution Flow

### R-Type
- Read registers
- ALU operation using funct field
- Write result to rd

### lw
- Compute address (base + offset)
- Read from Data Memory
- Write to rt

### sw
- Compute address
- Write register value to Data Memory

### beq
- Subtract rs and rt
- If Zero = 1, update PC with branch target

### j
- PC updated using jump address:
  
  {PC[31:28], instr[25:0], 2'b00}

---

## PC Update Logic

Next PC is selected from:

1. PC + 4
2. Branch target:
   
   PC + 4 + (SignImm << 2)

3. Jump target

Branch is taken when:
- Branch = 1
- Zero = 1


