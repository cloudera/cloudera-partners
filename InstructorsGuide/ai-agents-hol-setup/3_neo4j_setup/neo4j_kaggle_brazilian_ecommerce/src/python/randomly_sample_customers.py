
##########################################################
# Purpose: Filter by customer ids for a smaller demo set
# Author: kdavis@cloudera.com
##########################################################

import argparse
import logging
import os
import pandas as pd

from dotenv import load_dotenv
from typing import List

load_dotenv()

CUSTOMER_FILE = os.getenv("CUSTOMER_FILE")
CUSTOMER_ID_FILE = os.getenv("CUSTOMER_ID_FILE")

def get_random_customer_ids(sample_size: int)->List[str]:
    df = pd.read_csv(CUSTOMER_FILE, header=0)
    logging.info("Number of customer rows before sampling: %d", df.shape[0])
    ids = df['customer_id'].sample(n=sample_size, random_state=33).tolist()
    with open(CUSTOMER_ID_FILE, "w") as f:
        for id in ids:
            f.write(id + "\n")
    logging.info(f"Created file: {CUSTOMER_ID_FILE} with random sample of ids")
    return ids

if __name__ == "__main__":
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)

    parser = argparse.ArgumentParser(description='Randomly sample customer IDs')
    parser.add_argument('--sample-size', 
                        type=int, 
                        required=True,
                        help='Number of customers to sample')
    args = parser.parse_args()
    
    # Get random customer IDs using the provided sample size
    customer_ids = get_random_customer_ids(args.sample_size)

    logging.info(f"Sampled {len(customer_ids)} customer IDs")
