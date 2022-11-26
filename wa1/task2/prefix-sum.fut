-- ==
-- entry: test_hillis_steele test_work_efficient test_scan
-- random input { [32768]i32 }
-- random input { [65536]i32 }
-- random input { [131072]i32 }
-- random input { [262144]i32 }
-- random input { [524288]i32 }
-- random input { [1048576]i32 }
-- random input { [2097152]i32 }
-- random input { [4194304]i32 }
-- random input { [8388608]i32 }
-- random input { [16777216]i32 }

def ilog2 (x: i64) = 63 - i64.clz x

def hillis_steele [n] (xs: [n]i32) : [n]i32 =
  let m = ilog2 n
  in loop xs = copy xs for d in 0...(m-1) do
    let k  = 2**d |> i64.i32
    let is = map (+k) (iota (n - k))
    let vs = map (\i -> xs[i] + xs[i-k]) is
    in scatter xs is vs

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

-- `scan` specialized to summation of i32 values
def scan_i32 [n] (xs: [n] i32) : [n] i32 = scan (+) 0 xs

entry test_hillis_steele = hillis_steele
entry test_work_efficient = work_efficient
entry test_scan = scan_i32
