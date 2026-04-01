package com.productresearch.apiserver.domain.product.repository;

import com.productresearch.apiserver.domain.product.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ProductRepository extends JpaRepository<Product, Long> {

    List<Product> findByBrand(String brand);
    List<Product> findByCategory(String category);
    List<Product> findByTitleContaining(String keyword);
}