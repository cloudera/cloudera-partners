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

def load_lifetime_rewards_node(tx):
    cypher = """
        MATCH (c:Customer)-[:placed]->(o:Order)-[r:has_item]->(p:Product)
        WITH c.customer_id AS customer_id, ROUND(SUM(r.price) * 100) / 100 as purchase_amount
        WITH AVG(purchase_amount) AS avg_purchase_amount, STDEVP(purchase_amount) AS stddev_purchase_amount

        MERGE (l:LifetimeRewardsVariable)
        SET l.average_purchase_amount = avg_purchase_amount, l.stddev_purchase_amount = stddev_purchase_amount
    """
    result = tx.run(cypher)
    logging.info(result)
    return result

if __name__ == '__main__':
    with GraphDatabase.driver(URI, auth=(USERNAME, PASSWORD)) as driver:
        with driver.session() as session:
            _ = session.execute_write(load_lifetime_rewards_node)