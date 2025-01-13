from crewai import Agent, Task, LLM
from textwrap import dedent
import os
import litellm
litellm.set_verbose=False

from chat_app.tools import TargetedPromosTool, RetrievePoliciesTool


llm = LLM(model=os.environ["AWS_BEDROCK_MODEL"])

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
        or request as an argument. Make sure to neatly summarize your answers and the
        relevant parts of the policy document in a short response. Only respond to what is
        asked and do not offer any information beyond what your tools return.
        
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
        Only respond to what is asked and do not make up any information beyond what your tools return.
        Try to keep final answers in markdown format.
        """)), # This is the goal that the agent is trying to achieve
    tools=[TargetedPromosTool()],
    allow_delegation=False, # Agents can delegate tasks or questions to one another, ensuring that each task is handled by the most suitable agent
    max_iter=2, # Maximum number of iterations the agent can perform before being forced to give its best answer. Manager Agents can request multiple iterations and this can be used to limit cycles
    max_retry_limit=3, # Maximum number of retries for an agent to execute a task when an error occurs
    llm=llm, # Defines the LLM to use for the agent
    verbose=True # Configures the internal logger to provide detailed execution logs, aiding in debugging and monitoring
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
        You have two agents at your disposal:
            - The ECommerce Policies Agent who handles requests related shipping, return and privacy policies
            - The Sales Agent who handles requests related to sales promotions
        If both the available agents do not have enough information, reply that you can follow up with them separately.
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
        """)),
    expected_output=dedent((
        """
        Output should be a well formatted list or statement with the results of the user request.
        """)),
    agent=customer_service_manager
)