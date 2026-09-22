# Ada-Rule-30

Ada 2022 implementation of Stephen Wolfram's elementary cellular automaton [Rule 30](https://en.wikipedia.org/wiki/Rule_30).

Cells are `Bit is mod 2`. Neighborhood `(P, Q, R)` updates as `P XOR (Q OR R)` (Wolfram code `00011110`).

## Layout

```
src/rule_30.ads   public API
src/rule_30.adb   evolve variants
src/play.adb      terminal demo (20×50 board + message box)
tests/tests.adb   unit tests
Makefile          make test | make play
```

## Terminal (`make play`)

Fills a plain terminal with:

- **20 rows × 50 characters** — scrolling view of the last generations (`#` = live, space = empty)
- **Message box** under the board (outer width 50, inner text 48):

```
##################################################
#48 characters of status text...................#
#48 characters of help text.....................#
#48 characters of footer........................#
##################################################
```

Default run: center seed, fixed-zero edges, **60 generations**, ~80 ms per step.

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
