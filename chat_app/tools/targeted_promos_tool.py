from typing import Type, List, Tuple
from crewai_tools import BaseTool
from pydantic import BaseModel, Field

from chat_app.chat_utils import get_promos_for_customer


class TargetedPromosToolInput(BaseModel):
    """ Input schema for the TargetedPromosTool"""
    customer_id: str = Field(..., description="The ID of the customer for whom we are looking up targeted promotions. This is a required field and cannot be blank.")


class TargetedPromosTool(BaseTool):
    name: str = "TargetedPromosTool"
    description: str = ("""
                        Use this tool to retrieve promotions that are targeted towards the given customer.
                        The response will return a tuple in the format (Loyalty Tier, Promo).
                        The promo returned is based on the customer's loyalty tier.
                        If there are no promos available, there will be an empty string in the second element.""")

    args_schema: Type[BaseModel] = TargetedPromosToolInput
    
    def _run(self, customer_id: str) -> Tuple[str, str]:

        tier_promo = get_promos_for_customer(customer_id)

        return tier_promo