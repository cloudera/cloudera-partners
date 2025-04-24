GET_DEMO_CUSTOMER_IDS="MATCH (c:Customer)-[:placed]->(o)-[r:has_item]->(p:Product) RETURN c.customer_id AS id"

GET_TIER="""
MATCH (c:demo_set_customer {customer_id: $customer_id})-[:placed]->(o)-[r:has_item]->(p:product), 
    (l:lifetime_rewards_variable)
WITH c.customer_id AS customer_id, ROUND(SUM(r.price) * 100) / 100 as purchase_amount, l
RETURN
customer_id,
CASE
    WHEN purchase_amount > l.average_purchase_amount + (2 * l.stddev_purchase_amount) THEN "Diamond"
    WHEN purchase_amount > l.average_purchase_amount + l.stddev_purchase_amount THEN "Gold"
    WHEN purchase_amount >= l.average_purchase_amount THEN "Silver"
    ELSE "Member"
END AS tier
"""

GET_TIERS_FOR_ALL_SAMPLE="""
MATCH (c:demo_set_customer)-[:placed]->(o)-[r:has_item]->(p:product), 
    (l:lifetime_rewards_variable)
WITH c.customer_id AS customer_id, ROUND(SUM(r.price) * 100) / 100 as purchase_amount, l
RETURN
customer_id,
CASE
    WHEN purchase_amount > l.average_purchase_amount + (2 * l.stddev_purchase_amount) THEN "Diamond"
    WHEN purchase_amount > l.average_purchase_amount + l.stddev_purchase_amount THEN "Gold"
    WHEN purchase_amount >= l.average_purchase_amount THEN "Silver"
    ELSE "Member"
END AS tier
"""

GET_PROMOTIONS_FOR_ALL_TIERS="""
MATCH (d:TierDiamond)
MATCH (g:TierGold)
MATCH (s:TierSilver)
RETURN d.discount AS diamond, g.discount AS gold, s.discount AS silver, "" AS member
"""

GET_ORDER_ITEMS="""
MATCH (o:order)-[r:has_item]->(p:product)
RETURN o.order_id AS order_id, p.product_category_name as product_category_name
"""

GET_CUSTOMERS_AND_ORDERS="MATCH (c:Customer)-[:placed]->(o:Order) RETURN c.customer_id as customer_id, COLLECT(o.order_id) AS orders"

GET_TIER_FOR_CUSTOMER="""
MATCH (c:Customer {customer_id: $customer_id})-[:placed]->(o)-[r:has_item]->(p:Product), 
    (l:LifetimeRewardsVariable)
WITH c.customer_id AS customer_id, ROUND(SUM(r.price) * 100) / 100 as purchase_amount, l
RETURN
customer_id,
CASE
    WHEN purchase_amount > l.average_purchase_amount + (2 * l.stddev_purchase_amount) THEN "Diamond"
    WHEN purchase_amount > l.average_purchase_amount + l.stddev_purchase_amount THEN "Gold"
    WHEN purchase_amount >= l.average_purchase_amount THEN "Silver"
    ELSE "Member"
END AS tier
"""

GET_CUSTOMERS_WITH_TIER="""
MATCH (c:Customer)-[:placed]->(o)-[r:has_item]->(p:Product), (l:LifetimeRewardsVariable)
WITH c.customer_id AS customer_id, ROUND(SUM(r.price) * 100) / 100 as purchase_amount, l
RETURN
customer_id,
CASE
    WHEN purchase_amount > l.average_purchase_amount + (2 * l.stddev_purchase_amount) THEN "Diamond"
    WHEN purchase_amount > l.average_purchase_amount + l.stddev_purchase_amount THEN "Gold"
    WHEN purchase_amount >= l.average_purchase_amount THEN "Silver"
    ELSE "Member"
END AS tier
"""

SET_ORDER_FEEDBACK="""
MATCH (c:Customer {customer_id: $customer_id})-[r:placed]->(o:Order {order_id: $order_id})
SET r.feedback = $feedback
RETURN r
"""