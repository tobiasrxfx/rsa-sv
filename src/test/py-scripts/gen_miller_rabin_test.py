import random
from sympy import isprime

NUM_TESTS = 100
WORD_LENGTH = 32

counter = 0 

with open("miller_rabin_test_vectors.txt", "w") as f:
    for _ in range(NUM_TESTS):
        n = random.randint(3, 2**WORD_LENGTH - 1) | 1  # Ensure modulus m is odd
        is_prime = isprime(n)
        if(is_prime):
            aux = 1
            f.write(f"{n} {aux}\n")
            counter += 1
        else:
            aux = 0
            f.write(f"{n} {aux}\n")

print(f"{NUM_TESTS} tests were generated. {counter} are prime")