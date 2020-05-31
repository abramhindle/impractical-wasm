int mandel(double cx, double cy, int maxiters) {
  int i = 0;
  double zx = 0;
  double zy = 0;
  double zx2 = 0;
  double zy2 = 0;
  for (i = 0 ; i < maxiters && ((zx2 + zy2) < 4.0); i++) {
    zy = cy + 2.0 * zx * zy;
    zx = cx + zx2 - zy2;
    zx2 = zx * zx;
    zy2 = zy * zy;
  }
  return (i == maxiters);
}
