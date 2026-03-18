package com.productresearch.apiserver.domain.cluster.service;

import com.productresearch.apiserver.domain.cluster.entity.ProductCluster;
import com.productresearch.apiserver.domain.cluster.entity.ProductClusterItem;
import com.productresearch.apiserver.domain.cluster.repository.ProductClusterItemRepository;
import com.productresearch.apiserver.domain.cluster.repository.ProductClusterRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ProductClusterService {

    private final ProductClusterRepository clusterRepository;
    private final ProductClusterItemRepository clusterItemRepository;

    public List<ProductCluster> findAll() {
        return clusterRepository.findAllOrderByCreatedAtDesc();
    }

    public ProductCluster findById(Long id) {
        return clusterRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("클러스터를 찾을 수 없습니다. id=" + id));
    }

    public List<ProductClusterItem> findItemsByClusterId(Long clusterId) {
        return clusterItemRepository.findByClusterId(clusterId);
    }
}