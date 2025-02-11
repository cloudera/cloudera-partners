##################################################################################
# Reference:
# https://rasbt.github.io/mlxtend/user_guide/frequent_patterns/association_rules/
##################################################################################

import logging
import chat_app.chat_utils.graph_query_strings as q_strings
import os
import pandas as pd
import warnings
warnings.filterwarnings("ignore")

from mlxtend.frequent_patterns import apriori
from mlxtend.frequent_patterns import association_rules
from neo4j import GraphDatabase
from typing import List

logging.basicConfig(
    level=logging.INFO, 
    format="%(asctime)s - %(levelname)s \n %(message)s" 
)
logger = logging.getLogger(__name__)

USERNAME = os.getenv("AWS_NEPTUNE_USERNAME")
PASSWORD = os.getenv("AWS_NEPTUNE_PASSWORD")
ENDPOINT = os.getenv("AWS_NEPTUNE_ENDPOINT")
PORT = os.getenv("AWS_NEPTUNE_ENDPOINT_PORT")
URI = "bolt://{0}:{1}".format(ENDPOINT, PORT)

def getAllOrderedItems()->pd.DataFrame:
    try:
        with GraphDatabase.driver(URI, auth=(USERNAME, PASSWORD), encrypted=True) as driver:
            driver.verify_connectivity()
            drs = driver.session()
            res = drs.run(q_strings.GET_ORDER_ITEMS)
            data = [rec.data() for rec in res]
            df = pd.DataFrame(data)
            drs.close()
        return df

    except Exception as e:
        raise Exception(f"A Neptune error occurred in getAllOrderedItems: {e}")

# Find baskets - i.e. orders where more than one product was purchased
# Identify order_ids where more than one product was purchased
# Add a new column whose value is a list of column names with True values in the row
def getUniqueBaskets()->List[List[str]]:
    def encode(item_freq: int)->bool:
        x = False
        if item_freq > 0:
            x = True
        return x
    order_items = getAllOrderedItems()
    df = pd.crosstab(order_items["order_id"], order_items["product_category_name"])
    df = df.map(encode)
    filteredDf = df[df.sum(axis=1) > 1]
    filteredDf["basket"] = filteredDf.apply(
        lambda row: [col for col in df.columns if row[col]], axis=1
    )
# Find the unique baskets by disregarding the order of items in the shopping cart
    baskets = filteredDf["basket"].apply(lambda x: tuple(sorted(x))).drop_duplicates()
    return baskets.tolist()

def getUniqueBasketsHavingProduct(product: str)->List[List[str]]:
# Filter lists that contain the search_value
    baskets = getUniqueBaskets()
    filtered_lists = [lst for lst in baskets if product in lst]
    return filtered_lists

if __name__ == "__main__":
    unique_baskets = getUniqueBasketsHavingProduct("consoles_games")
    logger.info(unique_baskets) 

#############################################################################
# @comment: kentontroy
# The mlxtend Python package was also tested to perform the basket analysis
# A manually, less analytical approach was chosen instead as illustrated
# above. The 'Support' levels of the basket itemsets were very small. The
# values in the Kaggle dataset tend not to overlap causing 'Lift' values to 
# be close to 1. The probability of seeing multiple items in a basket is small,
# roughly 727 out of over 100,000 orders. So, basket recommendations were only
# made based upon the observations without regard to 'Conviction' and 'Leverage'.

# from mlxtend.frequent_patterns import apriori
# from mlxtend.frequent_patterns import association_rules
#
#    df = getAllOrderedItems()
#    frequent_itemsets = apriori(df, min_support=0.0001, use_colnames=True)
#    sorted_df = frequent_itemsets.sort_values(by="support", ascending=True)
#    rules = association_rules(frequent_itemsets, metric="lift")
#############################################################################
