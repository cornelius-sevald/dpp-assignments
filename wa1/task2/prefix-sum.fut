def ilog2 (x: i64) = 63 - i64.clz x

def hillis_steele [n] (xs: [n]i32) : [n]i32 =
  let m = ilog2 n
  in loop xs = copy xs for d in 0...m do
    map (\i ->
      let j = i32.i64 i - 2**d
       in if j < 0 then xs[i] else xs[i] + xs[j]
    ) (iota n)

--def work_efficient [n] (xs: [n] i32) : [n] i32 =
--  let m = ilog2 n
--  let upswept =
--    loop xs = copy xs for d in m...0 do
--    ...
--  let upswept [n-1] = 0
--  let downswept =
--    loop xs = upswept for d in 0...m do
--    ...
--  in downswept
