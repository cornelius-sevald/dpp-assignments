let rotate [n] 't (r: i64) (xs: [n]t) : [n]t =
  let r' = i32.i64 r in
  map (\i -> xs[(i + r') % n]) (iota n)

let transpose [n] [m] 't (xss: [n][m]t) : [m][n]t =
  map (\i -> map (\j -> xss[j,i]) (iota n)) (iota m)

let concat [n] [m] 't (xs: [n]t) (ys: [m]t) : []t =
  map (\i -> if i < n then xs[i] else ys[i-n]) (iota (n+m))

-- ==
-- entry: test_rotate
-- input  { [0] 9     }
-- output { [0]       }
-- input  { [0,1,2] 0 }
-- output { [0,1,2]   }
-- input  { [0,1,2] 1 }
-- output { [1,2,0]   }
-- input  { [0,1,2] 2 }
-- output { [2,0,1]   }
-- input  { [0,1,2] 3 }
-- output { [0,1,2]   }
entry test_rotate [n] (xs: [n]i32) (r: i32) : [n]i32 =
  rotate (i64.i32 r) xs

-- ==
-- entry: test_transpose
-- input  { [[0]]         }
-- output { [[0]]         }
-- input  { [[0,1]]       }
-- output { [[0],[1]]     }
-- input  { [[0,1],[2,3]] }
-- output { [[0,2],[1,3]] }
entry test_transpose [n] [m] (xss: [n][m]i32) : [m][n]i32 =
  transpose xss

-- ==
-- entry: test_concat
-- input  { [0] [1]         }
-- output { [0,1]           }
-- input  { [1] [0]         }
-- output { [1,0]           }
-- input  { [0,1] [2,3,4,5] }
-- output { [0,1,2,3,4,5]   }
entry test_concat [n] [m] (xs: [n]i32) (ys: [m]i32) : []i32 =
  concat xs ys
