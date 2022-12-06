export uniform int pack_ispc(uniform int output[], uniform int input[], uniform int n) {
  uniform int m = 0;
  uniform int cur = input[0]^1; // <- guaranteed distinct
  foreach (i = 0 ... n) {
    int v = input[i];
    int vrot = rotate(insert(v, programCount-1, cur), -1);
    int keep = v != vrot;
    int offset = exclusive_scan_add(keep);
    if (!keep) {
      offset = programCount-1;
    }
    output[m + offset] = v;
    m += reduce_add(keep);
    cur = extract(v, programCount-1);
  }
  return m;
}
