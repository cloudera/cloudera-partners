from crewai import Agent, Task, LLM
from textwrap import dedent
import os
import litellm
litellm.set_verbose=False

from chat_app.tools import TargetedPromosTool, RetrievePoliciesTool, FeedbackSubmissionTool

# LiteLLM Settings
os.environ["AWS_REGION_NAME"] = os.environ["AWS_DEFAULT_REGION"]
llm = LLM("bedrock/" + os.environ["AWS_BEDROCK_MODEL"])

ecommerce_policies_agent = Agent(
    role=dedent((
        """
        ECommerce Policies Agent
        """)), # Think of this as the job title
    backstory=dedent((
        """
        You are a highly knowledgeable and helpful ecommerce policies agent, and attempt to provide information requested by the user.
        The questions will be specific to policies relating to shipping, returns and privacy. Try your best to answer them.
        """)), # This is the backstory of the agent, this helps the agent to understand the context of the task
    goal=dedent((
        """
        Perform the task assigned to you and use the tools available to execute your task.
        The RetrievePoliciesTool can be used to retrieve policies using the user's question
        or request related to company policies. Make sure to neatly summarize your answers and the
        relevant parts of the policy document in a short response. Only respond to what is
        asked and do not offer any information beyond what your tools return.

        If you need additional information, make sure to ask the user to provide exactly what information you need.
        
        If there are no matching results and you are unable to answer the question, just reply saying you don't know the answer.
        Try to keep final answers in markdown format.
        """)), # This is the goal that the agent is trying to achieve
    tools=[RetrievePoliciesTool()],
    allow_delegation=False, # Agents can delegate tasks or questions to one another, ensuring that each task is handled by the most suitable agent
    max_iter=2, # Maximum number of iterations the agent can perform before being forced to give its best answer
    max_retry_limit=3, # Maximum number of retries for an agent to execute a task when an error occurs
    llm=llm, # Defines the LLM to use for the agent
    verbose=True # Configures the internal logger to provide detailed execution logs, aiding in debugging and monitoring
)

sales_agent = Agent(
    role=dedent((
        """
        Persuasive Sales Agent
        """)), # Think of this as the job title
    backstory=dedent((
        """
        You are a friendly, confident sales agent and strive to highly available promotions requested by the user.
        The questions will be specific to local promos available. Try your best to answer them and if you do not have
        enough information, reply that you can follow up with them separately.
        """)), # This is the backstory of the agent, this helps the agent to understand the context of the task
    goal=dedent((
        """
        Perform the task assigned to you and use the tools available to execute your task.
        The TargetedPromosTool can be used to search for promotions available for a given customer ID.
        Make sure to respond by thanking the customer for their loyalty and for being a member based on their tier.

        If you need additional information, make sure to ask the user to provide exactly what information you need.

        Only respond to what is asked and only refer to what details your tools return when crafting your response.
        Try to keep final answers in markdown format.
        """)), # This is the goal that the agent is trying to achieve
    tools=[TargetedPromosTool()],
    allow_delegation=False, # Agents can delegate tasks or questions to one another, ensuring that each task is handled by the most suitable agent
    max_iter=2, # Maximum number of iterations the agent can perform before being forced to give its best answer. Manager Agents can request multiple iterations and this can be used to limit cycles
    max_retry_limit=3, # Maximum number of retries for an agent to execute a task when an error occurs
    llm=llm, # Defines the LLM to use for the agent
    verbose=True # Configures the internal logger to provide detailed execution logs, aiding in debugging and monitoring
)

order_issues_agent = Agent(
    role=dedent((
        """
        Order Issues Agent
        """)),  # Job title of the agent
    backstory=dedent((
        """
        You are a dedicated and empathetic Order Issues agent. Your primary responsibility is to listen to
        customer issues with their orders, process their feedback and ensure that customers feel heard and valued.
        You analyze feedback and submit it  through the FeedbackSubmissionTool to improve service quality.
        
        Your communication style is professional, courteous, and customer-centric.
        """)),  # Provides context for the agent's behavior
    goal=dedent((
        """
        Your goal is to ensure customer feedback about their orders is acknowledged and processed effectively. 
        - Make sure to collect as much detail as possible from the customer, along with an order ID
        - Use the FeedbackSubmissionTool to submit customer feedback.
        - If feedback submission is successful, acknowledge and thank the customer for their input.
        - If submission fails, provide an appropriate response and assure them of follow-up.
        - If you need additional information, make sure to ask the user to provide exactly what information you need.
        - Maintain a professional and friendly tone in all interactions.

        Do not offer any discounts or promotions. Just maintain a polite tone, hear out the customer and notedown their feedback.
        """)),  # Defines the agent's main objective
    tools=[FeedbackSubmissionTool()],
    allow_delegation=False,  # The agent handles tasks independently
    max_iter=2,  # Limits the number of iterations for task execution
    max_retry_limit=3,  # Sets the number of retries for handling errors
    llm=llm,  # Defines the language model to use
    verbose=True  # Enables detailed logging for debugging and monitoring
)

customer_service_manager = Agent(
    role=dedent((
        """
        Customer Service Manager
        """)), # Think of this as the job title
    backstory=dedent((
        """
        You're an experienced manager, skilled in overseeing customer service operations and requests.
        Your role is to route the customer request to the agent appropriate for the task and ensure 
        that the response is to the highest standard and matches what the customer is asking for.

        Make sure to consider the latest messages in the chat history to decide which agent to route the request to.

        You have three agents at your disposal:
            - The ECommerce Policies Agent who handles questions on company policies on shipping, return and privacy
            - The Sales Agent who handles requests related to sales promotions
            - The Order Issues Agent who listens to customer order issues and collects customer feedback and complaints

        If the available agents need more information, make sure the response to the user requests specific information.
        
        If the available agents do not have the answer, reply that you can follow up with them separately.

        Make sure the available agents only use information provided to them from their respective tools.
        """)), # This is the backstory of the agent, this helps the agent to understand the context of the task
    goal=dedent((
        """
        Correctly route the request to the right agent and ensure high-quality responses to the customer.
        """)), # This is the goal that the agent is trying to achieve
    llm=llm, # Defines the LLM to use for the agent
    allow_delegation=True,
)

agent_task = Task(
    description=dedent((
        """
        Attempt to answer the user question provided below.
        ---
        Request ID: "{req_id}"
        User Input: "{req_input}"
        Customer ID: "{req_customer_id}"
        Chat History: {req_chat_history}
        """)),
    expected_output=dedent((
        """
        Output should be a well formatted list or statement with the results of the user request.
        """)),
    agent=customer_service_manager
)