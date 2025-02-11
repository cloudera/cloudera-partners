from typing import Type, List, Tuple, Optional
from crewai_tools import BaseTool
from pydantic import BaseModel, Field

from chat_app.chat_utils import submit_feedback_for_order


class FeedbackSubmissionToolInput(BaseModel):
    """Input schema for the FeedbackSubmissionTool"""
    customer_feedback: str = Field(..., description="The feedback provided by the customer.")
    customer_id: str = Field(..., description="The unique ID of the customer providing feedback.")
    order_id: str = Field(..., description="The order ID associated with the feedback, if applicable.")


class FeedbackSubmissionTool(BaseTool):
    name: str = "FeedbackSubmissionTool"
    description: str = ("""
                        This tool submits customer feedback to the database. It accepts a customer ID, 
                        the feedback message, and an order ID. 

                        Make sure to request the user for an order ID in order to use this tool.

                        It returns a boolean indicating whether the feedback submission was successful.
                    """)

    args_schema: Type[BaseModel] = FeedbackSubmissionToolInput

    def _run(self, customer_feedback: str, customer_id: str, order_id: str) -> bool:
        """
        Processes customer feedback submission.

        :param customer_feedback: The feedback provided by the customer.
        :param customer_id: The unique ID of the customer.
        :param order_id: The order ID associated with the feedback.
        :return: True if the feedback was successfully submitted, otherwise False.
        """
        try:
            feedback_submitted = submit_feedback_for_order(customer_id=customer_id, order_id=order_id, feedback=customer_feedback)

            return feedback_submitted
        
        except Exception as e:
            print(f"Error submitting feedback: {e}")
            return False