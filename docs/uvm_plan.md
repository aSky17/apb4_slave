# APB4 UVM Verification — Complete Industry Flow

---

# 1. Verification Objective

We are verifying:

```text
APB4 Slave RTL
```

NOT:

* APB interconnect
* AXI/APB bridge
* SoC-level subsystem

The DUT is:

```text
APB4 Peripheral Slave Interface
```

Examples:

* UART APB slave
* GPIO APB slave
* TIMER APB slave

---

# 2. Overall Verification Architecture

```text
                  +----------------+
                  |   UVM TEST     |
                  +--------+-------+
                           |
                           v
                  +----------------+
                  |    UVM ENV     |
                  +--------+-------+
                           |
          ----------------------------------
          |                |               |
          v                v               v
   +-------------+   +-----------+   +------------+
   | APB AGENT   |   | SCOREBOARD|   | COVERAGE   |
   +------+------+   +-----------+   +------------+
          |
   -------------------
   |        |        |
   v        v        v
SEQUENCER DRIVER  MONITOR
             |
             v
       APB INTERFACE
             |
             v
          APB DUT
```

---

# 3. Complete Industry Directory Structure

```text
apb4_uvm_project/
│
├── README.md
├── Makefile
├── run.do
├── compile.do
├── waves.do
├── regress.sh
│
├── docs/
│   ├── verification_plan.md
│   ├── testplan.xlsx
│   ├── coverage_plan.md
│   └── protocol_notes.md
│
├── rtl/
│   ├── apb4_pkg.sv
│   ├── apb4_slave.sv
│   ├── apb4_assertions.sv
│   └── top.sv
│
├── tb/
│   ├── top/
│   │   └── top_tb.sv
│   │
│   ├── interface/
│   │   └── apb_if.sv
│   │
│   ├── sequence_item/
│   │   └── apb_seq_item.sv
│   │
│   ├── sequences/
│   │   ├── apb_base_seq.sv
│   │   ├── apb_write_seq.sv
│   │   ├── apb_read_seq.sv
│   │   ├── apb_random_seq.sv
│   │   ├── apb_b2b_seq.sv
│   │   ├── apb_wait_seq.sv
│   │   ├── apb_error_seq.sv
│   │   ├── apb_pstrb_seq.sv
│   │   ├── apb_pprot_seq.sv
│   │   └── apb_reset_seq.sv
│   │
│   ├── sequencer/
│   │   └── apb_sequencer.sv
│   │
│   ├── driver/
│   │   └── apb_driver.sv
│   │
│   ├── monitor/
│   │   └── apb_monitor.sv
│   │
│   ├── agent/
│   │   └── apb_agent.sv
│   │
│   ├── scoreboard/
│   │   └── apb_scoreboard.sv
│   │
│   ├── coverage/
│   │   └── apb_coverage.sv
│   │
│   ├── assertions/
│   │   └── apb_protocol_sva.sv
│   │
│   ├── env/
│   │   └── apb_env.sv
│   │
│   ├── tests/
│   │   ├── apb_base_test.sv
│   │   ├── apb_smoke_test.sv
│   │   ├── apb_random_test.sv
│   │   ├── apb_error_test.sv
│   │   ├── apb_wait_test.sv
│   │   ├── apb_pstrb_test.sv
│   │   ├── apb_pprot_test.sv
│   │   ├── apb_reset_test.sv
│   │   └── apb_regression_test.sv
│   │
│   └── pkg/
│       └── apb_tb_pkg.sv
│
├── sim/
│   ├── work/
│   ├── logs/
│   ├── waves/
│   ├── coverage/
│   └── regressions/
│
└── scripts/
    ├── compile.sh
    ├── run_test.sh
    └── regress.py
```

---

# 4. UVM Component Responsibilities

# 4.1 Sequence Item

Represents:

```text
one APB transaction
```

Contains:

* address
* write/read
* write data
* read data
* PSTRB
* PPROT
* wait cycles
* error expectation

---

# 4.2 Sequence

Generates:

```text
transaction stream
```

Examples:

* write sequence
* random sequence
* error sequence
* reset sequence

---

# 4.3 Sequencer

Controls:

```text
sequence -> driver communication
```

---

# 4.4 Driver

MOST IMPORTANT COMPONENT.

Acts as:

```text
Behavioral APB Master
```

Driver responsibilities:

* drive SETUP phase
* drive ACCESS phase
* wait for PREADY
* hold stable signals during wait
* support reads/writes
* support resets
* support back-to-back transfers

---

# 4.5 Monitor

Passively observes DUT interface.

Monitor responsibilities:

* detect APB transfers
* sample transactions
* send transaction to scoreboard
* send transaction to coverage

Monitor samples ONLY when:

```text
PSEL && PENABLE && PREADY
```

---

# 4.6 Agent

Groups together:

* sequencer
* driver
* monitor

Modes:

* ACTIVE
* PASSIVE

---

# 4.7 Scoreboard

Golden checker.

Responsibilities:

* register checking
* read/write checking
* PSTRB correctness
* PPROT correctness
* PSLVERR correctness
* reset value checking

---

# 4.8 Coverage Collector

Collects:

* functional coverage
* protocol coverage
* cross coverage

---

# 4.9 Environment

Top verification container.

Contains:

* agent
* scoreboard
* coverage

---

# 4.10 Test

Top-level testcase.

Responsibilities:

* configure environment
* start sequences
* control simulation

---

# 5. APB Verification Flow

# Step 1

Compile RTL.

---

# Step 2

Compile UVM TB.

---

# Step 3

Run smoke test.

---

# Step 4

Run directed tests.

---

# Step 5

Run constrained-random tests.

---

# Step 6

Collect coverage.

---

# Step 7

Fix uncovered scenarios.

---

# Step 8

Run regression.

---

# Step 9

Coverage closure.

---

# Step 10

Verification signoff.

---

# 6. APB Verification Plan

# 6.1 Protocol Verification

Verify:

* SETUP timing
* ACCESS timing
* wait states
* stable wait behavior
* transfer completion
* back-to-back transfers

---

# 6.2 Read/Write Verification

Verify:

* single write
* single read
* multiple writes
* multiple reads
* read-after-write
* write-after-read

---

# 6.3 Wait-State Verification

Verify:

* zero wait
* single wait
* multiple waits
* random waits
* wait during read
* wait during write

---

# 6.4 PSTRB Verification

Verify:

* byte writes
* halfword writes
* sparse writes
* full-word writes
* PSTRB=0000
* unchanged-byte preservation

---

# 6.5 PSLVERR Verification

Verify:

* invalid address
* RO register write
* illegal transfer
* proper PSLVERR timing

---

# 6.6 PPROT Verification

Verify:

* privileged access
* user access
* secure access
* non-secure access
* instruction access
* protection violations

---

# 6.7 Reset Verification

Verify:

* reset in IDLE
* reset in SETUP
* reset in ACCESS
* reset during wait
* reset recovery

---

# 6.8 Back-to-Back Verification

Verify:

* write-write
* read-read
* write-read
* read-write

---

# 6.9 Corner Cases

Verify:

* all 0 data
* all 1 data
* walking 1
* walking 0
* invalid addresses
* boundary addresses
* random PSTRB
* random PPROT

---

# 7. Functional Coverage Plan

# 7.1 Address Coverage

Cover:

* all valid addresses
* invalid addresses

---

# 7.2 Direction Coverage

Cover:

* reads
* writes

---

# 7.3 Wait-State Coverage

Cover:

* 0 wait
* 1 wait
* multiple waits

---

# 7.4 PSTRB Coverage

Cover all combinations:

```text
0000
0001
0010
0100
1000
0011
1100
1111
etc
```

---

# 7.5 PPROT Coverage

Cover all:

```text
000
001
010
011
100
101
110
111
```

---

# 7.6 Error Coverage

Cover:

* PSLVERR asserted
* PSLVERR deasserted

---

# 7.7 Cross Coverage

MOST IMPORTANT.

Cross:

* address x direction
* PSTRB x write
* wait x direction
* PPROT x address
* error x address
* error x protection

---

# 8. Assertion Coverage

Assertions must verify:

* protocol legality
* wait-state stability
* timing correctness
* error timing
* FSM legality

All assertions should:

* pass
* fail at least once during negative testing

---

# 9. Regression Strategy

# Smoke Regression

Small sanity tests.

---

# Directed Regression

Focused protocol tests.

---

# Random Regression

Constrained-random traffic.

---

# Stress Regression

Long random simulations.

---

# Nightly Regression

Run:

* all tests
* coverage merge
* summary report

---

# 10. Coverage Goals

# Functional Coverage

```text
>95%
```

---

# Code Coverage

```text
Statement >95%
Branch    >90%
Toggle    >90%
FSM       100%
```

---

# Assertion Coverage

```text
100%
```

---

# 11. Industry Debug Flow

Debug priority:

```text
Assertion Failure
    ↓
Waveform Analysis
    ↓
UVM Logs
    ↓
Scoreboard Mismatch
    ↓
Coverage Hole Analysis
```

---

# 12. Waveform Strategy

Waveforms used:

* WLF (Questa)
* FSDB (Verdi)
* VPD (VCS)

Monitor:

* PSEL
* PENABLE
* PREADY
* PADDR
* PWDATA
* PRDATA
* PSLVERR
* FSM state
* wait_count

---

# 13. UVM Development Order

Recommended order:

# Phase 1

* interface
* sequence item

---

# Phase 2

* driver
* monitor

---

# Phase 3

* sequencer
* agent

---

# Phase 4

* environment
* base test

---

# Phase 5

* scoreboard
* coverage

---

# Phase 6

* directed sequences

---

# Phase 7

* constrained random

---

# Phase 8

* regressions
* coverage closure

---

# 14. Industry-Level Features (Future)

Future extensions:

* RAL model
* AXI/APB bridge verification
* multi-agent environment
* protocol checker VIP
* formal verification
* low-power verification
* CDC verification
* emulation support
* portable stimulus

---

# 15. Final Industry Understanding

This project now represents:

```text
Industry-Style APB4 Slave Verification Environment
```

including:

* reusable UVM architecture
* assertions
* constrained-random verification
* functional coverage
* protocol checking
* regression flow
* verification planning
* signoff methodology

This is extremely close to real block-level verification flow used in semiconductor companies.
