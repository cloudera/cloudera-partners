import os
from pinecone import Pinecone, ServerlessSpec
from sentence_transformers import SentenceTransformer

EMBEDDING_MODEL_REPO = "sentence-transformers/all-mpnet-base-v2"

# Get env variables
PINECONE_API_KEY = os.getenv('PINECONE_API_KEY')
PINECONE_INDEX = os.getenv('PINECONE_INDEX')

dimension = 768

# Get embeddings for a user question and query Pinecone vector DB for nearest knowledge base chunk
def get_nearest_chunk_from_pinecone_vectordb(index, question):
    # Generate embedding for user question with embedding model
    retriever = SentenceTransformer(EMBEDDING_MODEL_REPO)
    xq = retriever.encode([question]).tolist()
    xc = index.query(vector=xq, top_k=5,
                 include_metadata=True)
    
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
    return response, sources, score

# Return the Knowledge Base doc based on Knowledge Base ID (relative file path)
def load_context_chunk_from_data(id_path):
    with open(id_path, "r") as f: # Open file in read mode
        return f.read()

def find_matching_chunk(query: str):
    print("initialising Pinecone connection...")
    pc = Pinecone(api_key=PINECONE_API_KEY)
        
    print("Pinecone initialised")
    print(f"Getting '{PINECONE_INDEX}' as object...")
    index = pc.Index(PINECONE_INDEX)
    print("Success")

    context_chunk, sources, score = get_nearest_chunk_from_pinecone_vectordb(index, query)
    print("\nContext Chunk: ")
    print(context_chunk)
    print("\nContext Source(s): ")
    print(sources)
    print("\nPinecone Score: ")
    print(score)

    return context_chunk, score


