# Ada-Rule-30

Ada 2022 implementation of Stephen Wolfram's elementary cellular automaton [Rule 30](https://en.wikipedia.org/wiki/Rule_30).

Cells are `Bit is mod 2`. Neighborhood `(P, Q, R)` updates as `P XOR (Q OR R)` (Wolfram code `00011110`).

## Layout

```
src/rule_30.ads            public API
src/rule_30.adb            evolve variants
src/rule_30-terminal.ads   Rule-30 frame renderer (uses Terminal_UI)
src/rule_30-terminal.adb
src/play.adb               terminal demo
third_party/terminal_ui/   vendored Ada-Terminal-UI src/
tests/tests.adb            unit tests (incl. frame overwrite guards)
Makefile                   make test | make play | make once
```

TUI from [Ada-Terminal-UI](https://github.com/RobertBoettcherSF/Ada-Terminal-UI); update by copying `src` when upstream changes.

## Terminal (`make play`)

Classic **top-seed spacetime** (Rule 30 triangle), **BW** (`#` / space), tip at top.

**Default:** live animation at **16 generations** (`clear` before each frame).

```bash
make play              # live, 16 gens
make play GEN=40       # live, 40 gens
make live              # same as play
./bin/play             # live, 16 gens
./bin/play 30          # live, 30 gens
```

**Single frame** (no animation):

```bash
make once
make play ONCE=1
./bin/play --once
```

Do **not** write `make run --live` as a make flag — use `make play` / `make live` (live is already default), or `./bin/play --live`.

```bash
make play LIVE=1
make play GEN=40 LIVE=1
./bin/play 40 --live
```

Message box (width 50):

```
##################################################
#CURRENT GEN  50 / 50          RULE  30          #
#BW  play [N] [--live]  N=1..200  default=50     #
##################################################
```

## Tests

`make test` includes **TEST 15** for the terminal renderer:

- frame has **no ESC**
- every line is width 50
- gen-0 tip is a single center `#`
- tip survives after evolve
- re-render equals overwrite (not a stacked concat)

## API (`src/rule_30.ads`)

| Operation | Boundary |
|-----------|----------|
| `Evolve_Fixed_Zero` | Outside cells are `0` |
| `Evolve_Periodic` | Torus wrap (left↔right) |
| `Evolve_Expanding` | Grow one cell each side (`Length + 2`) |
| `Evolve_And_Extract_Center` | One step, return center bit |

## License

MIT. LLM assistance was used for this project.
