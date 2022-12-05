export void scan_ispc(uniform float output[], uniform float input[], uniform int n) {
  uniform float acc = 0;
  foreach (i = 0 ... n) {
    float x = input[i];
    float y = exclusive_scan_add(x) + x;
    output[i] = acc + y;
    acc += reduce_add(x);
  }
}
