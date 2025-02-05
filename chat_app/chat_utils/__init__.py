__version__ = "0.1.0"
from .vector_rag_utils import find_matching_chunk
from .neptune_query_wrapper import getCustomersWithOrders, getTierForCustomer, getPromotionsForCustomerId
from .neptune_query_strings import (
    GET_DEMO_CUSTOMER_IDS,
    GET_TIER,
    GET_TIERS_FOR_ALL_SAMPLE,
    GET_PROMOTIONS_FOR_ALL_TIERS,
    GET_CUSTOMERS_WITH_TIER,
    GET_CUSTOMERS_AND_ORDERS,
    GET_TIER_FOR_CUSTOMER
    )
from .util_functions import select_random_first_element