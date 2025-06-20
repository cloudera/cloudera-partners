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

def create_customer_order_edges(tx):
    cypher = """
        MATCH (c:Customer), (o:Order)
        WHERE c.customer_id = o.customer_id
        MERGE (c)-[p:placed]->(o)
        ON CREATE SET p.order_purchase_timestamp = o.order_purchase_timestamp
    """
    result = tx.run(cypher) 
    return result

if __name__ == '__main__':
    with GraphDatabase.driver(URI, auth=(USERNAME, PASSWORD)) as driver:
        with driver.session() as session:
            result = session.execute_write(create_customer_order_edges)
            logging.info(result)