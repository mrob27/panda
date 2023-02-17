void matmul(float * A, float * B, float * C, int size)
{
  int i = 0;
  int j = 0;
  int k = 0;
#pragma omp parallel for
  for(i = 0; i < size; i++) {
    for(j = 0; j < size; j++) {
      float sum = 0;
      for(k = 0; k < size; k++) {
        sum = sum + A[i*size+j] * B[j*size+k];
      }
      C[i*size+k] = sum;
    }
  }
}
