# APB4 RTL + UVM

# 1. Introduction

This document serves as a complete industry-oriented development and verification guide for an APB4-compliant slave design and its UVM verification environment.

The objective is to:

- Design a protocol-correct APB4 RTL slave
- Handle all legal APB4 protocol scenarios
- Handle protocol corner cases
- Support wait states
- Support byte strobes
- Support protection logic
- Build a reusable industry-style UVM environment
- Achieve protocol, functional, and code coverage closure
- Enable assertion-based verification

---

# 3. RTL Features

- FSM
- wait states
- PREADY
- PSTRB
- PSLVERR
- PPROT
- protected registers
- assertions
- parameterization
- reusable write helpers

---

# 4. APB Protocol Rules

RULE 1: 
SETUP phase lasts exactly one cycle.

RULE 2: 
ACCESS phase starts only after SETUP.

Rule 3:
PENABLE asserted only during ACCESS.

Rule 4:
Signals remain stable during wait states.
Stable signals are:
- PADDR
- PWRITE
- PWDATA
- PSTRB
- PPROT
- PSEL

Rule 5:
Transfer completes only when:

```text
PSEL && PENABLE && PREADY
```

Rule 6:
PSLVERR valid only during completion cycle.

Rule 7:
PSTRB must be 0 during READ transfers.


---

# 7. Assertions

The APB4 slave includes SystemVerilog Assertions (SVA) to validate protocol correctness, FSM behavior, timing compliance, and error handling during simulation.

Assertions help detect protocol violations automatically and improve debug efficiency in verification environments.

---

## PENABLE Requires PSEL

Ensures that the ACCESS phase signal `PENABLE` is never asserted unless the slave is selected using `PSEL`.

This validates correct APB phase sequencing and prevents illegal ACCESS cycles.

---

## SETUP To ACCESS Transition

Checks that every valid SETUP phase transitions into ACCESS phase on the following clock cycle.

This verifies proper APB transaction progression.

---

## Stable Signals During Wait States

Ensures that address, control, protection, and write-data signals remain stable while the slave inserts wait states (`PREADY = 0`).

This validates APB protocol compliance during stalled transfers.

---

## PSLVERR Validity

Verifies that `PSLVERR` is asserted only during a valid transfer completion cycle.

This prevents illegal or asynchronous error signaling.

---

## ACCESS State Requires PENABLE

Checks that whenever the internal FSM enters ACCESS state, the protocol signal `PENABLE` is asserted.

This validates consistency between FSM state and external APB signaling.

---

## SETUP State Requires PENABLE Low

Ensures that `PENABLE` remains low during SETUP phase.

This validates correct APB timing behavior before entering ACCESS phase.

---

## PSTRB Validity During Reads

Checks that byte strobes (`PSTRB`) remain zero during read transfers.

Since byte strobes are only meaningful for writes, this validates correct APB4 usage.

---

## Transfer Completion Exit Check

Ensures that after a successful transfer completion, the FSM exits ACCESS state and transitions either to IDLE or the next SETUP phase.

This validates correct transfer termination behavior.

---

## PREADY Only During ACCESS

Checks that `PREADY` is asserted only while the slave is in ACCESS phase.

This prevents illegal ready signaling outside valid transfer windows.

---

## Illegal Write To Read-Only Registers

Verifies that writes to read-only registers generate `PSLVERR`.

This validates register access protection and error response handling.
---

# 8. UVM Responsibilities

## Driver
Acts as APB master.

Driver:
- generates APB protocol
- drives SETUP phase
- drives ACCESS phase
- waits for PREADY
- handles wait states

## Monitor
- samples completed transfers
- checks timing
- collects transactions

Completion condition:

```text
PSEL && PENABLE && PREADY
```

## Scoreboard
- checks register behavior
- validates reads/writes
- validates byte strobes
- validates error behavior

## Coverage
- protocol coverage
- address coverage
- wait-state coverage
- PSTRB coverage
- PPROT coverage
- error coverage

---

# 9. Directed Test Plan

## Basic Tests
- write test
- read test
- read/write mix
- back-to-back transfers

## Wait-State Tests
- fixed waits
- random waits
- long waits

## PSTRB Tests
- byte update
- halfword update
- sparse updates
- full updates

## PPROT Tests
- secure accesses
- privileged accesses
- illegal accesses

## Error Tests
- invalid address
- PSLVERR generation
- RO register write

## Reset Tests
- reset during transfer
- reset during wait
- reset recovery

## Random Tests
- constrained random traffic
- random waits
- random strobes
- random protection combinations

---

# 10. Coverage Goals

## Functional Coverage
```text
>95%
```

## Code Coverage
```text
Statement >95%
Branch    >90%
Toggle    >90%
FSM       100%
```


