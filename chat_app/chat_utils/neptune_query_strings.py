
GET_DEMO_CUSTOMER_IDS="MATCH (t:demo_set_customer) RETURN t.customer_id AS id"

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
MATCH (d:tier_diamond)
MATCH (g:tier_gold)
MATCH (s:tier_silver)
MATCH (m:tier_member)
RETURN d.discount AS diamond, g.discount AS gold, s.discount AS silver, "" AS member
"""

GET_ORDER_ITEMS="""
MATCH (o:order)-[r:has_item]->(p:product)
RETURN o.order_id AS order_id, p.product_category_name as product_category_name
"""
