import os
import cmlapi
import sys
import gradio as gr
import pinecone
from pinecone import Pinecone, ServerlessSpec
from typing import Any, Union, Optional
from pydantic import BaseModel
import tensorflow as tf
from sentence_transformers import SentenceTransformer
import requests
import json
import time
from typing import Optional
import boto3
from botocore.config import Config
from huggingface_hub import hf_hub_download


USE_PINECONE = True # Set this to False avoid any Pinecone calls

EMBEDDING_MODEL_REPO = "sentence-transformers/all-mpnet-base-v2"


if USE_PINECONE:
    PINECONE_API_KEY = os.getenv('PINECONE_API_KEY')
    PINECONE_INDEX = os.getenv('PINECONE_INDEX')

    print("initialising Pinecone connection...")
    pc = Pinecone(api_key=PINECONE_API_KEY)
    print("Pinecone initialised")

    print(f"Getting '{PINECONE_INDEX}' as object...")
    index = pc.Index(PINECONE_INDEX)
    print("Success")

    # Get latest statistics from index
    current_collection_stats = index.describe_index_stats()
    print('Total number of embeddings in Pinecone index is {}.'.format(current_collection_stats.get('total_vector_count')))

## TO DO GET MODEL DEPLOYMENT
## Need to get the below prgramatically in the future iterations
client = cmlapi.default_client(url=os.getenv("CDSW_API_URL").replace("/api/v1", ""), cml_api_key=os.getenv("CDSW_APIV2_KEY"))
projects = client.list_projects(include_public_projects=True, search_filter=json.dumps({"name": "Shared LLM Model for Hands on Lab"}))
project = projects.projects[0]

## Here we assume that only one model has been deployed in the project, if this is not true this should be adjusted (this is reflected by the placeholder 0 in the array)
model = client.list_models(project_id=project.id)
selected_model = model.models[0]

## Save the access key for the model to the environment variable of this project
MODEL_ACCESS_KEY = selected_model.access_key

MODEL_ENDPOINT = os.getenv("CDSW_API_URL").replace("https://", "https://modelservice.").replace("/api/v1", "/model?accessKey=")
MODEL_ENDPOINT = MODEL_ENDPOINT + MODEL_ACCESS_KEY

# Double check default region
if os.environ.get("AWS_DEFAULT_REGION") == "":
    os.environ["AWS_DEFAULT_REGION"] = "us-west-2"

    
## Setup Bedrock client:
def get_bedrock_client(
    endpoint_url: Optional[str] = None,
    region: Optional[str] = None,
):
    """Create a boto3 client for Amazon Bedrock, with optional configuration overrides

    Parameters
    ----------
    endpoint_url :
        Optional override for the Bedrock service API Endpoint. If setting this, it should usually
        include the protocol i.e. "https://..."
    region :
        Optional name of the AWS Region in which the service should be called (e.g. "us-east-1").
        If not specified, AWS_REGION or AWS_DEFAULT_REGION environment variable will be used.
    """
    target_region = region

    print(f"Create new client\n  Using region: {target_region}")
    session_kwargs = {"region_name": target_region}
    client_kwargs = {**session_kwargs}

    profile_name = os.environ.get("AWS_PROFILE")
    if profile_name:
        print(f"  Using profile: {profile_name}")
        session_kwargs["profile_name"] = profile_name

    retry_config = Config(
        region_name=target_region,
        retries={
            "max_attempts": 10,
            "mode": "standard",
        },
    )
    session = boto3.Session(**session_kwargs)


    if endpoint_url:
        client_kwargs["endpoint_url"] = endpoint_url

    bedrock_client = session.client(
        service_name="bedrock-runtime",
        config=retry_config,
        **client_kwargs
    )

    print("boto3 Bedrock client successfully created!")
    print(bedrock_client._endpoint)
    return bedrock_client


boto3_bedrock = get_bedrock_client(
      region=os.environ.get("AWS_DEFAULT_REGION", None))


def main():
    # Configure gradio QA app 
    print("Configuring gradio app")

    DESC = "This AI-powered assistant showcases the flexibility of Cloudera Machine Learning to work with 3rd party solutions for LLMs and Vector Databases, as well as internally hosted models and vector DBs. The prototype does not yet implement chat history and session context - every prompt is treated as a brand new one."
    
    # Create the Gradio Interface
    demo = gr.ChatInterface(
        fn=get_responses, 
        title="Enterprise Custom Knowledge Base Chatbot",
        description = DESC,
        additional_inputs=[gr.Radio(['Local Mistral 7B', 'AWS Bedrock Claude v2.1'], label="Select Foundational Model", value="AWS Bedrock Claude v2.1", visible=False), 
                           gr.Slider(minimum=0.01, maximum=1.0, step=0.01, value=0.5, label="Select Temperature (Randomness of Response)"),
                           gr.Radio(["50", "100", "250", "500", "1000"], label="Select Number of Tokens (Length of Response)", value="250"),
                           gr.Radio(['None', 'Pinecone'], label="Vector Database Choices", value="None")],
        retry_btn = None,
        undo_btn = None,
        clear_btn = None,
        autofocus = True
        )

    # Launch gradio app
    print("Launching gradio app")
    demo.launch(share=True,   
                enable_queue=True,
                show_error=True,
                server_name='127.0.0.1',
                server_port=int(os.getenv('CDSW_READONLY_PORT')))
    print("Gradio app ready")

# Helper function for generating responses for the QA app
def get_responses(message, history, model, temperature, token_count, vector_db):
    
    
    # Process chat history
    #chat_history_string = '; '.join([strng for xchng in history for strng in xchng])
    #print(f"Chat so far {history}")
    
    
    if model == "'Local Mistral 7B":
        
        if vector_db == "None":
            context_chunk = ""
            response = get_llama2_response_with_context(message, context_chunk, temperature, token_count)
        
            # Stream output to UI
            for i in range(len(response)):
                time.sleep(0.02)
                yield response[:i+1]
                
        elif vector_db == "Pinecone":
            
            # Stream output to UI
            for i in range(len(response)):
                time.sleep(0.02)
                yield response[:i+1]
    
    elif model == "AWS Bedrock Claude v2.1":
        if vector_db == "None":
            # No context call Bedrock
            context_chunk = ""
            response = get_bedrock_response_with_context(message, context_chunk, temperature, token_count)
        
            # Stream output to UI
            for i in range(len(response)):
                time.sleep(0.02)
                yield response[:i+1]
                
        elif vector_db == "Pinecone":
            # Vector search the index
            context_chunk, source, score = get_nearest_chunk_from_pinecone_vectordb(index, message)
            
            # Call Bedrock model
            response = get_bedrock_response_with_context(message, context_chunk, temperature, token_count)
            
            response = f"{response}\n\n For additional info see: {url_from_source(source)}"
            
            # Stream output to UI
            for i in range(len(response)):
                time.sleep(0.01)
                yield response[:i+1]

def url_from_source(source):
    url = source.replace('/home/cdsw/data/https:/', 'https://').replace('.txt', '.html')
    return f"[Reference 1]({url})"
    

# Get embeddings for a user question and query Pinecone vector DB for nearest knowledge base chunk
def get_nearest_chunk_from_pinecone_vectordb(index, question):
    # Generate embedding for user question with embedding model
    retriever = SentenceTransformer(EMBEDDING_MODEL_REPO)
    xq = retriever.encode([question]).tolist()
    xc = index.query(vector=xq, top_k=5,include_metadata=True)
    
    matching_files = []
    scores = []
    for match in xc['matches']:
        # extract the 'file_path' within 'metadata'
        file_path = match['metadata']['file_path']
        # extract the individual scores for each vector
        score = match['score']
        scores.append(score)
        matching_files.append(file_path)

    # Return text of the nearest knowledge base chunk 
    # Note that this ONLY uses the first matching document for semantic search. matching_files holds the top results so you can increase this if desired.
    response = load_context_chunk_from_data(matching_files[0])
    sources = matching_files[0]
    score = scores[0]
    
    print(f"Response of context chunk {response}")
    return response, sources, score
    #return "Cloudera is an Open Data Lakhouse company", "http://cloudera.com", 89 

# Return the Knowledge Base doc based on Knowledge Base ID (relative file path)
def load_context_chunk_from_data(id_path):
    with open(id_path, "r") as f: # Open file in read mode
        return f.read()


def get_bedrock_response_with_context(question, context, temperature, token_count):
    
    # Supply different instructions, depending on whether or not context is provided
    if context == "":
        instruction_text = """Human: You are a helpful, honest, and courteous assistant. If you don't know the answer, simply state I don't know the answer to that question. Please provide an honest response to the user question enclosed in <question></question> tags. Do not repeat the question in the output.
    
    <question>{{QUESTION}}</question>
                    Assistant:"""
    else:
        instruction_text = """Human: You are a helpful, honest, and courteous assistant. If you don't know the answer, simply state I don't know the answer to that question. Please read the text provided between the tags <text></text> and provide an honest response to the user question enclosed in <question></question> tags. Do not repeat the question in the output.
    <text>{{CONTEXT}}</text>
    
    <question>{{QUESTION}}</question>
                    Assistant:"""

    
    # Replace instruction placeholder to build a complete prompt
    full_prompt = instruction_text.replace("{{QUESTION}}", question).replace("{{CONTEXT}}", context)
    
    # Model expects a JSON object with a defined schema
    body = json.dumps({"prompt": full_prompt,
             "max_tokens_to_sample":int(token_count),
             "temperature":float(temperature),
             "top_k":250,
             "top_p":1.0,
             "stop_sequences":[]
              })

    # Provide a model ID and call the model with the JSON payload
    modelId = 'anthropic.claude-v2:1'
    response = boto3_bedrock.invoke_model(body=body, modelId=modelId, accept='application/json', contentType='application/json')
    response_body = json.loads(response.get('body').read())
    print("Model results successfully retreived")
    
    result = response_body.get('completion')
    #print(response_body)
    
    return result

    
# Pass through user input to LLM model with enhanced prompt and stop tokens
def get_llama2_response_with_context(question, context, temperature, token_count):

    question = "Answer this question based on the given context. Question: " + str(question)
    
    question_and_context = question + " Here is the context: " + str(context)

    try:
        
        # Following LLama's spec for prompt engineering
        llama_sys = f"<<SYS>>\n You are a helpful, respectful and honest assistant. If you are unsurae about an answer, truthfully say \"I don't know\".\n<</SYS>>\n\n"
        llama_inst = f"[INST]Use your own knowledge and additionally use the following information to answer the user's question: {context} [/INST]"
        question_and_context = f"{llama_sys} {llama_inst} [INST] User: {question} [/INST]"
        
        data={ "request": {"prompt":question_and_context,"temperature":temperature,"max_new_tokens":token_count,"repetition_penalty":1.0} }
        
        r = requests.post(MODEL_ENDPOINT, data=json.dumps(data), headers={'Content-Type': 'application/json'})
        
        # Logging
        print(f"Request: {data}")
        print(f"Response: {r.json()}")
        
        #no_inst_response = str(r.json()['response'])[len(question_and_context)+2:]
            
        return "TEST" #no_inst_response
        
    except Exception as e:
        print(e)
        return e


if __name__ == "__main__":
    main()
