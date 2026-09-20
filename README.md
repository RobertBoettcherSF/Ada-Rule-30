# Ada-Rule-30

Ada 2022 implementation of Stephen Wolfram's elementary cellular automaton [Rule 30](https://en.wikipedia.org/wiki/Rule_30).

Cells are `Bit is mod 2`. Neighborhood `(P, Q, R)` updates as `P XOR (Q OR R)` (Wolfram code `00011110`).

## API (`rule_30.ads`)

| Operation | Boundary |
|-----------|----------|
| `Evolve_Fixed_Zero` | Outside cells are `0` |
| `Evolve_Periodic` | Torus wrap (left↔right) |
| `Evolve_Expanding` | Grow one cell each side into a zero background (`Length + 2`) |
| `Evolve_And_Extract_Center` | One evolve step, then return the center bit (odd-length grid required) |

Empty grids raise `Invalid_Grid`. Pre/Post/`Global => null` contracts are on the public ops.

`Evolve_And_Extract_Center` mirrors the classic Mathematica-style center-column sampler. It is **not** a cryptographic PRNG.

## Build

```bash
make test
```

## Tests

- Rule table / deterministic neighborhoods for `00011110`
- Empty grid → `Invalid_Grid`
- Odd-length center extract
- Small / single-cell / expanding cases

## SI

None. Discrete bits only. Optional later: `Generation_Count` as dimensionless steps.

## License

MIT. LLM assistance was used for this project.
