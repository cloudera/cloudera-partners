import logging
import os
import pandas as pd
from dotenv import load_dotenv
from neo4j import GraphDatabase

load_dotenv()
PRODUCT_FILE_FILTERED = os.getenv("PRODUCT_FILE_FILTERED")
URI = os.getenv("NEO4J_URI")
USERNAME = os.getenv("NEO4J_USERNAME")
PASSWORD = os.getenv("NEO4J_PASSWORD")

logging.basicConfig(
    level=logging.INFO, 
    format="%(asctime)s - %(levelname)s \n %(message)s" 
)
logger = logging.getLogger(__name__)

def load_product_nodes(tx, row):
    cypher = """
        MERGE (p:Product {
            product_id: $product_id,
            product_category_name: $product_category_name,
            product_weight_g: $product_weight_g,
            product_length_cm: $product_length_cm,
            product_height_cm: $product_height_cm,
            product_width_cm: $product_width_cm
        })
        """

    result = tx.run(cypher, 
        product_id = row["product_id"],
        product_category_name = row["product_category_name"] if pd.notna(row["product_category_name"]) else "",
        product_weight_g = row["product_weight_g"] if pd.notna(row["product_weight_g"]) else -1,
        product_length_cm = row["product_length_cm"]if pd.notna(row["product_length_cm"]) else -1,
        product_height_cm = row["product_height_cm"] if pd.notna(row["product_height_cm"]) else -1,
        product_width_cm = row["product_width_cm"] if pd.notna(row["product_width_cm"]) else -1
    )
    logging.info(result)
    return result

if __name__ == '__main__':
    with GraphDatabase.driver(URI, auth=(USERNAME, PASSWORD)) as driver:
        with driver.session() as session:
            df = pd.read_csv(PRODUCT_FILE_FILTERED) 
            for index, row in df.iterrows():
                _ = session.execute_write(load_product_nodes, row)