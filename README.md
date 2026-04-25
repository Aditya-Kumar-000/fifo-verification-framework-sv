# FIFO Verification Framework (SystemVerilog)

A structured **SystemVerilog verification framework** developed to validate a parameterized FIFO RTL design using assertion-based verification, interface-driven stimulus, reference-model checking, and functional coverage metrics.

This project simulates how real digital verification teams validate RTL before tapeout by ensuring correctness under normal operation, corner cases, and invalid protocol scenarios.

---

## Verification Features

- SystemVerilog Assertions (SVA)
- Interface-based DUT communication
- Reference scoreboard model
- Functional coverage reporting
- Simultaneous read/write verification
- Overflow/underflow stress testing
- Pointer wraparound validation
- Reset verification
- Flag validation (`full`, `empty`, `almost_full`, `almost_empty`)

---

## Project Architecture

```bash
Theta_4/
├── example_router.sv
├── fifo.sv
├── fifo_if.sv
├── reference_scoreboard.sv
└── tb_top.sv
```

---

## DUT Overview

The DUT is a parameterized FIFO with:

- Configurable data width
- Configurable FIFO depth
- Circular pointer wraparound
- Full/empty detection
- Almost full/empty threshold detection
- Simultaneous read/write capability

### Key Parameters

```systemverilog
parameter WIDTH = 4
parameter DEPTH = 12
parameter ALMOST_FULL_TH = 2
parameter ALMOST_EMPTY_TH = 2
```

---

# Verification Architecture

## 1. Interface Layer (`fifo_if.sv`)

Encapsulates DUT communication using:

- clocking blocks
- modports
- synchronized signal driving
- race condition prevention

This creates clean separation between DUT and testbench logic.

---

## 2. Assertion Layer (SVA)

Protocol correctness is validated using assertions:

### Reset validation
Ensures FIFO returns to empty state after reset.

### Empty read protection
Detects illegal reads from an empty FIFO.

### Full write protection
Detects illegal writes to a full FIFO.

### Wake-up validation
Ensures empty flag clears after valid write.

### Full flag validation
Ensures full flag clears after valid read.

### Simultaneous read/write validation
Checks FIFO behavior during concurrent operations.

---

## 3. Reference Scoreboard

A software reference model built using SystemVerilog queues:

```systemverilog
logic [3:0] golden_queue[$];
```

The scoreboard:

- tracks expected FIFO behavior
- stores valid writes
- predicts valid reads
- compares expected vs actual DUT output

---

## 4. Coverage Metrics

The testbench tracks:

- valid writes
- valid reads
- successful matches
- overall verification quality score

Example output:

```bash
Coverage Summary_FIFO
Total Valid Writes: 12
Total Valid Reads: 12
Total Data Matches: 12
Quality Score: 100%
```

---

# Test Scenarios

### FIFO Fill Test
Attempts writes beyond FIFO depth to validate full protection.

---

### FIFO Drain Test
Attempts reads beyond available entries to validate empty protection.

---

### Simultaneous Read/Write Test
Verifies concurrent transaction handling.

---

### Pointer Wraparound Test
Ensures circular addressing behaves correctly.

---

### Reset Recovery Test
Ensures clean restart behavior.

---

# Key Verification Concepts Demonstrated

- Assertion-Based Verification (ABV)
- Reference Modeling
- Scoreboarding
- Functional Coverage
- Interface Design
- RTL Debugging
- Corner Case Validation

---

# Tools Used

- SystemVerilog
- ModelSim / QuestaSim

---

# Why This Project Matters

Verification consumes a major portion of modern semiconductor development cycles.

This project reflects foundational workflows used by verification engineers at companies such as:

- ARM
- NVIDIA
- AMD
- Intel
- Qualcomm

and serves as a practical foundation for ASIC/FPGA verification roles.
