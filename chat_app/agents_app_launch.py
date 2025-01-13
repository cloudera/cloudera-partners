from crewai import Crew, Process, LLM
import asyncio
from textwrap import dedent
import os
import litellm
import uuid
litellm.set_verbose=False

from chat_app.crew_agents import ecommerce_policies_agent, sales_agent, customer_service_manager, agent_task
from chat_app.app_config import configuration

llm = LLM(model=os.environ["AWS_BEDROCK_MODEL"])
print("Importing available tools")

# Task Definitions
import datetime
print("Defining Primary Task")

def crew_launch(req_id, req_input):
    # Instantiate your crew with a sequential process
    print("Instantiating Crew")
    crew = Crew(
        agents=[ecommerce_policies_agent, sales_agent],
        tasks=[agent_task],
        verbose=True,  # You can set it to True or False
        manager_agent=customer_service_manager,
        # ↑ indicates the verbosity level for logging during execution.
        # process=Process.sequential
    )
    print("Setting req_input")
    inputs = {
        "req_id": req_id,
        "req_input": req_input,
        "req_customer_id": configuration.user_id,
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
    crew_response = crew_launch(request_id, message_text)
    chat_history.append((None, agent_usage_template))
    chat_history.append((None, bot_msg % (datetime.datetime.now().strftime('%H:%M'), str(crew_response))))
    return chat_history

css = """
footer{display:none !important}
#examples_table {zoom: 70% !important;}
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
Meet your **ECommerce Customer Service Squad (ECSS)**, an Agentic Workflow Orchestrator which deciphers and sends User requests to topic specific AI Agents and Tools.
"""

info_text = """
<div class='container'> 

## Agents that ECSS Can Use
**📄 ECommerce Policy Agent**
                               
Agent who is an expert in ECSS' Shipping, Returns and Privacy Policies. 

Looks up the latest policy and answers questions you may have.

##### 🛍️ Sales Promotions Agent
                               
AI Sales Agent that will look up sales promotions targeted towards the specific customer.

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
        gr.Markdown(header_text)
        gr.Markdown(f"### **User ID:** {configuration.user_id}", elem_id="user-id-box")
    with gr.Row():
        with gr.Column(scale=6):
            info = gr.Markdown(info_text, elem_classes=["info_md"])
            example_num = gr.Textbox(visible = False)
            with gr.Accordion("Example User Inputs", open = True):
              examples_2 = gr.Examples([
                                          [1, {"text":"How fast can you ship purchases?"}],
                                          [2, {"text":"Who can I contact if I want to delete my private data?"}],
                                          [3, {"text":"Am I eligible for any promos currently?"}],
                                      ],
                                      inputs=[example_num, input], elem_id="examples_table", label="")
            # with gr.Group():
            #     # Loop through products and render them inside the box
            #     for idx, product in enumerate(configuration.user_promos):
            #         with gr.Row(elem_id=f"row{idx}"):  # Each product is rendered in a row
            #             # Textbox for product name
            #             product_textbox = gr.Textbox(value=product, label="Product", interactive=False, elem_id=f"product_{idx}")
                        
            #             # Add to Cart button
            #             add_button = gr.Button("Add to Cart", elem_id=f"add_button_{idx}")
                        
            #             # Attach the button click event
            #             add_button.click(add_to_cart, inputs=[product_textbox, startup_history], outputs=[startup_history])
        with gr.Column(scale=15, elem_id="col"):
            chatbot = gr.Chatbot(
                value = startup_history,
                avatar_images=["assets/person.png", "assets/chatbot.png"],
                elem_id = "chatbot",
                show_label = False
            )
            input.render()
            
    user_msg = input.submit(display_user_message, [input, chatbot],  [request_id, request_text, chatbot])
    input.submit(lambda x: gr.update(value={"text":""}), None, [input], queue=False)
    tool_msg = user_msg.then(display_thinking, chatbot, chatbot)
    ayb_msg = tool_msg.then(respond, [request_id, request_text, chatbot], chatbot)

demo.launch(server_port=int(os.getenv("CDSW_APP_PORT")), server_name="127.0.0.1",  debug=True, allowed_paths=["/home/cdsw/assets/background.png"])
    