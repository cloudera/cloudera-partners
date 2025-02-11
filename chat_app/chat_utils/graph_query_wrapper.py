import logging
from chat_app.chat_utils import (
    GET_PROMOTIONS_FOR_ALL_TIERS,
    GET_CUSTOMERS_WITH_TIER,
    GET_CUSTOMERS_AND_ORDERS,
    GET_TIER_FOR_CUSTOMER,
    SET_ORDER_FEEDBACK,
    select_random_element
    )

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
    
def get_customers_with_tiers()->Any:
    print("Getting customers and tiers")
    result = []
    try:
        res = run_graph_query(GET_CUSTOMERS_WITH_TIER)
        for rec in res:
            result.append((rec["customer_id"], rec["tier"]))
            
    except Exception as e:
        raise Exception(f"A Neo4j error occurred in get_customers_with_tiers: {e}")
    
    return result

def get_customers_with_orders()->Any:
    result = []
    try:
        res = run_graph_query(GET_CUSTOMERS_AND_ORDERS)
        for rec in res:
            # print(rec["customer_id"])
            result.append((rec["customer_id"], rec["orders"][0]))
            
    except Exception as e:
        raise Exception(f"A Neo4j error occurred in get_customers_with_orders: {e}")
    
    return result

def get_tier_for_customer(customer_id: str)->str:
    tier = ""
    try:
        res = run_graph_query(GET_TIER_FOR_CUSTOMER, customer_id=customer_id)
        for rec in res:
            tier = rec["tier"]
            break

    except Exception as e:
        raise Exception(f"A Neo4j error occurred in get_tier_for_customer: {e}")

    return tier

def get_tier_promos()->Dict[str, str]:
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
        raise Exception(f"A Neo4j error occurred in get_tier_promos: {e}")

    return promotions

def get_promos_for_customer(customer_id: str)->Tuple[str, str]:
    print("Getting promos now")
    try:
        tier = get_tier_for_customer(customer_id)
        all_promotions: {} = get_tier_promos()
        print("All Promos:" + str(all_promotions))
        print("Customer Tier:" + tier)
        promotions = all_promotions[tier.lower()]
        print("Customer Promo:" + promotions)
        return (tier, promotions)

    except Exception as e:
        raise Exception(f"A Neo4j error occurred in get_promos_for_customer: {e}")
    

def submit_feedback_for_order(customer_id: str, order_id: str, feedback: str)->bool:

    try:
        res = run_graph_query(SET_ORDER_FEEDBACK, customer_id=customer_id, order_id=order_id, feedback=feedback)
        if res:
            return True

    except Exception as e:
        raise Exception(f"A Neo4j error occurred in submit_feedback_for_order: {e}")

    return False


if __name__ == "__main__":
# Execute all APIs to test

    cus_and_orders = get_customers_with_orders()

    selected_cust_order = select_random_element(cus_and_orders)

    selected_customer = selected_cust_order[0]
    selected_order = selected_cust_order[1]
    logger.info("Selected Customer: " + selected_customer)
    logger.info("Selected Order: " + selected_order)

    # customer_tier_promo = get_promos_for_customer(selected_customer)

    # feedback_submitted = submit_feedback_for_order(selected_customer, selected_order, "Test Feedback")
    # logger.info("Feedback Submitted: " + str(feedback_submitted))


