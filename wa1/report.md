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
def process (xs: []i32) (ys: []i32): i32 =
  reduce i32.max 0 (map i32.abs (map2 (-) xs ys))
```

```futhark
def process_idx [n] (xs: [n]i32) (ys: [n]i32): (i32,i64) =
  let max (d1,i1) (d2,i2) =
        if      d1 > d2 then (d1,i1)
        else if d2 > d1 then (d2,i2)
        else if i1 > i2 then (d1,i1)
        else                 (d2,i2)
  in reduce_comm max (0, -1)
                 (zip (map i32.abs (map2 (-) xs ys))
                      (iota n))
```

The result of the `process` function on `s1` and `s2` is `73i32` as the 11'th
element has the largest absolute difference (4 vs. 77). As expected, the result
of `process_idx` is `(73i32, 12i64)`.

The benchmarks for the two functions are shown below.
Both benchmarks were done on the `gpu04-diku-apl` machine.

![Benchmarks of `test_process`](test_process.pdf){ height=256px }

![Benchmarks of `test_process_idx`](test_process_idx.pdf){ height=256px }

\FloatBarrier
