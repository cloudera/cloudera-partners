import os
import cml.data_v1 as cmldata
import hashlib
import torch
import torch.nn.functional as F
from transformers import AutoTokenizer, AutoModel
from pinecone import Pinecone, ServerlessSpec
from sentence_transformers import SentenceTransformer

PINECONE_API_KEY = os.getenv('PINECONE_API_KEY')
PINECONE_INDEX = os.getenv('PINECONE_INDEX')
dimension = 768

EMBEDDING_MODEL_REPO = "sentence-transformers/all-mpnet-base-v2"

tokenizer = AutoTokenizer.from_pretrained(EMBEDDING_MODEL_REPO)
model = AutoModel.from_pretrained(EMBEDDING_MODEL_REPO)


def hash_path_to_key(path: str) -> str:
    return hashlib.sha256(path.encode()).hexdigest()

def create_pinecone_collection(pc, index_name):
    try:
        print(f"Creating 768-dimensional index called '{index_name}'...")
        pc.create_index(index_name, dimension=dimension, spec=ServerlessSpec(
            cloud="aws",
            region="us-east-1"
        ))
        print("Success")
    except Exception as e:
        if hasattr(e, "status") and e.status == 409:
            print(f"Index '{index_name}' already exists. Continuing without creating a new index.")
        else:
            print(f"Failed to create index '{index_name}': {e}")
            raise
    
    print("Checking Pinecone for active indexes...")
    active_indexes = pc.list_indexes()
    print("Active indexes:")
    print(active_indexes)
    print(f"Getting description for '{index_name}'...")
    index_description = pc.describe_index(index_name)
    print("Description:")
    print(index_description)

    print(f"Getting '{index_name}' as object...")
    pinecone_index = pc.Index(index_name)
    print("Success")

    return pinecone_index

def mean_pooling(model_output, attention_mask):
    token_embeddings = model_output[0]
    input_mask_expanded = attention_mask.unsqueeze(-1).expand(token_embeddings.size()).float()
    return torch.sum(token_embeddings * input_mask_expanded, 1) / torch.clamp(input_mask_expanded.sum(1), min=1e-9)

def get_embeddings(sentence):
    sentences = [sentence]
    encoded_input = tokenizer(sentences, padding='max_length', truncation=True, return_tensors='pt')
    with torch.no_grad():
        model_output = model(**encoded_input)
    sentence_embeddings = mean_pooling(model_output, encoded_input['attention_mask'])
    sentence_embeddings = F.normalize(sentence_embeddings, p=2, dim=1)
    return sentence_embeddings.tolist()[0]

def insert_embedding(pinecone_index, id_path, text):
    print("Upserting vectors...")
    vectors = [(hash_path_to_key(id_path), get_embeddings(text), {"s3_prefix": id_path})]
    try:
        upsert_response = pinecone_index.upsert(vectors=vectors)
        print("Success")
    except Exception as e:
        print(f"Failed to upsert vectors: {e}")
        raise

def load_files(pinecone_collection):

    try:
        CONNECTION_NAME = "S3 Object Store"
        conn = cmldata.get_connection(CONNECTION_NAME)

        # Sample usage
        client = conn.get_base_connection()
        doc_prefixes = []
        response = client.list_objects_v2(Bucket=os.getenv('POLICY_BUCKET'), Prefix=os.getenv('POLICY_BUCKET_PREFIX'))

        if "Contents" in response:
            for obj in response["Contents"]:
                # Skip empty "folder" objects
                if obj["Key"].endswith("/") and obj["Size"] == 0:
                    continue  
                doc_prefixes.append(obj["Key"])
        else:
            print("No objects found.")

        for prefix in doc_prefixes:
            file = client.get_object(Bucket=os.getenv('POLICY_BUCKET'), Key=prefix)
            body = file["Body"].read().decode("utf-8")
            insert_embedding(pinecone_collection, prefix, body)

        client.close()

    except Exception as e:
        print(f"An error occurred: {e}")
        raise

def main():
    try:
        print("Initializing Pinecone connection...")
        pc = Pinecone(api_key=PINECONE_API_KEY)
        print("Pinecone initialized")

        collection = create_pinecone_collection(pc, PINECONE_INDEX)
        print("Pinecone index is up, collection created")

        load_files(collection)
        print('Finished loading Knowledge Base embeddings into Pinecone')

    except Exception as e:
        print(f"An error occurred: {e}")
        raise


if __name__ == "__main__":
    main()