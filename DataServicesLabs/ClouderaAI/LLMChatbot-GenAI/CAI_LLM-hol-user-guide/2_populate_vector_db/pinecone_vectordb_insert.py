import os
import subprocess
import torch
import torch.nn.functional as F
from transformers import AutoTokenizer, AutoModel
from pathlib import Path
from pinecone import Pinecone, ServerlessSpec
from sentence_transformers import SentenceTransformer

# Get environment variables for Pinecone API key, environment, and index name.
PINECONE_API_KEY = os.getenv('PINECONE_API_KEY')
PINECONE_REGION = os.getenv('PINECONE_REGION')
PINECONE_INDEX = os.getenv('PINECONE_INDEX')

dimension = 768

# Set embedding model
EMBEDDING_MODEL_REPO = "sentence-transformers/all-mpnet-base-v2"

# Load the model stored in models/embedding-model
tokenizer = AutoTokenizer.from_pretrained(EMBEDDING_MODEL_REPO)
model = AutoModel.from_pretrained(EMBEDDING_MODEL_REPO)

# Define a function to create a Pinecone collection with the specified index name.
def create_pinecone_collection(pc, PINECONE_INDEX):
    try:
        print(f"Creating 768-dimensional index called '{PINECONE_INDEX}'...")
        # Create the Pinecone index with the specified dimension.
        pc.create_index(name=PINECONE_INDEX,
                        dimension=768,
                        spec=ServerlessSpec(
                          cloud='aws',
                          region=PINECONE_REGION))
        print("Success")
    except Exception as e:
        print (e)
        # index already created, continue
        pass

    print("Checking Pinecone for active indexes...")
    active_indexes = pc.list_indexes()
    print("Active indexes:")
    print(active_indexes)
    print(f"Getting description for '{PINECONE_INDEX}'...")
    index_description = pc.describe_index(PINECONE_INDEX)
    print("Description:")
    print(index_description)

    print(f"Getting '{PINECONE_INDEX}' as object...")
    pinecone_index = pc.Index(PINECONE_INDEX)
    print("Success")

    # Return the Pinecone index object.
    return pinecone_index
    

# Mean Pooling - Take attention mask into account for correct averaging
def mean_pooling(model_output, attention_mask):
    token_embeddings = model_output[0] #First element of model_output contains all token embeddings
    input_mask_expanded = attention_mask.unsqueeze(-1).expand(token_embeddings.size()).float()
    return torch.sum(token_embeddings * input_mask_expanded, 1) / torch.clamp(input_mask_expanded.sum(1), min=1e-9)


# Create embeddings using chosen embedding-model
def get_embeddings(sentence):
    # Sentences we want sentence embeddings for
    sentences = [sentence]
    
    # Tokenize sentences
    # Default model will truncate the document and only gets embeddings of the first 256 tokens.
    # Semantic search will only be effective on these first 256 tokens.
    # Context loading will still include the ENTIRE document file
    encoded_input = tokenizer(sentences, padding='max_length', truncation=True, return_tensors='pt')

    # Compute token embeddings
    with torch.no_grad():
        model_output = model(**encoded_input)

    # Perform pooling
    sentence_embeddings = mean_pooling(model_output, encoded_input['attention_mask'])

    # Normalize embeddings
    sentence_embeddings = F.normalize(sentence_embeddings, p=2, dim=1)

    return (sentence_embeddings.tolist()[0])

    
# Create an embedding for given text/doc and insert it into Pinecone Vector DB
def insert_embedding(pinecone_index, id_path, text):
    print("Upserting vectors...")
    vectors = list(zip([text[:512]], [get_embeddings(text)], [{"file_path": id_path}]))
    upsert_response = pinecone_index.upsert(
        vectors=vectors
        )
    print("Success")
    
    
def main():
    try:
        print("initialising Pinecone connection...")
        # Initialize the Pinecone connection with API key and environment.
        # pinecone.init(api_key=PINECONE_API_KEY, environment=PINECONE_ENVIRONMENT)
        pc = Pinecone(api_key=PINECONE_API_KEY)
        print("Pinecone initialised")
        
        # Create a Pinecone collection with the specified index name.
        collection = create_pinecone_collection(pc, PINECONE_INDEX)
        
        # Same files are ignored (e.g. running process repetitively won't overwrite, just pick up new files)
        print("Pinecone index is up and collection is created")

        # Read KB documents in ./data directory and insert embeddings into Vector DB for each doc
        doc_dir = '/home/cdsw/data'
        for file in Path(doc_dir).glob(f'**/*.txt'):
            with open(file, "r") as f: # Open file in read mode
                print("Generating embeddings for: %s" % file.name)
                text = f.read()
                # Insert the embeddings into the Pinecone Vector DB.
                insert_embedding(collection, os.path.abspath(file), text)
        print('Finished loading Knowledge Base embeddings into Pinecone')

    except Exception as e:
        raise (e)


if __name__ == "__main__":
    main()
