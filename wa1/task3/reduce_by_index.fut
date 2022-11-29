import "lib/github.com/diku-dk/sorts/radix_sort"
import "segmented"

-- ==
-- entry: test_my_reduce_by_index test_reduce_by_index
-- random input { [100]i64      [100]i32      }
-- random input { [1000]i64     [1000]i32     }
-- random input { [10000]i64    [10000]i32    }
-- random input { [100000]i64   [100000]i32   }
-- random input { [1000000]i64  [1000000]i32  }
-- random input { [10000000]i64 [10000000]i32 }

def my_reduce_by_index 'a [m] [n]
		       (dest: *[m]a)
		       (f: a -> a -> a) (ne: a)
		       (is: [n]i64) (as: [n]a) : *[m]a =
  let (vals,inds) = zip as is                                         -- Work: O(n),      Span: O(log(n))
                 |> radix_sort_by_key (\(_,i) -> i) i64.num_bits i64.get_bit
		             |> unzip
  let flags       = map2 (\i1 i2 -> i1 != i2) inds (rotate (-1) inds) -- Work: O(n),      Span: O(1)
  let (uniq,_)    = zip inds flags |> filter (\(_,b) -> b) |> unzip   -- Work: O(n),      Span: O(log(n))
  let reduced     = zip vals flags |> segreduce f ne                  -- Work: O(n*W(f)), Span: O(log(n)*W(f))
  let N           = length uniq                                       -- O(1)
  let redind      = zip (reduced :> [N]a) (uniq :> [N]i64)            -- O(1) i think
  let result      = map (\(x,i) -> f x dest[i]) redind                -- Work: O(n*W(f)), Span: O(S(f))
  in scatter dest (uniq :> [N]i64) result                             -- Work: O(n),      Span: O(1)

entry test_my_reduce_by_index [n] (is:  [n]i64)
                                  (as:  [n]i32) : [100]i32 =
  my_reduce_by_index (replicate 100 0) (+) 0 is as
entry test_reduce_by_index [n] (is:  [n]i64)
                               (as:  [n]i32) : [100]i32 =
  reduce_by_index (replicate 100 0) (+) 0 is as
