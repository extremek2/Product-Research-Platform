from sentence_transformers import SentenceTransformer
import numpy as np

# 사전 학습된 문장 임베딩 모델 로드
model = SentenceTransformer('all-MiniLM-L6-v2')

def embed_titles(titles: list[str]) -> np.ndarray:
    """
    상품명 리스트를 받아 임베딩 벡터 반환
    """
    embeddings = model.encode(titles, convert_to_numpy=True, normalize_embeddings=True)
    return embeddings