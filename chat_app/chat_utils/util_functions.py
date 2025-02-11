import random

def select_random_element(arr):
        if not arr:
            return None  # Handle empty array case
        return random.choice(arr)