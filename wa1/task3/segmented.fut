-- ==
-- entry: test_segscan test_scan test_segreduce test_reduce
-- random input { [100]i32 [100]bool }
-- random input { [1000]i32 [1000]bool }
-- random input { [10000]i32 [10000]bool }
-- random input { [100000]i32 [100000]bool }
-- random input { [1000000]i32 [1000000]bool }
-- random input { [10000000]i32 [10000000]bool }

def segscan [n] 't (op: t -> t -> t) (ne: t)
                   (arr: [n](t, bool)) : []t =
  let op' (v1,f1) (v2,f2) = (if f2 then v2 else v1 `op` v2, f1 || f2)
  let ne' = (ne, false)
  let (res,_) = scan op' ne' arr |> unzip
  in res

def segreduce [n] 't (op: t -> t -> t) (ne: t)
                     (arr: [n](t, bool)): []t =
  let (_,flags) = unzip arr
  let flags'    = map (i64.bool) flags
  let indsp1    = map2 (*) (scan (+) 0 flags') (rotate 1 flags')
  let inds      = map (\x -> x-1) indsp1
  let k         = indsp1[n-1]
  let scan_res  = segscan op ne arr
  in spread k ne inds scan_res

entry test_segscan [n] (xs: [n]i32) (fs: [n]bool) : []i32 =
  segscan (+) 0 (zip xs fs)
entry test_segreduce [n] (xs: [n]i32) (fs: [n]bool) : []i32 =
  segreduce (+) 0 (zip xs fs)
entry test_scan [n] (xs: [n]i32) (fs: [n]bool) : []i32 =
  scan (+) 0 xs
entry test_reduce [n] (xs: [n]i32) (fs: [n]bool) : i32 =
  reduce (+) 0 xs
