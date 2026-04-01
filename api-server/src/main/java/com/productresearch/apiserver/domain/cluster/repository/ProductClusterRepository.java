package com.productresearch.apiserver.domain.cluster.repository;

import com.productresearch.apiserver.domain.cluster.entity.ProductCluster;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface ProductClusterRepository extends JpaRepository<ProductCluster, Long> {

    @Query("SELECT pc FROM ProductCluster pc ORDER BY pc.createdAt DESC")
    List<ProductCluster> findAllOrderByCreatedAtDesc();
}