
##########################################################
# Purpose: Filter by customer ids for a smaller demo set
# Author: kdavis@cloudera.com
##########################################################

import logging
import os
import pandas as pd

from dotenv import load_dotenv
from typing import List

load_dotenv()

CUSTOMER_ID_FILE = os.getenv("CUSTOMER_ID_FILE")
CUSTOMER_FILE = os.getenv("CUSTOMER_FILE")
CUSTOMER_FILE_FILTERED = os.getenv("CUSTOMER_FILE_FILTERED")
ORDER_FILE = os.getenv("ORDER_FILE")
ORDER_FILE_FILTERED = os.getenv("ORDER_FILE_FILTERED")
ORDER_ITEM_FILE = os.getenv("ORDER_ITEM_FILE")
ORDER_ITEM_FILE_FILTERED = os.getenv("ORDER_ITEM_FILE_FILTERED")

logging.basicConfig(
    level=logging.INFO, 
    format="%(asctime)s - %(levelname)s \n %(message)s" 
)
logger = logging.getLogger(__name__)

def read_customer_ids_from_file()->List[str]:
    ids = []
    with open(CUSTOMER_ID_FILE, "r") as f:
        lines = f.readlines()
        for id in lines:
           ids.append(id.strip().strip('"'))
    return ids

def read_order_ids_from_file()->List[str]:
    ids = []
    df = pd.read_csv(ORDER_FILE_FILTERED, header=0)
    return df['order_id'].unique().tolist()

if __name__ == "__main__":
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)

    df = pd.read_csv(CUSTOMER_FILE, header=0)
    logging.info("Number of customer rows before filtering: %d", df.shape[0])

    filtered = read_customer_ids_from_file()
    mask = df["customer_id"].isin(filtered)
    filteredDf = df[mask]
    print(filteredDf)
    logging.info("Number of customer rows after filtering: %d", filteredDf.shape[0])

    filteredDf.to_csv(CUSTOMER_FILE_FILTERED, header=True, index=False)
    logging.info("Filtered customer data set saved to file")

#############################################
# Filter order ids for a smaller demo set`
#############################################
    df = pd.read_csv(ORDER_FILE, header=0)
    logging.info("Number of order rows before filtering: %d", df.shape[0])

    filtered = read_customer_ids_from_file()
    mask = df["customer_id"].isin(filtered)
    filteredDf = df[mask]
    print(filteredDf)
    logging.info("Number of order rows after filtering: %d", filteredDf.shape[0])

    filteredDf.to_csv(ORDER_FILE_FILTERED, header=True, index=False)
    logging.info("Filtered order data set saved to file")

#############################################
# Filter order items for a smaller demo set`
#############################################
    df = pd.read_csv(ORDER_ITEM_FILE, header=0)
    logging.info("Number of order item rows before filtering: %d", df.shape[0])

    filtered = read_order_ids_from_file()
    mask = df["order_id"].isin(filtered)
    filteredDf = df[mask]
    print(filteredDf)
    logging.info("Number of order item rows after filtering: %d", filteredDf.shape[0])

    filteredDf.to_csv(ORDER_ITEM_FILE_FILTERED, header=True, index=False)
    logging.info("Filtered order item data set saved to file")
