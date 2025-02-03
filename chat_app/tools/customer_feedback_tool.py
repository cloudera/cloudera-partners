from typing import Type, List, Tuple, Optional
from crewai_tools import BaseTool
from pydantic import BaseModel, Field


class CustomerFeedbackToolInput(BaseModel):
    """Input schema for the CustomerFeedbackTool"""
    customer_feedback: str = Field(..., description="The feedback provided by the customer.")
    customer_id: str = Field(..., description="The unique ID of the customer providing feedback.")
    order_id: Optional[str] = Field(None, description="The order ID associated with the feedback, if applicable.")


class CustomerFeedbackTool(BaseTool):
    name: str = "CustomerFeedbackTool"
    description: str = ("""
                        This tool submits customer feedback to the database. It accepts a customer ID, 
                        the feedback message, and optionally an order ID. 
                        It returns a boolean indicating whether the feedback submission was successful.
                    """)

    args_schema: Type[BaseModel] = CustomerFeedbackToolInput

    def _run(self, customer_feedback: str, customer_id: str, order_id: Optional[str] = None) -> bool:
        """
        Processes customer feedback submission.

        :param customer_feedback: The feedback provided by the customer.
        :param customer_id: The unique ID of the customer.
        :param order_id: (Optional) The order ID associated with the feedback.
        :return: True if the feedback was successfully submitted, otherwise False.
        """
        try:
            # Stub: Simulating a database call
            print(f"Submitting feedback: {customer_feedback}")
            print(f"Customer ID: {customer_id}")
            if order_id:
                print(f"Order ID: {order_id}")

            # Simulate success
            return True  
        except Exception as e:
            print(f"Error submitting feedback: {e}")
            return False