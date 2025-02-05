import random

def select_random_first_element(arr):
        if not arr:
            return None  # Handle empty array case
        return random.choice(arr)[0]