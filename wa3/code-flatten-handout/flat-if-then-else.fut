-- Flattening If-Then-Else nested inside a map

-- Tests
-- ==
-- entry: main
-- compiled input { [false,true,false,true]
--                  [3i64,4i64,2i64,1i64]
--                  [1,2,3,4,5,6,7,8,9,10]
-- }
-- output { [3i64,4i64,2i64,1i64] [2,4,6,5,6,7,8,16,18,11] }
-- compiled input { [false,true,false,false,true,true]
--                  [0i64,1i64,2i64,3i64,4i64,5i64]
--                  [1,2,2,3,3,3,4,4,4,4,5,5,5,5,5]
-- }
-- output { [0i64,1i64,2i64,3i64,4i64,5i64] [2,4,4,6,6,6,5,5,5,5,6,6,6,6,6] }

-- Benchmarks
-- ==
-- entry: bench_flatIf
-- random input { [1000]bool [10000000]i32 }

let sgmscan 't [n] (op: t->t->t) (ne: t) (flg : [n]i64) (arr : [n]t) : [n]t =
  let flgs_vals =
    scan ( \ (f1, x1) (f2,x2) ->
            let f = f1 | f2 in
            if f2 != 0 then (f, x2)
            else (f, op x1 x2) )
         (0,ne) (zip flg arr)
  let (_, vals) = unzip flgs_vals
  in vals

let scanExc 't [n] (op: t->t->t) (ne: t) (arr : [n]t) : [n]t =
    scan op ne <| map (\i -> if i>0 then arr[i-1] else ne) (iota n)

let mkFlagArray 't [m]
            (aoa_shp: [m]i64) (zero: t)       --aoa_shp=[0,3,1,0,4,2,0]
            (aoa_val: [m]t  ) : []t =         --aoa_val=[1,1,1,1,1,1,1]
  let shp_rot = map (\i->if i==0 then 0       --shp_rot=[0,0,3,1,0,4,2]
                         else aoa_shp[i-1]
                    ) (iota m)
  let shp_scn = scan (+) 0 shp_rot            --shp_scn=[0,0,3,4,4,8,10]
  let aoa_len = shp_scn[m-1]+aoa_shp[m-1]     --aoa_len= 10
  let shp_ind = map2 (\shp ind ->             --shp_ind=
                       if shp==0 then -1      --  [-1,0,3,-1,4,8,-1]
                       else ind               --scatter
                     ) aoa_shp shp_scn        --   [0,0,0,0,0,0,0,0,0,0]
  in scatter (replicate aoa_len zero)         --   [-1,0,3,-1,4,8,-1]
             shp_ind aoa_val                  --   [1,1,1,1,1,1,1]
                                              -- res = [1,0,0,1,1,0,0,0,1,0]

let partition2 [n] 't (conds: [n]bool) (dummy: t) (arr: [n]t) : (i64, [n]t) =
  let tflgs = map (\ c -> if c then 1 else 0) conds
  let fflgs = map (\ b -> 1 - b) tflgs

  let indsT = scan (+) 0 tflgs
  let tmp   = scan (+) 0 fflgs
  let lst   = if n > 0 then indsT[n-1] else -1
  let indsF = map (+lst) tmp

  let inds  = map3 (\ c indT indF -> if c then indT-1 else indF-1) conds indsT indsF

  let fltarr= scatter (replicate n dummy) inds arr
  in  (lst, fltarr)

let mkII2 [m] (shp: [m]i64) : []i64 =
    let F = mkFlagArray shp 0 (replicate m 1)
    in  sgmscan (+) 0 F (map (const 1) F) |> map (\x->x-1)

------------------------------------------------------------------------
-- Weekly 2, Task 1:
-- The function bellow should be the flatten version of:
--     map (\b xs -> if b then map f xs
--                        else map g xs
--         ) bs xss
-- where:
--   `bs` is a 1d array of booleans
--   `xss` is a 2d irregular array of shape `S1_xss` and flat data `D_xss`;
--         the shape is an array of size `m` and the data is an array of size `n`
--   the result is a tuple representing an irregular array:
--       result's shape
--       result's flat data
-- Please take a look at the Rule (8) of Flattening
-- (slides 39 and 40 of L4-irreg-flattening.pdf)
-- and adapt the code from there.
--
-- The task is of course to replace the dummy implementation below
-- that just returns the input array with the code that performs the
-- flattening.
-- (You may of course use the helper functions provided in this file.)
--
-- DISCLAIMERS:
-- 1. Please note that in the lecture slides, function `f` is `map (+1)`.
--    Here it would be just `\x -> x+1`. Similarly for function `g`.
--    Do not let that inconsistency confuse you.
-- 2. The reason for which you are given a trivial recursive-flattening
--    case, is so that you do not get lost in debugging.
--    Please try to not use the knowledge that `map f' preserves the
--    length of the input array, i.e., fully implement as in slides.
-- 3. You are of course welcome to try with some arbitrary functions
--    `g1` and `g2` that do not preserve the length of the input
--    (instead of `map f` and `map g`), e.g., `filter odd`
--    and `filter even` but you will need work hard to flatten
--    `map (filter odd)`. (It is not required!)
--
let flatIf [n][m] (f: i32 -> i32) (g: i32->i32)
                  (bs: [m]bool) (S1_xss: [m]i64, D_xss: [n]i32)
                : ([]i64, []i32) =

  let F_xss = mkFlagArray S1_xss 0 (1...(length S1_xss) :> [m]i64)
  let ii1_xss = sgmscan (+) 0 F_xss F_xss |> map (\x->x-1)
  let ii2_xss = mkII2 S1_xss
  let (spl, iinds) = partition2 bs 0i64 (iota (length bs) :> [m]i64)
  let (S1_xss_then, S1_xss_else) = split spl (map (\ii -> S1_xss[ii]) iinds)
  let mask_xss = map (\sgmind -> bs[sgmind]) ii1_xss :> [n]bool
  let (brk, Dp_xss) = partition2 mask_xss 0i32 D_xss
  let (D_xss_then, D_xss_else) = split brk Dp_xss
  -- preserve lengths in this case.
  let (S1_res_then, D_res_then) = (S1_xss_then, map f D_xss_then)
  let (S1_res_else, D_res_else) = (S1_xss_else, map g D_xss_else)
  let S1P_res = S1_res_then ++ S1_res_else :> [m]i64
  let S1_res = scatter (replicate (length bs) 0) iinds S1P_res
  let B1_res = scanExc (+) 0 S1_res
  let FP_res = mkFlagArray S1P_res 0 (map (+1) iinds)
  let II1P_res = sgmscan (+) 0 FP_res FP_res |> map (\x->x-1) :> [n]i64
  let II2_res_then = mkII2 S1_xss_then
  let II2_res_else =  mkII2 S1_xss_else
  let II2P_res = II2_res_then ++ II2_res_else :> [n]i64
  let flen_res = reduce (+) 0 S1_res
  let sinds_res = map2 (\sgm iin -> B1_res[sgm] + iin) II1P_res II2P_res :> [flen_res]i64
  let D_res_then_else = D_res_then ++ D_res_else :> [flen_res]i32
  let D_res = scatter (replicate n 0) sinds_res D_res_then_else
  in  (S1_res, D_res)

-- echo "[false,true,false,true] [3,4,2,1] [1,2,3,4,5,6,7,8,9,10]" | ./flat-if-then-else
entry main [n][m] (bs: [m]bool) (S1_xss: [m]i64) (D_xss: [n]i32) =
  flatIf (\x->x+1i32) (\x->2i32*x) bs (S1_xss, D_xss)

-- benchmark `flatIf`. Assumes `m` evenly divides `n`
entry bench_flatIf [n][m] (bs: [m]bool) (D_xss: [n]i32) =
  let _ = #[trace(bs)] bs
  let _ = #[trace(D_xss)] D_xss
  let S1_xss = #[trace(S1_xss)] replicate m (n/m)
  in flatIf (\x->x+1i32) (\x->2i32*x) bs (S1_xss, D_xss)
