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
  ???
