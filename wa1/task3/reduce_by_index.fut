import "lib/github.com/diku-dk/sorts/radix_sort"
import "segmented"

def my_reduce_by_index 'a [m] [n]
		       (dest: *[m]a)
		       (f: a -> a -> a) (ne: a)
		       (is: [n]i64) (as: [n]a) : *[m]a =
  let (vals,inds) = zip as is
                 |> radix_sort_by_key (\(_,i) -> i) i64.num_bits i64.get_bit
		 |> unzip
  let flags       = map2 (\i1 i2 -> i1 != i2) inds (rotate (-1) inds)
  let (uniq,_)    = zip inds flags |> filter (\(_,b) -> b) |> unzip
  let reduced     = zip vals flags |> segreduce f ne
  let N           = length uniq
  let redind      = zip (reduced :> [N]a) (uniq :> [N]i64)
  let result      = map (\(x,i) -> f x dest[i]) redind
  in scatter dest (uniq :> [N]i64) result
