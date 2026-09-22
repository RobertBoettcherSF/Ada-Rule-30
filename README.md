# Ada-Rule-30

Ada 2022 implementation of Stephen Wolfram's elementary cellular automaton [Rule 30](https://en.wikipedia.org/wiki/Rule_30).

Cells are `Bit is mod 2`. Neighborhood `(P, Q, R)` updates as `P XOR (Q OR R)` (Wolfram code `00011110`).

## Layout

```
src/rule_30.ads   public API
src/rule_30.adb   evolve variants
src/play.adb      terminal demo (BW spacetime + message box)
tests/tests.adb   unit tests
Makefile          make test | make play
```

## Terminal (`make play`)

Classic **top-seed spacetime** (like the usual Rule 30 triangle):

- Row 1 = generation 0 (single center seed — the tip never scrolls away)
- Later generations grow **downward**
- **50 columns**, **51 rows** (gens 0..50), **BW** only (`#` live, space empty)
- No color, no scale/slider

Message box under the board (outer width 50, inner text 48):

```
##################################################
#CURRENT GEN  12 / 50          RULE  30          #
#BW  fixed-zero edges  center seed  make play    #
##################################################
```

## API (`src/rule_30.ads`)

| Operation | Boundary |
|-----------|----------|
| `Evolve_Fixed_Zero` | Outside cells are `0` |
| `Evolve_Periodic` | Torus wrap (left↔right) |
| `Evolve_Expanding` | Grow one cell each side into a zero background (`Length + 2`) |
| `Evolve_And_Extract_Center` | One evolve step, then return the center bit (odd-length grid required) |

Empty grids raise `Invalid_Grid`.

## Build

```bash
make test   # unit tests
make play   # terminal demo (alias: make run)
```

## License

MIT. LLM assistance was used for this project.
