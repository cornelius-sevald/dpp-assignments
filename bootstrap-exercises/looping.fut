let popcount (n : i32) : i32 =
  loop c = 0 for i < 32 do c + i32.bool ((n & (1 << i)) != 0)

-- ==
-- entry: test_popcount
-- input  { 0   }
-- output { 0   }
-- input  { 1   }
-- output { 1   }
-- input  { 2   }
-- output { 1   }
-- input  { 3   }
-- output { 2   }
-- input  { 999 }
-- output { 8   }
entry test_popcount (n : i32) : i32 =
  popcount n
