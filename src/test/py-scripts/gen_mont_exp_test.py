import random

# Generate test vectors
NUM_TESTS = 100  # Number of test cases
R_BITS = 32  # R = 2^32 (commonly used in Montgomery arithmetic)

with open("exp_test_vectors.txt", "w") as f:
    for _ in range(NUM_TESTS):
        m = random.randint(1, 2**R_BITS - 1) | 1  # Ensure modulus m is odd
        # 0 =< x, y < m
        x = random.randint(0, m) 
        e = 65537
        
        if x<m and e<m: 
            expected_result = pow(x, e, m)
            f.write(f"{x} {e} {m} {expected_result}\n")

print(f"Generated {NUM_TESTS} test vectors in 'exp_test_vectors.txt'.")
