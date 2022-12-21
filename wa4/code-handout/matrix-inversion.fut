-- Benchmarks
-- ==
-- entry: main
-- random input { [1][1024][1024]f32 }
-- random input { [4][512][512]f32   }
-- random input { [16][256][256]f32  }
-- random input { [64][128][128]f32  }
-- random input { [256][64][64]f32   }
-- random input { [1024][32][32]f32  }
-- random input { [4096][16][16]f32  }
-- random input { [16384][8][8]f32   }
-- random input { [65536][4][4]f32   }

def argmax arr =
  reduce_comm (\(a,i) (b,j) ->
                 if a < b
                 then (b,j)
                 else if b < a then (a,i)
                 else if j < i then (b,j)
                 else (a,i))
              (0f32, 0)
              (zip arr (indices arr))

def gaussian_elimination [n] [m] (A: [m][n]f32): [m][n]f32 =
  loop A for i < i64.min m n do
    -- Find nonzero pivot.
    -- Written carefully to avoid irregular parallelism.
    let value j x = if j >= i then f32.abs x else -f32.inf
    let j = A[:,i] |> map2 value (indices A) |> argmax |> (.1)
    let f = (1-A[i,i]) / A[j,i]
    let irow = map2 (f32.fma f) A[j] A[i]
    in tabulate m (\j ->
                     let f = A[j,i] * -1
                     in map2 (\x y -> if j == i then x else f32.fma f x y)
                             irow A[j])

def matrix_inverse [n] (A: [n][n]f32): [n][n]f32 =
  let AI =
    let I = scatter (replicate (n*n) 0)
                    (map (\i -> i+n*i) (iota n))
                    (replicate n 1)
                  |> unflatten n n
    in map2 (concat_to (2*n)) A I
  let BAinv = gaussian_elimination AI
  let Ainv = BAinv[0:n,n:2*n] :> [n][n]f32
  in Ainv

entry main [k] [n] (As: [k][n][n]f32) : [k][n][n]f32 =
  map matrix_inverse As
