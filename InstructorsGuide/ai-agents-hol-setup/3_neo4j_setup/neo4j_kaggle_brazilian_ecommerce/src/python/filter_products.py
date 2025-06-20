
##########################################################
# Purpose: Filter products by order item ids for a smaller demo set
# Author: sbalachandar@cloudera.com
##########################################################

import logging
import os
import pandas as pd

from dotenv import load_dotenv
from typing import List

load_dotenv()

ORDER_ITEM_FILE_FILTERED = os.getenv("ORDER_ITEM_FILE_FILTERED")
PRODUCT_FILE = os.getenv("PRODUCT_FILE")
PRODUCT_FILE_FILTERED = os.getenv("PRODUCT_FILE_FILTERED")

def read_product_ids_for_order_item_from_file()->List[str]:
    product_ids = []
    df = pd.read_csv(ORDER_ITEM_FILE_FILTERED, header=0)
    return df['product_id'].unique().tolist()

if __name__ == "__main__":

    df = pd.read_csv(PRODUCT_FILE, header=0)
    logging.info("Number of product rows before filtering: %d", df.shape[0])

    filtered = read_product_ids_for_order_item_from_file()
    mask = df["product_id"].isin(filtered)

    filteredDf = df[mask]
    print(filteredDf)
    logging.info("Number of product rows after filtering: %d", filteredDf.shape[0])

    filteredDf.to_csv(PRODUCT_FILE_FILTERED, header=True, index=False)
    logging.info("Filtered product data set saved to file")

