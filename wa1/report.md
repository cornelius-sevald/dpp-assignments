---
title-meta: DPP Assignment 1
author-meta: Cornelius Sevald-Krause
date-meta: ???
lang: en-GB
header-includes:
  - \usepackage{placeins}
  - \usepackage{fancyvrb}
  - \newcommand{\assoc}{\oplus}
  - \newcommand{\conj}{\vee}
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

![benchmarks of `test_process`](figures/test_process.pdf){ height=256px }

![Benchmarks of `test_process_idx`](figures/test_process_idx.pdf){ height=256px }

\FloatBarrier

Task 2
------

The code for the Hillis-Steele prefix sum is given below.
For each step in the loop, it constructs new values for certain indices and uses
scatter to update `xs` with these new values.

```futhark
def hillis_steele [n] (xs: [n]i32) : [n]i32 =
  let m = ilog2 n
  in loop xs = copy xs for d in 0...(m-1) do
    let k  = 2**d |> i64.i32
    let is = map (+k) (iota (n - k))
    let vs = map (\i -> xs[i] + xs[i-k]) is
    in scatter xs is vs
```

The code for the work-efficient prefix sum is given below.
Like Hillis-Steele, it constructs a list of new values at certain indices and
uses `scatter` to update `xs`. This is done over both a "upsweep" and
"downsweep" step. In the downsweep step, two sets of value/indices pairs are
constructed (one for the blue and black arrows and one for the red arrows from
the slides).

```futhark
def work_efficient [n] (xs: [n] i32) : [n] i32 =
  let m = ilog2 n
  let upswept =
    loop xs = copy xs for d in (m-1)..(m-2)...0 do
      let k  = 2**d       |> i64.i32
      let k' = 2**(m-d-1) |> i64.i32
      let is = map (\i -> 2*i*k' + 2*k'-1) (iota k)
      let vs = map (\i -> xs[i]+xs[i-k']) is
      in scatter xs is vs
  let upswept[n-1] = 0
  let downswept =
    loop xs = upswept for d in 0...(m-1) do
      let k   = 2**d       |> i64.i32
      let k'  = 2**(m-d-1) |> i64.i32
      let is1 = map (\i -> 2*i*k' + 2*k'-1) (iota k)
      let is2 = map (\i -> 2*i*k' +   k'-1) (iota k)
      let vs1 = map (\i -> xs[i]+xs[i-k']) is1 -- Black & blue arrows
      let vs2 = map (\i -> xs[i+k'])       is2 -- Red arrows
      let k2  = k*2 -- Can't write expression in type cast
      let is  = is1 ++ is2 :> [k2]i64
      let vs  = vs1 ++ vs2 :> [k2]i32
      in scatter xs is vs
  in downswept
```

Benchmarks comparing the Hillis-Steele, work-efficient and built-in scan is
shown below. The benchmarks were all on the `gpu04-diku-apl` machine using
openCL. (the graph was plotted on my own machine as the ones generated on GPU04
looked weird).

\FloatBarrier

![benchmarks of prefix sums](figures/prefix-sum.pdf){ height=256px }

\FloatBarrier

While it's not easy to eyeball from the graph if the Hillis-Steele algorithm
follows a $O( n \log n)$ curve it is clear that the runtime of the Hillis-Steele
algorithm grows faster than the runtime of the work-efficient algorithm as the
input size grows, which would suggest that the work-efficient algorithm has a
better asymptotic runtime (or at least better constants w.r.t scaling).

They are both, however, much slower than the built-in scan.

Task 3
------

### Exercise 3.1

We inline the definitions of $\assoc'$ in the following two expressions:

\begin{align}
    \left( (v_1,f_1) \assoc' (v_2,f_2) \right) \assoc' (v_3,f_3)         \\
    (v_1,f_1)        \assoc' \left( (v_2,f_2)  \assoc' (v_3,f_3) \right)
\end{align}

\vspace{1em}

\begin{Verbatim}[frame=single
                ,framesep=2mm
                ,label=$(1)$
                ,labelposition=topline
                ,commandchars=\\\{\},
                ,codes={\catcode`$=3\catcode`^=7}]
(if f3 then v3 else
       (if f2 then v2 else v1 $\assoc$ v2) $\assoc$ v3
,(f1 $\conj$ f2) $\conj$ f3)
\end{Verbatim}

\vspace{1em}

\begin{Verbatim}[frame=single
                ,framesep=2mm
                ,label=$(2)$
                ,labelposition=topline
                ,commandchars=\\\{\},
                ,codes={\catcode`$=3\catcode`^=7}]
(if f2 $\conj$ f3 then (if f3 then v3 else v2 $\assoc$ v3)
            else v1 $\assoc$ (if f3 then v3 else v2 $\assoc$ v3)
,f1 $\conj$ (f2 $\conj$ f3))
\end{Verbatim}

As the $\conj$ operator is associative it is trivial that
$(f_1 \conj f_2) \conj f_3 = f_1 \conj (f_2 \conj f_3)$ i.e. the second elements
of (1) and (2) are equal.

For the first elements, we enumerate all of the possible cases. One thing to
notice is that $f_1$ does not show up in the first elements of $(1)$ and $(2)$,
so we only have to enumerate four cases.

\begin{enumerate}
    \item $f_2$ and $f_3$ are both \texttt{false}: \\
        In this case, for (1) we get $(v_1 \assoc v_2) \assoc v_3$
        and for (2) we get $v_1 \assoc (v_2 \assoc v_3)$.
        As $\assoc$ is associative, these are equal.
    \item $f_2$ is \texttt{true} and $f_3$ is \texttt{false}: \\
        For (1) the inner if-statement holds and we get $v_2 \assoc v_3$.
        For (2) the outer if-statement holds and the innder doesn't,
        so we also get $v_2 \assoc v_3$.
    \item $f_2$ is \texttt{false} and $f_3$ is \texttt{true}: \\
        For (1) the outer if-statement holds and we get $v_3$.
        For (2) the outer and inner if-statements hold and we also get $v_3$.
    \item $f_2$ and $f_3$ are both \texttt{true}: \\
        Just like in case 3,
        for (1) the outer if-statement holds so we get $v_3$ and
        for (2) the outer and inner if-statements hold and we also get $v_3$.
\end{enumerate}
