import os

## Initialize a connection to the running Chroma DB server
import chromadb
from pathlib import Path

# chroma_client = chromadb.Client()
chroma_client = chromadb.PersistentClient(path="/home/cdsw/chroma-data")

from chromadb.utils import embedding_functions
EMBEDDING_MODEL_REPO = "sentence-transformers/all-mpnet-base-v2"
EMBEDDING_MODEL_NAME = "all-mpnet-base-v2"
EMBEDDING_FUNCTION = embedding_functions.SentenceTransformerEmbeddingFunction(model_name=EMBEDDING_MODEL_NAME)

COLLECTION_NAME = 'cml-default'

print("initialising Chroma DB connection...")

print(f"Getting '{COLLECTION_NAME}' as object...")
try:
    chroma_client.get_collection(name=COLLECTION_NAME, embedding_function=EMBEDDING_FUNCTION)
    print("Success")
    collection = chroma_client.get_collection(name=COLLECTION_NAME, embedding_function=EMBEDDING_FUNCTION)
except:
    print("Creating new collection...")
    collection = chroma_client.create_collection(name=COLLECTION_NAME, embedding_function=EMBEDDING_FUNCTION)
    print("Success")

# Get latest statistics from index
current_collection_stats = collection.count()
print('Total number of embeddings in Chroma DB index is ' + str(current_collection_stats))

# Helper function for adding documents to the Chroma DB
def upsert_document(collection, document, metadata=None, classification="public", file_path=None):
    
    # Push document to Chroma vector db (if file path is not available, will use first 50 characters of document)
    if file_path is not None:
        response = collection.add(
            documents=[document],
            metadatas=[{"classification": classification}],
            ids=[file_path]
        )
    else:
        response = collection.add(
            documents=[document],
            metadatas=[{"classification": classification}],
            ids=document[:50]
        )
    return response

# Return the Knowledge Base doc based on Knowledge Base ID (relative file path)
def load_context_chunk_from_data(id_path):
    with open(id_path, "r") as f: # Open file in read mode
        return f.read()

# Read KB documents in ./data directory and insert embeddings into Vector DB for each doc
doc_dir = '/home/cdsw/data'
for file in Path(doc_dir).glob(f'**/*.txt'):
    print(file)
    with open(file, "r") as f: # Open file in read mode
        print("Generating embeddings for: %s" % file.name)
        text = f.read()
        upsert_document(collection=collection, document=text, file_path=os.path.abspath(file))
print('Finished loading Knowledge Base embeddings into Chroma DB')

