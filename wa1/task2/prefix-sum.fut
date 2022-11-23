def ilog2 (x: i64) = 63 - i64.clz x

def hillis_steele [n] (xs: [n]i32) : [n]i32 =
  let m = ilog2 n
  in loop xs = copy xs for d in 0...(m-1) do
    map (\i ->
      let j = i32.i64 i - 2**d
       in if j < 0 then xs[i] else xs[i] + xs[j]
    ) (iota n)

def work_efficient [n] (xs: [n] i32) : [n] i32 =
  let m = ilog2 n
  let upswept =
    loop xs = copy xs for d in (m-1)..(m-2)...0 do
      let k = 2**(m - d - 1) |> i64.i32
      let p i = (i + 1) % (2*k) == 0
      in map (\i ->
         if p i then xs[i-k] + xs[i] else xs[i]
      ) (iota n)
  let upswept[n-1] = 0
  let downswept =
    loop xs = upswept for d in 0...(m-1) do
      let k = 2**(m - d - 1) |> i64.i32
      let p i = (i + 1) % (2*k) == 0
      let p' i = (i + 1) % k == 0
      in map (\i ->
         if p  i then xs[i-k] + xs[i] else
         if p' i then xs[i+k] else xs[i]
      ) (iota n)
  in downswept
