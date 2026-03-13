import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from app.clustering.embedder import embed_titles

def build_clusters(products: list) -> dict:
    """
    Product 객체 리스트를 받아서 클러스터링 후 결과 반환
    """
    titles = [p.normalized_title for p in products]  # 이미 normalize된 제목
    embeddings = embed_titles(titles)
    
    # cosine similarity 계산
    similarity_matrix = cosine_similarity(embeddings)
    
    clusters = {}
    cluster_id = 0
    assigned = set()
    
    for i, product in enumerate(products):
        if i in assigned:
            continue
        
        # i와 유사도가 0.85 이상인 상품 모으기
        similar_indices = np.where(similarity_matrix[i] > 0.85)[0]
        clusters[cluster_id] = [products[idx] for idx in similar_indices]
        assigned.update(similar_indices)
        cluster_id += 1
        
    return clusters