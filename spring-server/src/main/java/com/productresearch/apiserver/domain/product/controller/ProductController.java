package com.productresearch.apiserver.domain.product.controller;

import com.productresearch.apiserver.domain.product.entity.Product;
import com.productresearch.apiserver.domain.product.service.ProductService;
import com.productresearch.apiserver.global.response.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/products")
@RequiredArgsConstructor
@Tag(name = "Product", description = "상품 API")
public class ProductController {

    private final ProductService productService;

    @GetMapping
    @Operation(summary = "전체 상품 조회")
    public ApiResponse<List<Product>> findAll() {
        return ApiResponse.ok(productService.findAll());
    }

    @GetMapping("/{id}")
    @Operation(summary = "상품 단건 조회")
    public ApiResponse<Product> findById(@PathVariable Long id) {
        return ApiResponse.ok(productService.findById(id));
    }

    @GetMapping("/search")
    @Operation(summary = "키워드로 상품 검색")
    public ApiResponse<List<Product>> search(@RequestParam String keyword) {
        return ApiResponse.ok(productService.findByKeyword(keyword));
    }

    @GetMapping("/brand/{brand}")
    @Operation(summary = "브랜드로 상품 조회")
    public ApiResponse<List<Product>> findByBrand(@PathVariable String brand) {
        return ApiResponse.ok(productService.findByBrand(brand));
    }
}