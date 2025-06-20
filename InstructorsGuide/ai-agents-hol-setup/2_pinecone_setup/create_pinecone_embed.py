import os
import hashlib
import torch
import torch.nn.functional as F
from transformers import AutoTokenizer, AutoModel
from pinecone import Pinecone, ServerlessSpec
from sentence_transformers import SentenceTransformer

# --- Environment Variables and Constants ---
PINECONE_API_KEY = os.getenv('PINECONE_API_KEY')
PINECONE_INDEX = os.getenv('PINECONE_INDEX')
DIMENSION = 768
EMBEDDING_MODEL_REPO = "sentence-transformers/all-mpnet-base-v2"

# --- Model Initialization ---
print("Loading embedding model...")
tokenizer = AutoTokenizer.from_pretrained(EMBEDDING_MODEL_REPO)
model = AutoModel.from_pretrained(EMBEDDING_MODEL_REPO)
print("Model loaded successfully.")

# --- Helper Functions ---

def hash_path_to_key(path: str) -> str:
    """Hashes a file path to create a unique and stable ID."""
    return hashlib.sha256(path.encode()).hexdigest()

def create_pinecone_collection(pc: Pinecone, index_name: str):
    """Creates a Pinecone index if it doesn't already exist."""
    try:
        print(f"Creating {DIMENSION}-dimensional index called '{index_name}'...")
        pc.create_index(
            name=index_name,
            dimension=DIMENSION,
            metric="cosine",
            spec=ServerlessSpec(
                cloud="aws",
                region="us-east-1"
            )
        )
        print("Success")
    except Exception as e:
        # Check if the error is because the index already exists (conflict error)
        if hasattr(e, "status") and e.status == 409:
            print(f"Index '{index_name}' already exists. Continuing.")
        else:
            print(f"Failed to create index '{index_name}': {e}")
            raise

    print("Checking Pinecone for active indexes...")
    active_indexes = pc.list_indexes()
    print(f"Active indexes: {active_indexes}")

    print(f"Getting description for '{index_name}'...")
    index_description = pc.describe_index(index_name)
    print(f"Description: {index_description}")

    print(f"Getting '{index_name}' as an index object...")
    pinecone_index = pc.Index(index_name)
    print("Success")
    return pinecone_index

def mean_pooling(model_output, attention_mask):
    """Performs mean pooling on token embeddings."""
    token_embeddings = model_output[0]
    input_mask_expanded = attention_mask.unsqueeze(-1).expand(token_embeddings.size()).float()
    return torch.sum(token_embeddings * input_mask_expanded, 1) / torch.clamp(input_mask_expanded.sum(1), min=1e-9)

def get_embeddings(sentence: str):
    """Generates embeddings for a given sentence."""
    sentences = [sentence]
    encoded_input = tokenizer(sentences, padding=True, truncation=True, return_tensors='pt')
    with torch.no_grad():
        model_output = model(**encoded_input)
    sentence_embeddings = mean_pooling(model_output, encoded_input['attention_mask'])
    sentence_embeddings = F.normalize(sentence_embeddings, p=2, dim=1)
    return sentence_embeddings.tolist()[0]

def insert_embedding(pinecone_index, id_path: str, text: str):
    """Generates and upserts a vector for a given text file."""
    print(f"Upserting vector for: {id_path}")
    vector_id = hash_path_to_key(id_path)
    embedding = get_embeddings(text)
    metadata = {"file_path": id_path, "original_text": text[:200]} # Add a snippet of text to metadata
    
    vectors_to_upsert = [(vector_id, embedding, metadata)]
    
    try:
        pinecone_index.upsert(vectors=vectors_to_upsert)
        print("Success")
    except Exception as e:
        print(f"Failed to upsert vector: {e}")
        raise

def load_files_and_embed(pinecone_collection, local_directory="policy_documents"):
    """
    Reads all text files from a local directory, generates embeddings,
    and uploads them to Pinecone.
    """
    print(f"Loading files from local directory: '{local_directory}'")
    try:
        if not os.path.isdir(local_directory):
            raise FileNotFoundError(f"The directory '{local_directory}' was not found.")

        for filename in os.listdir(local_directory):
            file_path = os.path.join(local_directory, filename)

            if os.path.isfile(file_path) and filename.endswith(".txt"):
                print(f"Processing file: {file_path}")
                with open(file_path, 'r', encoding='utf-8') as f:
                    body = f.read()
                
                # Ensure content is not empty
                if body.strip():
                    insert_embedding(pinecone_collection, file_path, body)
                else:
                    print(f"Skipping empty file: {file_path}")

        print("\nFinished processing all local files.")
    except Exception as e:
        print(f"An error occurred during file loading and embedding: {e}")
        raise

# --- Main Execution Block ---

# --- Main Execution Block ---

def main():
    """Main function to run the data embedding pipeline, corrected for Jupyter Notebooks."""
    # Check for required environment variables
    if not PINECONE_API_KEY or not PINECONE_INDEX:
        print("Error: 'PINECONE_API_KEY' and 'PINECONE_INDEX' environment variables must be set.")
        return

    try:
        # --- KEY FIX FOR JUPYTER NOTEBOOKS ---
        # In a notebook, we start from the 'current working directory' instead of using '__file__'
        current_directory = os.getcwd()
        print(f"Notebook's current working directory: {current_directory}")

        # The 'policy_documents' folder is at the project root. We need to find the root
        # relative to this notebook's location. This code will search upwards from the
        # current directory until it finds the folder.
        
        project_root = current_directory
        # Search up a few levels to find the directory
        for _ in range(4):
            if 'policy_documents' in os.listdir(project_root):
                break
            project_root = os.path.dirname(project_root)
        
        # Construct the absolute path to the policy_documents folder
        data_directory = os.path.join(project_root, 'policy_documents')

        if not os.path.isdir(data_directory):
            raise FileNotFoundError(f"Could not find 'policy_documents' directory. Path tried: {data_directory}")

        print(f"Successfully located data directory at: {data_directory}")
        
        # --- The rest of the script continues as before ---
        print("Initializing Pinecone connection...")
        pc = Pinecone(api_key=PINECONE_API_KEY)
        print("Pinecone initialized.")

        collection = create_pinecone_collection(pc, PINECONE_INDEX)
        print("Pinecone index is ready.")

        # Pass the correctly constructed, absolute path to the loading function
        # This ensures the paths stored in Pinecone are absolute and can be found later
        load_files_and_embed(collection, data_directory)
        
        print('Successfully finished loading Knowledge Base embeddings into Pinecone.')

    except Exception as e:
        print(f"A critical error occurred in the main function: {e}")
        raise

# IMPORTANT: After replacing the main() function,
# make sure you call it in the last cell of your notebook section:
#
if __name__ == "__main__":
    main()