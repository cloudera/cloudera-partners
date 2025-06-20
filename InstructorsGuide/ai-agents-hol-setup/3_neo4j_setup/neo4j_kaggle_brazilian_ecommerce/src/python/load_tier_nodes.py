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

def load_tier_nodes(tx):
    cypher = """
        MERGE (:TierDiamond {name: "Diamond Tier", 
            discount: "Free shipping on all orders and free lifetime warranty on applicable products"})
        MERGE (:TierGold {name: "Gold Tier", 
            discount: "Free shipping on orders above $100 and discounted warranty on applicable products"})
        MERGE (:TierSilver {name: "Silver Tier", 
            discount: "Free shipping on orders above $200"})
        MERGE (:TierMember {name: "Member Tier"})
        """
    result = tx.run(cypher)
    logging.info(result)
    return result

if __name__ == '__main__':
    with GraphDatabase.driver(URI, auth=(USERNAME, PASSWORD)) as driver:
        with driver.session() as session:
            _ = session.execute_write(load_tier_nodes)