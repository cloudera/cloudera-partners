import logging
import os
from dotenv import load_dotenv
from neo4j import GraphDatabase

load_dotenv()
URI = os.getenv("NEO4J_URI")
USERNAME = os.getenv("NEO4J_USERNAME")
PASSWORD = os.getenv("NEO4J_PASSWORD")

logging.basicConfig(
    level=logging.INFO, 
    format="%(asctime)s - %(levelname)s \n %(message)s" 
)
logger = logging.getLogger(__name__)

def create_order_product_edges(tx):
    cypher = """
        MATCH (o:Order), (i:OrderItem), (p:Product)
        WHERE o.order_id = i.order_id AND i.product_id = p.product_id
        MERGE (o)-[h:has_item]->(p)
        ON CREATE SET h.price = i.price, h.freight_value = i.freight_value, 
            h.seller_id = i.seller_id, h.order_id = o.order_id,
            h.product_id = p.product_id
        RETURN COUNT(h)
    """
    result = tx.run(cypher) 
    logging.info(result)
    return result

if __name__ == '__main__':
    with GraphDatabase.driver(URI, auth=(USERNAME, PASSWORD)) as driver:
        with driver.session() as session:
            _ = session.execute_write(create_order_product_edges)