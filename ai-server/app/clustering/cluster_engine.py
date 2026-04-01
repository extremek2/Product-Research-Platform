import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from app.clustering.embedder import embed_titles

def build_clusters(products: list) -> dict:
    titles = [p.title for p in products]  # normalized_title → title
    embeddings = embed_titles(titles)
    
    similarity_matrix = cosine_similarity(embeddings)
    
    clusters = {}
    cluster_id = 0
    assigned = set()
    
    for i, product in enumerate(products):
        if i in assigned:
            continue
        
        similar_indices = np.where(similarity_matrix[i] > 0.85)[0]
        clusters[cluster_id] = [products[idx] for idx in similar_indices]
        assigned.update(similar_indices)
        cluster_id += 1
        
    return clusters
