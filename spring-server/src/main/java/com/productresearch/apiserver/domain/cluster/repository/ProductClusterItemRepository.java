package com.productresearch.apiserver.domain.cluster.repository;

import com.productresearch.apiserver.domain.cluster.entity.ProductClusterItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ProductClusterItemRepository extends JpaRepository<ProductClusterItem, Long> {

    List<ProductClusterItem> findByClusterId(Long clusterId);
    List<ProductClusterItem> findByProductId(Long productId);
}
