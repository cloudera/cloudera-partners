import logging
from chat_utils.neptune_query_strings import (
    GET_DEMO_CUSTOMER_IDS,
    GET_TIER,
    GET_TIERS_FOR_ALL_SAMPLE,
    GET_PROMOTIONS_FOR_ALL_TIERS,
    GET_CUSTOMERS_WITH_TIER,
    GET_CUSTOMERS_AND_ORDERS,
    GET_TIER_FOR_CUSTOMER
    )
from chat_utils.util_functions import select_random_first_element
import os

from neo4j import GraphDatabase
from typing import Dict, List, Tuple, Any

logging.basicConfig(
    level=logging.INFO, 
    format="%(asctime)s - %(levelname)s \n %(message)s" 
)
logger = logging.getLogger(__name__)

URI = os.getenv("NEO4J_ENDPOINT")
USERNAME = os.getenv("NEO4J_USERNAME")
PASSWORD = os.getenv("NEO4J_PASSWORD")

def run_graph_query(query: str, **kwargs) -> List[Any]:
    with GraphDatabase.driver(URI, auth=(USERNAME, PASSWORD)) as driver:
        driver.verify_connectivity()
        drs = driver.session()
        print("Connected to Neo4j!")
        res = drs.run(query, **kwargs)
        records = list(res)
        drs.close()
        return records
    
def getCustomersWithTiers()->Any:
    print("Getting customers and tiers")
    result = []
    try:
        res = run_graph_query(GET_CUSTOMERS_WITH_TIER)
        for rec in res:
            result.append((rec["customer_id"], rec["tier"]))
            
    except Exception as e:
        raise Exception(f"A Neo4j error occurred in getCustomersWithTiers: {e}")
    
    return result

def getCustomersWithOrders()->Any:
    print("Getting customers and orders")
    result = []
    try:
        res = run_graph_query(GET_CUSTOMERS_AND_ORDERS)
        for rec in res:
            # print(rec["customer_id"])
            result.append((rec["customer_id"], rec["orders"][0]))
            
    except Exception as e:
        raise Exception(f"A Neo4j error occurred in getCustomersWithOrders: {e}")
    
    return result

def getTierForCustomer(customer_id: str)->str:
    tier = ""
    try:
        res = run_graph_query(GET_TIER_FOR_CUSTOMER, customer_id=customer_id)
        for rec in res:
            tier = rec["tier"]
            break

    except Exception as e:
        raise Exception(f"A Neptune error occurred in getTierForCustomerId: {e}")

    return tier

def getPromotionsForAllTiers()->Dict[str, str]:
    promotions = {}
    try:
        res = run_graph_query(GET_PROMOTIONS_FOR_ALL_TIERS)
        for rec in res:
                promotions["diamond"] = rec["diamond"]
                promotions["gold"] = rec["gold"]
                promotions["silver"] = rec["silver"]
                promotions["member"] = rec["member"]
                break

    except Exception as e:
        raise Exception(f"A Neptune error occurred in getPromotionsForAllTiers: {e}")

    return promotions

def getPromotionsForCustomerId(customer_id: str)->Tuple[str, str]:
    print("Getting promos now")
    try:
        tier = getTierForCustomer(customer_id)
        all_promotions: {} = getPromotionsForAllTiers()
        print("All Promos:" + str(all_promotions))
        print("Customer Tier:" + tier)
        promotions = all_promotions[tier.lower()]
        print("Customer Promo:" + promotions)
        return (tier, promotions)

    except Exception as e:
        raise Exception(f"A Neptune error occurred in getPromotionsForCustomerId: {e}")


if __name__ == "__main__":
# Execute all APIs to test

    cus_and_orders = getCustomersWithOrders()

    selected_customer = select_random_first_element(cus_and_orders)

    customer_tier_promo = getPromotionsForCustomerId(selected_customer)
    logger.info(customer_tier_promo)


    # customer_ids = getSampleCustomerIds()
    # logger.info(customer_ids)

    # tier = getTierForCustomerId(random.choice(customer_ids))
    # logger.info(tier)

    # tiers = getTiersForAllSampleCustomers()
    # logger.info(tiers)

    # promotions = getPromotionsForAllTiers()
    # logger.info(promotions)

    # promotions = getPromotionsForCustomerId(random.choice(customer_ids))
    # logger.info(promotions)

