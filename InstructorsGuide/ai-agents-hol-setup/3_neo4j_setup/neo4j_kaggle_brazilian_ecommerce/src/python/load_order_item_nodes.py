import logging
import os
import pandas as pd
from dotenv import load_dotenv
from neo4j import GraphDatabase

load_dotenv()
ORDER_ITEM_FILE = os.getenv("ORDER_ITEM_FILE_FILTERED")
URI = os.getenv("NEO4J_URI")
USERNAME = os.getenv("NEO4J_USERNAME")
PASSWORD = os.getenv("NEO4J_PASSWORD")

logging.basicConfig(
    level=logging.INFO, 
    format="%(asctime)s - %(levelname)s \n %(message)s" 
)
logger = logging.getLogger(__name__)

def load_order_item_nodes(tx, row):
    cypher = """
        MERGE (o:OrderItem {
            order_item_id: $order_item_id,
            order_id: $order_id,
            product_id: $product_id,
            seller_id: $seller_id,
            shipping_limit_date: $shipping_limit_date,
            price: $price,
            freight_value: $freight_value
        })
        """
    result = tx.run(cypher, 
        order_id = row["order_id"],
        order_item_id = row["order_item_id"],
        product_id = row["product_id"],
        seller_id = row["seller_id"],
        shipping_limit_date = row["shipping_limit_date"],
        price = row["price"],
        freight_value = row["freight_value"]
    )
    logging.info(result)
    return result

if __name__ == '__main__':
    with GraphDatabase.driver(URI, auth=(USERNAME, PASSWORD)) as driver:
        with driver.session() as session:
            df = pd.read_csv(ORDER_ITEM_FILE) 
            for index, row in df.iterrows():
                _ = session.execute_write(load_order_item_nodes, row)