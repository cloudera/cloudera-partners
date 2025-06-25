from flask import Blueprint, jsonify
from app.models.campaign_details import *

campaign_routes = Blueprint('campaign_routes', __name__)

# Endpoint to generate CampaignDetails data
@campaign_routes.route('/campaign-details', methods=['GET'])
def campaign_details():
    campaigns = generate_campaign_details()
    return jsonify(campaigns)

# Endpoint to generate CampaignPerformance data
@campaign_routes.route('/campaign-performance', methods=['GET'])
def campaign_performance():
    campaigns = generate_campaign_details()  # Get campaigns to use their CampaignIDs
    performance_data = generate_campaign_performance(campaigns)
    return jsonify(performance_data)

# Endpoint to generate SalesSeasonality data
@campaign_routes.route('/sales-seasonality', methods=['GET'])
def sales_seasonality():
    seasonality_data = generate_sales_seasonality()
    return jsonify(seasonality_data)

# Endpoint to generate CustomerCampaign data
@campaign_routes.route('/customer-campaign', methods=['GET'])
def customer_campaign():
    customer_campaigns = generate_customer_campaign()
    return jsonify(customer_campaigns)