let smoothe [n] (xs : [n]i32) : [n]i32 =
  map (\i -> let l = if (i > 0)   then xs[i-1] else xs[i]
          in let r = if (i < n-1) then xs[i+1] else xs[i]
          in let m = xs[i]
          in (l+m+r) / 3) (iota n)

let main (xs : []i32) : []i32 =
  smoothe xs
