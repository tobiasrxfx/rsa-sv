import random

def montgomery_mul(x, y, m, R_bits=32):
    """
    Computes Montgomery multiplication (x * y * R^(-1) mod m)
    where R = 2^R_bits.
    """
    R = 1 << R_bits  # R = 2^R_bits
    R_inv = pow(R, -1, m)  # Compute R^(-1) mod m using modular inverse
    if x<m and y<m:
        result = (x * y * R_inv) % m
    
    return result

# Generate test vectors
NUM_TESTS = 10000  # Number of test cases
R_BITS = 32  # R = 2^32 (commonly used in Montgomery arithmetic)

with open("montgomery_test_vectors.txt", "w") as f:
    for _ in range(NUM_TESTS):
        m = random.randint(1, 2**R_BITS - 1) | 1  # Ensure modulus m is odd
        # 0 =< x, y < m
        x = random.randint(0, m) 
        y = random.randint(0, m)
        
        if x<m and y<m: 
            expected_result = montgomery_mul(x, y, m, R_BITS)
            f.write(f"{x} {y} {m} {expected_result}\n")

print(f"Generated {NUM_TESTS} test vectors in 'montgomery_test_vectors.txt'.")
