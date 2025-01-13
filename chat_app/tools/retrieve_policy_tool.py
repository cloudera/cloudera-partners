from typing import Type, List, Tuple
from crewai_tools import BaseTool
from pydantic import BaseModel, Field

from chat_app.chat_utils import find_matching_chunk


class RetrievePoliciesToolInput(BaseModel):
    """ Input schema for the RetrievePoliciesTool"""
    user_question: str = Field(..., description="The that the user has about a company policy")


class RetrievePoliciesTool(BaseTool):
    name: str = "RetrievePoliciesTool"
    description: str = ("""
                        Use this tool to look up company policies related to Privacy, Shipping and
                        Returns. Go through the entire output returned and find the relavent details
                        from within the page returned
                    """)

    args_schema: Type[BaseModel] = RetrievePoliciesToolInput
    
    def _run(self, user_question: str) -> str:

        vector_result, score = find_matching_chunk(user_question)

        if len(vector_result) > 0 and score > 0.3:
            return vector_result
        else:
            return "No matching results found"