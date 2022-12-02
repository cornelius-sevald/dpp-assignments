-- We represent a spin as a single byte.  In principle, we need only
-- two values (-1 or 1), but Futhark represents booleans a a full byte
-- entirely, so using an i8 instead takes no more space, and makes the
-- arithmetic simpler.
type spin = i8

import "lib/github.com/diku-dk/cpprandom/random"

-- Pick an RNG engine and define random distributions for specific types.
module rng_engine = minstd_rand
module rand_f32 = uniform_real_distribution f32 rng_engine
module rand_i8 = uniform_int_distribution i8 rng_engine

-- We can create an few RNG state with 'rng_engine.rng_from_seed [x]',
-- where 'x' is some seed.  We can split one RNG state into many with
-- 'rng_engine.split_rng'.
--
-- For an RNG state 'r', we can generate random integers that are
-- either 0 or 1 by calling 'rand_i8.rand (0i8, 1i8) r'.
--
-- For an RNG state 'r', we can generate random floats in the range
-- (0,1) by calling 'rand_f32.rand (0f32, 1f32) r'.
--
-- Remember to consult
-- https://futhark-lang.org/pkgs/github.com/diku-dk/cpprandom/latest/

let rand = rand_f32.rand (0f32, 1f32)

-- Create a new grid of a given size.  Also produce an identically
-- sized array of RNG states.
let random_grid (seed: i32) (h: i64) (w: i64)
              : ([h][w]rng_engine.rng, [h][w]spin) =
  let init_rng      = rng_engine.rng_from_seed [seed]
  let rngs          = rng_engine.split_rng (h*w) init_rng
  let (rngs',spins) = map (rand_i8.rand (0i8, 1i8)) rngs |> unzip
  -- turn zeros into minus ones
  let spins'        = map (\c -> c*2-1) spins
  in (unflatten h w rngs', unflatten h w spins')

-- Compute $\Delta_e$ for each spin in the grid, using wraparound at
-- the edges.
let deltas [h][w] (spins: [h][w]spin): [h][w]i8 =
  -- Get the neighbors by rotating the 'spin' array
  let uSpins = rotate (-1) spins
  let dSpins = rotate   1  spins
  let lSpins = map (rotate (-1)) spins
  let rSpins = map (rotate   1)  spins
  in map5 (map5 (\c u d l r -> 2*c*(u+d+l+r))) spins uSpins dSpins lSpins rSpins

-- The sum of all deltas of a grid.  The result is a measure of how
-- ordered the grid is.
let delta_sum [h][w] (spins: [w][h]spin): i32 =
  flatten spins |> reduce (+) 0 |> i32.i8

-- Take one step in the Ising 2D simulation.
let step [h][w] (abs_temp: f32) (samplerate: f32)
                (rngs: [h][w]rng_engine.rng) (spins: [h][w]spin)
              : ([h][w]rng_engine.rng, [h][w]spin) =
  -- Generate random numbers
  let rngs_f = flatten rngs
  let (rngs_f',  as) = map rand rngs_f  |> unzip
  let (rngs_f'', bs) = map rand rngs_f' |> unzip
  -- The random numbers where flattened, we need to un-flatten them again
  let as' = unflatten h w as
  let bs' = unflatten h w bs
  -- Calculate the deltas and cast them to floats
  let ds = deltas spins |> map (map f32.i8)
  -- The 'update_cell' function updates a single cell
  let update_cell p t c a b d =
    if a < p && (d < (-d) || b < f32.exp ((-d) / t))
    then -1*c else c
  -- Compute the new spins
  let new_spins = map4 (map4 (update_cell samplerate abs_temp)) spins as' bs' ds
  in (unflatten h w rngs_f'', new_spins)

-- | Just for benchmarking.
let main (abs_temp: f32) (samplerate: f32)
         (h: i64) (w: i64) (n: i32): [h][w]spin =
  (loop (rngs, spins) = random_grid 1337 h w for _i < n do
     step abs_temp samplerate rngs spins).1

-- ==
-- entry: main
-- input { 0.5f32 0.1f32 10i64 10i64 2 } auto output

-- The following definitions are for the visualisation and need not be modified.

type~ state = {cells: [][](rng_engine.rng, spin)}

entry tui_init seed h w : state =
  let (rngs, spins) = random_grid seed h w
  in {cells=map (uncurry zip) (zip rngs spins)}

entry tui_render (s: state) = map (map (.1)) s.cells

entry tui_step (abs_temp: f32) (samplerate: f32) (s: state) : state =
  let rngs = (map (map (.0)) s.cells)
  let spins = map (map (.1)) s.cells
  let (rngs', spins') = step abs_temp samplerate rngs spins
  in {cells=map (uncurry zip) (zip rngs' spins')}

-- ==
-- entry: test_ising
-- input { 100i64 }
-- input { 1000i64 }
-- input { 10000i64 }
-- input { 100000i64 }
-- input { 1000000i64 }
entry test_ising (N: i64) : [][]spin =
  let s = f32.i64 N |> f32.sqrt |> i64.f32
  in main 0.5f32 0.1f32 s s 10
