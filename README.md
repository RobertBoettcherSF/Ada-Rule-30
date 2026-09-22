# Ada-Rule-30

Ada 2022 implementation of Stephen Wolfram's elementary cellular automaton [Rule 30](https://en.wikipedia.org/wiki/Rule_30).

Cells are `Bit is mod 2`. Neighborhood `(P, Q, R)` updates as `P XOR (Q OR R)` (Wolfram code `00011110`).

## Layout

```
src/rule_30.ads            public API
src/rule_30.adb            evolve variants
src/rule_30-terminal.ads   clean frame renderer (no ANSI)
src/rule_30-terminal.adb
src/play.adb               terminal demo
tests/tests.adb            unit tests (incl. frame overwrite guards)
Makefile                   make test | make play
```

## Terminal (`make play`)

Classic **top-seed spacetime** (Rule 30 triangle), **BW** (`#` / space), tip at top.

**Default (Linux Mint safe):** evolve fully, then print **exactly one** frame.
No cursor/clear escapes — avoids the stacked-scroll dump when the terminal
ignores `ESC[H` / `ESC[2J`.

```bash
make play              # 50 gens, one final picture
make play GEN=80       # 80 gens
./bin/play 30          # same
```

**Optional animation** (only if your TTY honors clear/home):

```bash
make live
make live GEN=40
make play LIVE=1
./bin/play 40 --live
```

Do **not** write `make run --live` — GNU make treats `--live` as its own
option and never starts `play`.

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
