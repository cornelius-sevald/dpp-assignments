export uniform int rle_ispc(uniform int output[], uniform int input[], uniform int n) {
  uniform int m = 0;
  uniform int last = input[0];
  uniform int count = 0;
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

    int offset = exclusive_scan_add(diff)*2;
    if (diff) {
      output[m + offset]   = c;
      output[m + offset+1] = vrot;
    }
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
