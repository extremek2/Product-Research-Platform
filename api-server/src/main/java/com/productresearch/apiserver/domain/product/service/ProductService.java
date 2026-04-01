package com.productresearch.apiserver.domain.product.service;

import com.productresearch.apiserver.domain.product.entity.Product;
import com.productresearch.apiserver.domain.product.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ProductService {

    private final ProductRepository productRepository;

    public List<Product> findAll() {
        return productRepository.findAll();
    }

    public Product findById(Long id) {
        return productRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("상품을 찾을 수 없습니다. id=" + id));
    }

    public List<Product> findByKeyword(String keyword) {
        return productRepository.findByTitleContaining(keyword);
    }

    public List<Product> findByBrand(String brand) {
        return productRepository.findByBrand(brand);
    }
}