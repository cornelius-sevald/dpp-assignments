-- ==
-- entry: test_process test_process_idx
-- random input { [100]i32 [100]i32 }
-- random input { [1000]i32 [1000]i32 }
-- random input { [10000]i32 [10000]i32 }
-- random input { [100000]i32 [100000]i32 }
-- random input { [1000000]i32 [1000000]i32 }
-- random input { [10000000]i32 [10000000]i32 }

def process [n] (xs: [n]i32) (ys: [n]i32) : i32 =
  let ds = map2 (\x y -> i32.abs (x - y)) xs ys
  in reduce i32.max 0 ds

def process_idx [n] (xs: [n]i32) (ys: [n]i32) : (i32,i64) =
  let ds = map2 (\x y -> i32.abs (x - y)) xs ys
  let is = iota n
  let op (x,ix) (y,iy) =
    if      x  > y  then (x,ix)
    else if y  > x  then (y,iy)
    else if ix > iy then (x,ix)
    else                 (y,iy)
  in zip ds is |> reduce_comm op (0,-1)

entry test_process = process
entry test_process_idx = process_idx
