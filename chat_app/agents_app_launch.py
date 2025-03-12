from crewai import Crew, Process, LLM
import asyncio
from textwrap import dedent
import os
import re
import litellm
import uuid
litellm.set_verbose=False

from chat_app.crew_agents import ecommerce_policies_agent, sales_agent, customer_service_manager, agent_task, order_issues_agent
from chat_app.app_config import configuration

# Task Definitions
import datetime

# Disable sending metrics to CrewAI
os.environ["OTEL_SDK_DISABLED"] = "true"


def format_chat_messages(chat_list):
    def remove_html(text):
        if text is None:
            return None
        return re.sub(r"<.*?>", "", text).strip()  # Remove HTML tags and extra spaces

    formatted_messages = []
    
    # Ignore the last element using list slicing
    for msg1, msg2 in chat_list[:-1]:  
        clean_msg1 = remove_html(msg1)
        clean_msg2 = remove_html(msg2)

        if clean_msg1 is None and clean_msg2 is not None:
            formatted_messages.append({"role": "system", "content": clean_msg2})
        elif clean_msg2 is None and clean_msg1 is not None:
            formatted_messages.append({"role": "user", "content": clean_msg1})

    return formatted_messages

def crew_launch(req_id, req_input, chat_history):
    # Instantiate your crew with a sequential process
    print("Instantiating Crew")
    crew = Crew(
        agents=[ecommerce_policies_agent, sales_agent, order_issues_agent],
        tasks=[agent_task],
        verbose=True,  # You can set it to True or False
        manager_agent=customer_service_manager,
        # ↑ indicates the verbosity level for logging during execution.
        # process=Process.sequential
    )
    formated_messages = format_chat_messages(chat_history)
    print("Setting req_input")
    inputs = {
        "req_id": req_id,
        "req_input": req_input,
        "req_customer_id": configuration.user_id,
        "req_chat_history": formated_messages
    }
    print("Kicking off crew")
    result = crew.kickoff(inputs=inputs)
    print(result.tasks_output)
    
    return result


example=""
print("Loading UI")
import gradio as gr


bot_msg = """<strong style="text-align:left;">ECSS</strong> - %s\n\n%s"""
# human_msg="##### User\n%s"
human_msg="""<p align="right">%s - <strong>User</strong></p>\n\n%s"""

startup_history = [(None, bot_msg % (datetime.datetime.now().strftime('%H:%M'), "Hello, how can I help you today?"))]




def display_user_message(message, chat_history):
    request_id = str(uuid.uuid4())[:8]
    message_text = message["text"]
    chat_history.append((human_msg % (datetime.datetime.now().strftime('%H:%M'), message_text), None))
    return request_id, message_text, chat_history

# def add_to_cart(message, chat_history):

#     return chat_history

def display_thinking(chat_history):
    thinking_msg = """
<h3 style="text-align:left;">🔄 Thinking...</h3>

"""

    chat_history.append((None, thinking_msg))
    return chat_history

def respond(request_id, message_text, chat_history):
    agent_usage_template = """
<h3 style="text-align:left;">🛠️ Calling Agent ...</h3>
"""
    crew_response = crew_launch(request_id, message_text, chat_history)
    chat_history.append((None, agent_usage_template))
    chat_history.append((None, bot_msg % (datetime.datetime.now().strftime('%H:%M'), str(crew_response))))
    return chat_history

css = """
footer{display:none !important}
#examples_table {zoom: 70% !important; }
#chatbot { flex-grow: 1 !important; overflow: auto !important;}
#col { height: 75vh !important; }
.info_md .container {
    border:1px solid #ccc; 
    border-radius:5px; 
    min-height:300px;
    color: #666;
    padding: 10px;
    background-color: whitesmoke;
}
#user-id-box {
    text-align: right;
    width: 100%;
    justify-content: flex-end;
    font-size: 32px;
}
"""

header_text = """
# ECommerce Customer Service Squad (ECSS)
"""

header2_text = """
Meet your **ECommerce Customer Service Squad (ECSS)**, an Agentic Workflow Orchestrator which deciphers and sends User requests to topic specific AI Agents and Tools.
"""

info_text = """
<div class='container'> 

## Agents that ECSS Can Use
**📄 ECommerce Policy Agent**
                               
Agent who is an expert in ECSS' Shipping, Returns and Privacy Policies. 

##### 🛍️ Sales Promotions Agent
                               
AI Sales Agent that will look up sales promotions targeted towards the specific customer.

##### 😌 Order Issues Agent
                               
AI Customer Advocate that will collect customer feedback for a specific order.

</div>
"""

theme = gr.themes.Base().set(
    body_background_fill="url('file=/home/cdsw/assets/background.png') #FFFFFF no-repeat center bottom / 100svw auto padding-box fixed"
)

# Define this textbox outside of blocks so other components can refer to it, render it on the layout inside gr.Blocks
input = gr.MultimodalTextbox(scale = 5, show_label = False, file_types = ["text"])

with gr.Blocks(css=css, theme=theme, title="ECSS") as demo:
    configuration.reset_config()
    request_id = gr.State("")
    request_text = gr.State("")
    with gr.Row():
        gr.Markdown(header_text, elem_id="header-text-box")
        gr.Markdown(f"### **User ID:** {configuration.user_id}", elem_id="user-id-box")
    with gr.Row():
        gr.Markdown(header2_text)
    with gr.Row():
        with gr.Column(scale=6):
            info = gr.Markdown(info_text, elem_classes=["info_md"])
            example_num = gr.Textbox(visible = False)
            with gr.Accordion("Example User Inputs", open = False):
              examples_2 = gr.Examples([
                                          [1, {"text":"How fast can you ship purchases?"}],
                                          [2, {"text":"Who can I contact if I want to delete my private data?"}],
                                          [3, {"text":"Am I eligible for any promos currently?"}],
                                          [4, {"text":f"Hi I didn't receive my order"}],
                                      ],
                                      inputs=[example_num, input], elem_id="examples_table", label="")
            with gr.Accordion("User Data", open = False):
                gr.Markdown(f"### **Orders:**\n1. {configuration.order_id}", elem_id="order-id-box")
        with gr.Column(scale=15, elem_id="col"):
            chatbot = gr.Chatbot(
                value = startup_history,
                avatar_images=["assets/person.png", "assets/chatbot.png"],
                elem_id = "chatbot",
                show_label = False
            )
            # configuration.chat_interface = chatbot
            # configuration.messages = startup_history
            input.render()
            
    user_msg = input.submit(display_user_message, [input, chatbot],  [request_id, request_text, chatbot])
    input.submit(lambda x: gr.update(value={"text":""}), None, [input], queue=False)
    tool_msg = user_msg.then(display_thinking, chatbot, chatbot)
    ayb_msg = tool_msg.then(respond, [request_id, request_text, chatbot], chatbot)

demo.launch(server_port=int(os.getenv("CDSW_APP_PORT")), server_name="127.0.0.1",  debug=True, allowed_paths=["/home/cdsw/assets/background.png"])
    