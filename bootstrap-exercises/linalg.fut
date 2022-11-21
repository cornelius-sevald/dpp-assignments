import "lib"

let vec_scale [n] (s: f32) (xs: [n]f32) : [n]f32 =
  map (*s) xs

let vec_add [n] (s: f32) (xs: [n]f32) : [n]f32 =
  map (+s) xs

let dotprod [n] (xs: [n]f32) (ys: [n]f32) : f32 =
  map2 (*) xs ys |> reduce (+) 0

let matmul [n][m][p] (xss: [n][p]f32) (yss: [p][m]f32) : [n][m]f32 =
  let yss' = transpose yss in
  map (\i -> map (\j -> dotprod xss[i] yss'[j]) (iota m)) (iota n)

-- ==
-- entry: test_vec_scale
-- input  { [0,1,2] 0 }
-- output { [0,0,0]   }
-- input  { [0,1,2] 1 }
-- output { [0,1,2]   }
-- input  { [0,1,2] 2 }
-- output { [0,2,4]   }
-- input  { [0,1,2] 3 }
-- output { [0,3,6]   }
entry test_vec_scale [n] (xs: [n]i32) (s: i32) : [n]i32 =
  vec_scale (f32.i32 s) (map f32.i32 xs) |> map i32.f32

-- ==
-- entry: test_vec_add
-- input  { [0,1,2] 0 }
-- output { [0,1,2]   }
-- input  { [0,1,2] 1 }
-- output { [1,2,3]   }
-- input  { [0,1,2] 2 }
-- output { [2,3,4]   }
-- input  { [0,1,2] 3 }
-- output { [3,4,5]   }
entry test_vec_add [n] (xs: [n]i32) (s: i32) : [n]i32 =
  vec_add (f32.i32 s) (map f32.i32 xs) |> map i32.f32

-- ==
-- entry: test_dotprod
-- input  { [0] [9]         }
-- output { 0               }
-- input  { [0,1] [8,9]     }
-- output { 9               }
-- input  { [0,1,2] [3,4,5] }
-- output { 14              }
-- input  { [9,9,9] [9,9,9] }
-- output { 243             }
entry test_dotprod [n] (xs: [n]i32) (ys: [n]i32) : i32 =
  dotprod (map f32.i32 xs) (map f32.i32 ys) |> i32.f32

-- ==
-- entry: test_matmul
-- input  { [[0]] [[9]]       }
-- output { [[0]]             }
-- input  { [[0,1]] [[8],[9]] }
-- output { [[9]]             }
-- input  { [[0],[1]] [[8,9]] }
-- output { [[0,0],[8,9]]     }
-- input  { [[1,2,3]] [[4,5],[6,7],[8,9]] }
-- output { [[40,46]] }
entry test_matmul [n][m][p] (xss: [n][p]i32) (yss: [p][m]i32) : [n][m]i32 =
  matmul (map (map f32.i32) xss) (map (map f32.i32) yss) |> map (map i32.f32)
