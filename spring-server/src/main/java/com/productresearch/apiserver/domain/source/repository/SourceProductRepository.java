package com.productresearch.apiserver.domain.source.repository;

import com.productresearch.apiserver.domain.source.entity.SourceProduct;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface SourceProductRepository extends JpaRepository<SourceProduct, Long> {

    Optional<SourceProduct> findBySourceAndSourceProductId(
            String source,
            String sourceProductId
    );

    List<SourceProduct> findBySource(String source);
}