---
title-meta: DPP Assignment 1
author-meta: Cornelius Sevald-Krause
date-meta: ???
lang: en-GB
header-includes:
  - \usepackage{placeins}
---

DPP Assignment 1
=================

By: Cornelius Sevald-Krause `<lgx292>`  
Due: ???

Task 1
------

The `process` and `process_idx` functions are shown below:

```futhark
def process [n] (xs: [n]i32) (ys: [n]i32) : i32 =
  let ds = map2 (\x y -> i32.abs (x - y)) xs ys
  in reduce i32.max 0 ds
```

```futhark
def process_idx [n] (xs: [n]i32) (ys: [n]i32) : (i32,i64) =
  let ds = map2 (\x y -> i32.abs (x - y)) xs ys
  let is = iota n
  let op (x,ix) (y,iy) =
    if      x  > y  then (x,ix)
    else if y  > x  then (y,iy)
    else if ix > iy then (x,ix)
    else                 (y,iy)
  in zip ds is |> reduce_comm op (0,-1)
```

The result of the `process` function on `s1` and `s2` is `73i32` as the 11'th
element has the largest absolute difference (4 vs. 77). As expected, the result
of `process_idx` is `(73i32, 12i64)`.

The benchmarks for the two functions are shown below.
Both benchmarks were done on the `gpu04-diku-apl` machine.

![Benchmarks of `test_process`](figures/test_process.pdf){ height=256px }

![Benchmarks of `test_process_idx`](figures/test_process_idx.pdf){ height=256px }

\FloatBarrier
