/*--- pi.c       PROGRAM RANPI
 *
 *   Program to compute PI by probability.
 *   By Mark Riordan  24-DEC-1986;
 *   Original version apparently by Don Shull.
 *   To be used as a CPU benchmark.
 *
 *  Translated to C from FORTRAN 20 Nov 1993
 */

/*
 * ----------------------------------------------------------------------------
 * MODIFICATIONS for RISC-V CPU Project (Benchmark Version)
 * Based on: https://github.com/mortbopet/Ripes/blob/master/test/riscv-tests/ranpi.c
 * By: Linda6
 * Date: 2025-05-07
 *
 * Benchmark results/details: https://godbolt.org/z/18jaKfxTY
 *
 * Purpose: Create a clean benchmark version from pi.c for performance evaluation
 *          of the RISC-V CPU. This version removes debug outputs and standardizes
 *          the iteration count to 100.
 *
 * Summary of changes from pi.c:
 * - Removed all printf statements for cleaner benchmarking.
 * - Removed #include <stdio.h> as it's no longer needed after removing printf.
 * - Ensured iteration count 'itot' is set to 100.
 * - Removed argc and argv from main() function signature as they are not used.
 * ----------------------------------------------------------------------------
 */

// #include <stdio.h> // Removed as printf is no longer used

void myadd(float* sum, float* addend) {
  /*
  c   Simple adding subroutine thrown in to allow subroutine
  c   calls/returns to be factored in as part of the benchmark.
  */
  *sum = *sum + *addend;
}

// int main(int argc, char* argv[]) { // Original signature from pi.c
int main() { // Modified signature: argc and argv removed as they are not used
  float ztot, yran, ymult, ymod, x, y, z, pi, prod;
  long int low, ixran, itot, j, iprod;

  // printf("Running RanPI...\n"); // Removed

  ztot = 0.0;
  low = 1;
  ixran = 1907;
  yran = 5813.0;
  ymult = 1307.0;
  ymod = 5471.0;
  itot = 100; // Standardized iteration count for this benchmark version

  for (j = 1; j <= itot; j++) {
      /*
      c   X and Y are two uniform random numbers between 0 and 1.
      c   They are computed using two linear congruential generators.
      c   A mix of integer and real arithmetic is used to simulate a
      c   real program.  Magnitudes are kept small to prevent 32-bit
      c   integer overflow and to allow full precision even with a 23-bit
      c   mantissa.
      */
      // printf("\tIteration: %d\n", j); // Removed
      iprod = 27611 * ixran;
      ixran = iprod - 74383 * (long int)(iprod / 74383);
      x = (float)ixran / 74383.0;
      prod = ymult * yran;
      yran = (prod - ymod * (long int)(prod / ymod));
      y = yran / ymod;
      z = x * x + y * y;
      myadd(&ztot, &z);
      if (z <= 1.0) {
          low = low + 1;
      }
  }

  pi = 4.0 * (float)low / (float)itot;

  // Print result
  // printf("Result: %f\n", pi); // Removed

  // Move result to some pre-determined register
  asm("mv x27, %[v]"
      :             /* Output registers */
      : [v] "r"(pi) /* Input registers */
      :             /* Clobber registers */
  );

  return 0;
}