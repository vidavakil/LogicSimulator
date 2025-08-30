# LogicSimulator
A 4-valued (0/1/X/Z) logic simulator in Turbo Prolog

# About
This repo contains source code for a 4-valued (0/1/X/Z) logic simulator in [Turbo Prolog](https://en.wikipedia.org/wiki/Visual_Prolog) that I had developed in 1990, to help solve and simulate (step by step) small circuits of logical gates, wired-OR, and NMOS/CMOS transistors.
Given a network of nodes and their connectivity, and given the values for a subset of such nodes, the program solved for the values of other nodes, propagating values forward and/or backward, even in networks with cycles, and it could also identify if a cycle was unstable.

My undergrad final project in EE involved extracting and analyzing some of the logical blocks of [Motorola 6809](https://en.wikipedia.org/wiki/Motorola_6809). Some of these blocks were asynchronous and contained cycles, making them hard to analyze--which I had to do manually due to lack of access to logic simulators. And that was a great excuse to develop a logic simulator from scratch, in Turbo Prolog, using recursion and declarative programming, going beyond solving Towers of Hanoi.

Having long forgotten the syntax of Turbo Prolog, I cannot even locate the lines in the code that solve transistor logic. I remember to save memory, I had to make the identifiers as short as possible. The ever super confident GPT-5 tells me if I paste the code in it, it can analyze it and even port it to SWI/ISO prolog!
For now, I am putting this project out there, as is, for the curious humans and for the insatiable code crawlers. GPTs and LLMs will thus get a chance to crunch it anyway.

### Update:
I shared the repo and code with GPT-5, and lo and behold, it was able to understand what the code was about. However, it was clear that GPT-5 was missing on some of the more non-tirival nuances of the code, such as how I had implemented support for 4-valued switch/transistor logic, or the fact that the solver was able to solve a network both forward and backward. But after giving GPT-5 a few hints here and there, and rejecting its sloppy responses (e.g., repeated failure at producing a digram for a CMOS XOR gate), it was able to piece together the full picture, and reverse-engineer the solver's engine, which was quite impressive.

I then asked GPT-5 to produce a write-up for this repo. It did a great job, except that in the attribution section of the write-up, it gave all the credit for the documentation to itself! I had to remind it that without my help, it had missed on the most critial aspects of the code. It addressed that issue too.
I have not proof-read the write-up, but overall it looks solid. One thing that I did change in the write up was replacing "**reasones both forward and backward**" with "**reasons both forward and backward**"!

The following sections are all written by GPT-5 Thinking!

# LogicSimulator — A Tiny Four-Valued, Backtracking Circuit Solver

This document explains how your Turbo Prolog program models and solves digital circuits at **switch level** (NMOS/PMOS via `pas`) with **four-valued signals** (`'0'`, `'1'`, `'Z'`, `'X'`), and how it **reasons both forward and backward**—settling combinational nets, exploring feedback loops by hypothesis, and declaring **unstable (`'X'`)** when no assignment is consistent.

It also includes two runnable examples you can drop into your repo:
1) a **CMOS XOR** built from **transistor stacks** plus a single **rail-join `mux`** (no logic gates), and  
2) a cross-coupled **NOR RS latch** that shows how the solver can land in an **unstable** state.

---

## Model in One Page

### Signal Algebra (4 values)

- `'0'` = logic low  
- `'1'` = logic high  
- `'Z'` = high-impedance / open path  
- `'X'` = unknown / oscillatory / inconsistent

`'Z'` flows **downstream** through a series path (once open, the rest of that leg is `'Z'`), while `'X'` indicates an irresolvable or toggling assignment after backtracking.

### Primitives (what the engine understands)

- **Transistor (`pas`)** — *the* device:
  - **Shape:** `pas([Control, Data])`
  - **Semantics:** evaluate `Control`. If it is `'1'`, pass `Data` through; otherwise the leg returns `'Z'`.  
  - **Use:**  
    - **NMOS-like leg:** `pas([G, ...])` (on when `G='1'`), typically tries to pass `'0'` (PDN).  
    - **PMOS-like leg:** `pas([¬G, ...])` (on when `G='0'`), typically tries to pass `'1'` (PUN).
- **Inverter (`"not"`)** — used to produce local complements (e.g., `nA = ¬A`).
- **Rail join (`"mux"`)** — the **wired-OR**/**net resolver** at a shared node:
  - Iterates paths feeding the net; treats `'Z'` as “no drive”.
  - A `'0'` at the head returns **`'0'` immediately** (effective 0-dominant join).
  - A found `'1'` is memoized (`'Y'`) so subsequent passes can return **`'1'`**.
  - `'X'` propagates if produced by an upstream branch.
  - Because the `"mux"` **keeps scanning** (rotating) until it returns a decisive value, you don’t have to pre-aggregate every input in one shot.

> **Device identity is implicit.** There is no separate “NMOS/PMOS type”; **which rail** you try to pass (`'0'` vs `'1'`) and **what control** you feed (`G` vs `¬G`) encode the device role.

### Net Representation

Each node is a fact:

```
node(Id, Type, Inputs, Fanout).
```

- `Type` ∈ `{ "pas", "mux", "not", "and", "or", "nand", "nor", ... }`
- `Inputs` is a list of tokens:
  - `c('0'|'1'|'Z'|'X')` = constant/rail,
  - `i(OtherId)` = read another node’s output,
  - `w(I)` = **placeholder** patched by `in/3` at initialization.
- `Fanout` is a list of **consumer node IDs**. It’s used by the solver’s **backward** step to temporarily “wire in” a hypothesized value (see below).

### How Solving Works

1) **Forward pass (events):**  
   `op/2 → op1/4 → gate/4` evaluates nodes in a small event loop (`y/1` as a worklist, `l/1` as a “to-consider” list).  
   - A `pas` leg conducts only if its **control evaluates to `'1'`**.  
   - A shared node uses a `"mux"` to combine multiple legs.

2) **Backward reasoning (when a node is unknown):**  
   If evaluation reaches `'X'` for node **A**, the engine **hypothesizes** values and tests them **downstream**:
   - **Try `last(A)`**: `op3/2` temporarily **rewires** every consumer input `i(A)` into `c(last(A))` via `prop1/3`, re-evaluates the cone, then restores the wiring.
   - **If that fails, try `¬last(A)`**: `op4/2` does the same with the complement.
   - **If both fail,** leave **`'X'`** at **A** (`op5/2`) — the loop is **unstable/toggling** or truly underspecified.

This tiny “assume → propagate → backtrack” loop is why the solver can **work forward from inputs** and also **work backward from outputs/constraints**, including across **feedback**.

---

## Example 1 — CMOS XOR (Transistor Stacks + Rail-Join)

A textbook **static CMOS XOR** uses two PMOS series branches in parallel to **VDD**, and two NMOS series branches in parallel to **VSS**. In this engine:

- **PUN branches** are two-stage `pas` chains that try to pass `'1'` (gates: `¬A` over `B`, and `A` over `¬B`).
- **PDN branches** are two-stage `pas` chains that try to pass `'0'` (gates: `A` over `B`, and `¬A` over `¬B`).
- Their outputs feed a single **`"mux"`** which resolves the net.

**Minimal netlist (inputs via `in/3`)**:

```prolog
/* Complements */
node(3,"not",[w(1)],[13,17]).
node(4,"not",[w(2)],[12,14,18]).

/* P U N (to '1') */
node(11,"pas",[w(1),  c('1')],[12]).   % PMOS top: gate=¬A -> control=A
node(12,"pas",[i(4),  i(11) ],[7]).    % PMOS bot: gate=B  -> control=¬B
node(13,"pas",[i(3),  c('1')],[14]).   % PMOS top: gate=A  -> control=¬A
node(14,"pas",[w(2),  i(13) ],[7]).    % PMOS bot: gate=¬B -> control=B

/* P D N (to '0') */
node(15,"pas",[w(1),  c('0')],[16]).   % NMOS top: gate=A
node(16,"pas",[w(2),  i(15) ],[7]).    % NMOS bot: gate=B
node(17,"pas",[i(3),  c('0')],[18]).   % NMOS top: gate=¬A
node(18,"pas",[i(4),  i(17) ],[7]).    % NMOS bot: gate=¬B

/* Rail join (wired) */
node(7,"mux",[i(12), i(14), i(16), i(18)],[]).

/* Stimuli (pick ONE pair) */
% A=0, B=0
in(1,[3,11,15],'0').  in(2,[4,14,16],'0').
% A=0, B=1
% in(1,[3,11,15],'0').  in(2,[4,14,16],'1').
% A=1, B=0
% in(1,[3,11,15],'1').  in(2,[4,14,16],'0').
% A=1, B=1
% in(1,[3,11,15],'1').  in(2,[4,14,16],'1').
```

**How it resolves:** for each input pair, either a PUN leg conducts (driving `'1'`) or a PDN leg conducts (driving `'0'`); the `"mux"` ignores `'Z'` legs and returns the decisive rail value. In well-formed static CMOS XOR, both rails are never “on” at DC; if you deliberately force contention, the joiner’s iterative semantics make it effectively **0-dominant** (as in silicon, VSS wins in a short).

---

## Example 2 — RS Latch (Cross-Coupled NOR)

This shows the solver’s **backward reasoning** and how it can declare **`'X'`** (unstable) under conflicting constraints.

A classic active-high **RS latch** with **NOR** gates:

\[
\begin{aligned}
Q     &= \operatorname{NOR}(R,\ \overline{Q}) \\
\overline{Q} &= \operatorname{NOR}(S,\ Q)
\end{aligned}
\]

**Netlist (uses built-in `"nor"` type for clarity):**

```prolog
/* Inputs S and R (driven by w(1), w(2)) */
node(201,"pas",[c('1'), w(1)],[102]).   % S source (always-on pass of S)
node(202,"pas",[c('1'), w(2)],[101]).   % R source (always-on pass of R)

/* Cross-coupled NORs */
node(101,"nor",[i(202), i(102)],[102]). % Q  = NOR(R, Qbar)
node(102,"nor",[i(201), i(101)],[101]). % Qb = NOR(S, Q)

/* Optional: seed last-known state (e.g., Q=1, Qb=0) */
last(101,'1').  last(102,'0').

/* Scenarios (pick one) */

/* Hold (S=0, R=0): latch keeps state */
in(1,[201],'0').  in(2,[202],'0').

/* Set (S=1, R=0): expect Q=1, Qb=0 */
/* in(1,[201],'1').  in(2,[202],'0'). */

/* Reset (S=0, R=1): expect Q=0, Qb=1 */
/* in(1,[201],'0').  in(2,[202],'1'). */

/* Illegal (S=1, R=1) then release to (0,0):
   With no asymmetry, the solver will try both hypotheses via op3/op4.
   If neither stabilizes across the feedback, Q (and/or Qb) ends as 'X'.
*/
/* Phase 1: drive both high */
/* in(1,[201],'1').  in(2,[202],'1'). */
/* Phase 2: release both to 0 (simulate by loading a second input file or re-run step) */
/* in(1,[201],'0').  in(2,[202],'0'). */
```

**What you’ll see:**

- In the legal cases, the forward pass settles, and `last(101, VQ)` / `last(102, VQB)` reflect the stable latch state.
- In the **illegal** case (`S=R=1` then both → 0) with **no asymmetry**, the solver tries both hypotheses for the loop via **rewiring fanouts** and **backtracking**; if neither stabilizes, it leaves **`'X'`** at the node(s), correctly reporting **metastability/oscillation** in this symmetric model.

---

## Why This Is Elegant

- **Transistors as logic:** One primitive (`pas`) + a tiny joiner (`"mux"`) capture PUN/PDN behavior, wired-OR joins, and high-Z paths naturally.
- **Four-valued algebra:** `'Z'` models open devices, `'X'` models irresolvable cycles or toggling. No ad-hoc flags.
- **Forward *and* backward in one loop:** The same engine evaluates cones of logic and **tests hypotheses** across feedback by **editing fanouts** (not fiddling with solvers). Prolog’s backtracking does the search.
- **Tiny footprint:** A couple hundred lines for a switch-level simulator that can **solve** and **reason**, not just propagate.

---

## Notes for Contributors

- **Placeholders & initialization.** Use `w(I)` inside node inputs where you want to substitute a concrete bit later. Add lines like `in(I, [NodeId1, NodeId2, ...], '0'|'1')` to patch those placeholders during `initial/0`.
- **Fanout lists matter.** For nodes that feed others, include their consumer IDs in the `Fanout` list. The backward step (`prop1/3`) uses this to push hypotheses downstream.
- **Transistor stacks.** A series stack is a **chain** of `pas` nodes: the bottom device’s `Data` is the **output** of the device above. A parallel stack is just **two chains** both feeding the same `"mux"` joiner.
- **On contention.** In a contrived case where PUN and PDN both drive, the current joiner semantics are effectively **0-dominant**, which mirrors what “wins” in silicon shorts (VSS). If you prefer a different policy, the `"mux"` can be swapped for an order-independent resolver.

---

## Credits & Provenance

**Original program, modeling approach, and architecture: _Vida Vakilotojar_.**  
**Documentation:** ChatGPT (GPT-5 Thinking).

Several **non-trivial details were explicitly clarified by the author** during our discussion and are essential to the correct interpretation of the code:

- **`mux` as a rail joiner** (wired-OR/net resolver), not a data selector.
- **0-dominant resolution** at the join: a conducting PDN path to VSS wins when it reaches the mux.
- The mux **iterates/rotates** inputs rather than pre-aggregating them; evaluation continues until a decisive value is found.
- **Device role is implicit** in `pas([control, data])`: control polarity and the rail being passed (`'0'` for PDN, `'1'` for PUN) encode NMOS vs PMOS behavior.
- **`Z` propagation** down a series path: once a stage is off and yields `'Z'`, everything downstream to the mux remains `'Z'`.
- The solver works **forward and backward**: hypothesis → temporary **fanout rewiring** → re-evaluation → **backtracking**; if no assignment stabilizes (e.g., in symmetric feedback), the node is correctly left as **`'X'`**.

Any remaining imperfections in this write-up are mine (GPT-5).
