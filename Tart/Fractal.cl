kernel void mandelbrot(int max, int width, int height, float wx, float wy, float ww, float wh, global unsigned short *data) {
    int index = get_global_id(0);
    float i = index % width;
    float j = index / width;
    float x0 = wx + ww * (i / width);
    float y0 = wy + wh - wh * (j / height);
    float x = 0;
    float y = 0;
    int iteration = 0;
    while (x * x + y * y < 4 && iteration < max) {
        float temp = x * x - y * y + x0;
        y = 2 * x * y + y0;
        x = temp;
        iteration++;
    }
    data[index] = iteration == max ? 0 : iteration;
}

kernel void julia(int max, int width, int height, float wx, float wy, float ww, float wh, float jx, float jy, global unsigned short *data) {
    int index = get_global_id(0);
    float i = index % width;
    float j = index / width;
    float x = wx + ww * (i / width);
    float y = wy + wh - wh * (j / height);
    int iteration = 1;
    while (x * x + y * y < 4 && iteration < max) {
        float temp = x * x - y * y + jx;
        y = 2 * x * y + jy;
        x = temp;
        iteration++;
    }
    data[index] = iteration == max ? 0 : iteration;
}
