#include <limits.h>
#include <stdint.h>
#include <stdio.h>

static uint64_t transform(uint64_t subject, uint64_t loop_size) {
  uint64_t result = 1;
  for (uint64_t i = 0; i < loop_size; ++i) {
    result = (result * subject) % 20201227;
  }
  return result;
}

static uint64_t crack_key(uint64_t pub_key) {
  uint64_t result = 1;
  for (uint64_t loop_size = 1; loop_size < UINT64_MAX; ++loop_size) {
    result = (result * 7) % 20201227;
    if (result == pub_key) {
      return loop_size;
    }
  }
  return 0;
}

int main() {
  uint64_t pub_a = 5290733;
  uint64_t pub_b = 15231938;

  uint64_t secret_a = crack_key(pub_a);
  uint64_t enc_key = transform(pub_b, secret_a);
  printf("Part 1: %lu\n", enc_key);

  return 0;
}
