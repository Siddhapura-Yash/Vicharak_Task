
# Task 1: 19-bit CPU Architecture

This repository contains the Verilog implementation of a **custom 19-bit CPU architecture**, including modules for the ALU, datapath, register file, memory, and a controller. The CPU is designed to execute a specific set of assembly instructions.

## 🔗 EDA Playground Link

[View on EDA Playground](https://www.edaplayground.com/x/EZeM)

## 📂 Contents

  * `code/` – Verilog modules and testbench for the CPU.
  * `doc/` – Handwritten and PDF documentation detailing the architecture's design.

## 📝 Assembly Program Example

The following assembly program is included as a test case for the CPU.

```
LD r2,addr    // First store value in r2 from memory as value 23
LD r3,addr    // r3 = 20

LABEL :
INC r3        // Increment content of r3 by 1
ADD r1,r2,r3  // Add r2 and r3, store result in r1
BNE r2,r3     // If r2 != r3 then jump to LABEL (will loop for 3 times)
```

### Expected Output

After the program executes, the registers and a specific memory location will hold the following values:

  * **r1:** 46
  * **r2:** 23
  * **r3:** 23
  * **Memlocation[102]:** 46
