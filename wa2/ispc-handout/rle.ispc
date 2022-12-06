export uniform int rle_ispc(uniform int output[], uniform int input[], uniform int n) {
  uniform int m = 0;
  uniform int first = input[0];    // save very first read value
  uniform int last = first;        // value read last iteration for continuity
  uniform int count = 0;           // current count of consecutive values
  foreach (i = 0 ... n) {
    int v = input[i];              // inputs
    int vrot = rotate(v, -1);      // rotated inputs.
    vrot = insert(vrot , 0, last); // last read value set at front for continuity
    int diff = v != vrot;          // is `v_i` different from `v_i-1`?
    int c;                         // intermediate counts
    // crude sort of segmented scan
    // loop over each program and propagate `count`
    for (uniform int j = 0; j < programCount; j++) {
      uniform int this_diff = extract(diff, j); // "this" programs `diff` value
      c = insert(c, j, count);                  // set `c` to `count` for program j
      int new_count = this_diff ? 1 : c+1;      // increment count or reset if `diff`
      count = extract(new_count, j);            // update count
    }

    int offset   = exclusive_scan_add(diff)*2;
    int offsetp1 = offset + 1;                  // offset plus 1

    // if we don't intend to write, set `offset` and `offsetp1` to index 1
    // and `c` and `vrot` to the very first value.
    // this value is guaranteed to be at index 1 in the output i think.
    // not safe to just write at the end of the array as we might fill it.
    if (!diff) {
      offset   = 1 - m;
      offsetp1 = 1 - m;
      c    = first;
      vrot = first;
    }
    output[m + offset]   = c;
    output[m + offsetp1] = vrot;

    m += reduce_add(diff)*2;
    last = extract(v, programCount-1);  // save last read element
  }
  // write the last two elements
  if (programIndex == 0) {
    output[m]   = count;
    output[m+1] = last;
    m += 2;
  }
  return m;
}
