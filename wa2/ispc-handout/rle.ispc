export uniform int rle_ispc(uniform int output[], uniform int input[], uniform int n) {
  uniform int cur = input[0];
  uniform int count = 1;
  uniform int m = 0;

  foreach (i = 1 ... n) {
    int next = input[i];
    bool same = next == cur;
    if (all(same)) {
      count += reduce_add(1);
    } else {
      foreach_active (index) {
	if (next != cur) {
	  output[m++] = count;
	  output[m++] = cur;
	  cur = extract(next, index);
	  count = 1;
	} else {
	  count++;
	}
      }
    }
  }
  output[m++] = count;
  output[m++] = cur;

  return m;
}
