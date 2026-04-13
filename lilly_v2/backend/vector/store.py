import faiss, numpy as np

index = faiss.IndexFlatL2(384)
memory = []

def embed(text):
    vec = np.random.rand(384).astype("float32")
    return vec

def store(text):
    vec = embed(text)
    index.add(np.array([vec]))
    memory.append(text)

def search(text):
    if len(memory)==0:
        return ""
    vec = embed(text)
    D,I = index.search(np.array([vec]),1)
    return memory[I[0][0]]
