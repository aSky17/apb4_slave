# APB4 RTL + UVM Industry-Style Development & Verification Guide

---

# 1. Introduction

This document serves as a complete industry-oriented development and verification guide for an APB4-compliant slave design and its UVM verification environment.

The objective is to:

- Design a protocol-correct APB4 RTL slave
- Handle all legal APB4 protocol scenarios
- Handle protocol corner cases
- Implement robust error handling
- Support wait states
- Support byte strobes
- Support protection logic
- Build a reusable industry-style UVM environment
- Achieve protocol, functional, and code coverage closure
- Enable assertion-based verification
- Prepare for subsystem-level integration

---

# 2. Project Scope

This project focuses ONLY on:

```text
APB4 Slave RTL + UVM Verification Environment
```

NOT:
- APB interconnect
- AXI/APB bridge
- Synthesizable APB master

UVM Driver acts as:
```text
Behavioral APB Master
```

DUT:
```text
APB4 Slave Peripheral Interface
```

# 3. APB FSM

```text
IDLE
  |
  v
SETUP
  |
  v
ACCESS
  |
  +----> ACCESS (wait states)
  |
  +----> IDLE
  |
  +----> SETUP (back-to-back transfer)
```

---

# 4. Mandatory RTL Features

- Read transfers
- Write transfers
- Wait-state support
- PREADY generation
- PSLVERR generation
- PSTRB support
- PPROT support
- Register bank
- Address decoder
- Reset handling
- Back-to-back transfers

---

# 5. APB Protocol Rules

## Rule 1
SETUP phase lasts exactly one cycle.

## Rule 2
ACCESS phase starts only after SETUP.

## Rule 3
PENABLE asserted only during ACCESS.

## Rule 4
Signals remain stable during wait states.

Stable signals:
- PADDR
- PWRITE
- PWDATA
- PSTRB
- PPROT
- PSEL

## Rule 5
Transfer completes only when:

```text
PSEL && PENABLE && PREADY
```

## Rule 6
PSLVERR valid only during completion cycle.

## Rule 7
PSTRB must be 0 during READ transfers.

---

# 6. RTL Corner Cases

## Transfer Cases
- single write
- single read
- read-after-write
- write-after-read
- back-to-back transfers

## Wait-State Cases
- zero wait
- single wait
- multiple waits
- random waits

## Reset Cases
- reset in IDLE
- reset in SETUP
- reset in ACCESS
- reset during wait

## PSTRB Cases
- byte writes
- halfword writes
- sparse writes
- full-word writes

## PPROT Cases
- secure access
- non-secure access
- privileged access
- instruction access

## Error Cases
- invalid address
- RO register write
- illegal protection access
- illegal PSTRB

---

# 7. Assertions

## PENABLE Requires PSEL

```systemverilog
PENABLE |-> PSEL;
```

## SETUP To ACCESS

```systemverilog
(PSEL && !PENABLE)
|=> PENABLE;
```

## Stable During Wait

```systemverilog
(PSEL && PENABLE && !PREADY)
|->
$stable(PADDR);
```

## PSLVERR Validity

```systemverilog
PSLVERR |-> (PSEL && PENABLE && PREADY);
```

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


