import chromadb
from chromadb.config import Settings

# Initialize Chroma client (persistent DB)
client = chromadb.Client(Settings(
    persist_directory="./chroma_db",
    anonymized_telemetry=False
))

collection = client.get_or_create_collection(name="lilly_memory")


def store_vector(text: str, metadata: dict = None):
    collection.add(
        documents=[text],
        metadatas=[metadata or {}],
        ids=[str(hash(text))]
    )


def retrieve_context(query: str, n_results: int = 3):
    results = collection.query(
        query_texts=[query],
        n_results=n_results
    )

    return results.get("documents", [[]])[0]
