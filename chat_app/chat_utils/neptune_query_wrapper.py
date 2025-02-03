import logging
from chat_utils.neptune_query_strings import (
    GET_DEMO_CUSTOMER_IDS,
    GET_TIER,
    GET_TIERS_FOR_ALL_SAMPLE,
    GET_PROMOTIONS_FOR_ALL_TIERS,
    GET_CUSTOMERS_WITH_TIER
    )
import os
import random

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

def run_graph_query(query: str) -> List[Any]:
    with GraphDatabase.driver(URI, auth=(USERNAME, PASSWORD)) as driver:
        driver.verify_connectivity()
        drs = driver.session()
        print("Connected to Neo4j!")
        res = drs.run(query)
        records = list(res)
        drs.close()
        return records

def getSampleCustomerIds()->List[str]:
    customer_ids = []
    try:
        with GraphDatabase.driver(URI, auth=(USERNAME, PASSWORD)) as driver:
            driver.verify_connectivity()
            drs = driver.session()
            print("Connected to Neo4j!")
            res = drs.run(GET_DEMO_CUSTOMER_IDS)
            for rec in res:
                customer_ids.append(rec["id"])
            drs.close()

    except Exception as e:
        raise Exception(f"A Neptune error occurred in getSampleCustomerIds: {e}")
    
    return customer_ids

def getTierForCustomerId(customer_id: str)->str:
    tier = ""
    try:
        with GraphDatabase.driver(URI, auth=(USERNAME, PASSWORD)) as driver:
            driver.verify_connectivity()
            drs = driver.session()
            res = drs.run(GET_TIER, customer_id=customer_id)
            for rec in res:
                tier = rec["tier"]            
                break
            drs.close()

    except Exception as e:
        raise Exception(f"A Neptune error occurred in getTierForCustomerId: {e}")

    return tier

def getTiersForAllSampleCustomers()->Dict[str, str]:
    tiers = {}
    try:
        with GraphDatabase.driver(URI, auth=(USERNAME, PASSWORD)) as driver:
            driver.verify_connectivity()
            drs = driver.session()
            res = drs.run(GET_TIERS_FOR_ALL_SAMPLE)
            for rec in res:
                tiers[rec["customer_id"]] = rec["tier"]
            drs.close()

    except Exception as e:
        raise Exception(f"A Neptune error occurred in getTiersForAllSampleCustomers: {e}")

    return tiers

def getPromotionsForAllTiers()->Dict[str, str]:
    promotions = {}
    try:
        with GraphDatabase.driver(URI, auth=(USERNAME, PASSWORD)) as driver:
            driver.verify_connectivity()
            drs = driver.session()
            res = drs.run(GET_PROMOTIONS_FOR_ALL_TIERS)
            for rec in res:
                promotions["diamond"] = rec["diamond"]
                promotions["gold"] = rec["gold"]
                promotions["silver"] = rec["silver"]
                promotions["member"] = rec["member"]
                break
            drs.close()

    except Exception as e:
        raise Exception(f"A Neptune error occurred in getPromotionsForAllTiers: {e}")

    return promotions

def getPromotionsForCustomerId(customer_id: str)->Tuple[str, str]:
    print("Getting promos now")
    try:
        tier = getTierForCustomerId(customer_id)
        all_promotions: {} = getPromotionsForAllTiers()
        print("All Promos:" + str(all_promotions))
        print("Customer Tier:" + tier)
        promotions = all_promotions[tier.lower()]
        print("Customer Promo:" + promotions)
        return (tier, promotions)

    except Exception as e:
        raise Exception(f"A Neptune error occurred in getPromotionsForCustomerId: {e}")
    
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


if __name__ == "__main__":
# Execute all APIs to test
    cus_and_tier = getCustomersWithTiers()
    logger.info(cus_and_tier)

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

