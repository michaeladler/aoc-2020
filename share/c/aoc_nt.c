#include <limits.h>

#define __STDC_FORMAT_MACROS
#include <inttypes.h>

// Returns modulo inverse of a with respect to m using extended
// Euclid Algorithm. Refer below post for details:
// https://www.geeksforgeeks.org/multiplicative-inverse-under-modulo-m/
int64_t aoc_nt_modinv(int64_t a, int64_t m) {
  int64_t m0 = m, t, q;
  int64_t x0 = 0, x1 = 1;

  if (m == 1)
    return 0;

  // Apply extended Euclid Algorithm
  while (a > 1) {
    // q is quotient
    q = a / m;

    t = m;

    // m is remainder now, process same as
    // euclid's algo
    m = a % m, a = t;

    t = x0;

    x0 = x1 - q * x0;

    x1 = t;
  }

  // Make x1 positive
  if (x1 < 0)
    x1 += m0;

  return x1;
}

static inline int64_t normalize(int64_t a, int64_t n) {
  if (a < 0) {
    return (a % n) + n; // >= 0
  }
  return a % n;
}

// k is size of num[] and rem[]. Returns the smallest
// number x such that:
// x % num[0] = rem[0],
// x % num[1] = rem[1],
// ..................
// x % num[k-2] = rem[k-1]
// Assumption: Numbers in num[] are pairwise coprime
// (gcd for every pair is 1)
int64_t aoc_nt_chinese_remainder(int64_t num[], int64_t rem[], int k) {
  // Compute product of all numbers
  int64_t prod = 1;
  for (int i = 0; i < k; i++)
    prod *= num[i];

  // Initialize result
  int64_t result = 0;

  // Apply above formula
  for (int i = 0; i < k; i++) {
    int64_t pp = prod / num[i];
    result += normalize(rem[i], num[i]) * aoc_nt_modinv(pp, num[i]) * pp;
  }

  return normalize(result, prod);
}
