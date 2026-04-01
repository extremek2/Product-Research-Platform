package com.productresearch.apiserver.domain.cluster.controller;

import com.productresearch.apiserver.domain.cluster.entity.ProductCluster;
import com.productresearch.apiserver.domain.cluster.entity.ProductClusterItem;
import com.productresearch.apiserver.domain.cluster.service.ProductClusterService;
import com.productresearch.apiserver.global.response.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/clusters")
@RequiredArgsConstructor
@Tag(name = "Cluster", description = "클러스터 API")
public class ProductClusterController {

    private final ProductClusterService clusterService;

    @GetMapping
    @Operation(summary = "전체 클러스터 조회")
    public ApiResponse<List<ProductCluster>> findAll() {
        return ApiResponse.ok(clusterService.findAll());
    }

    @GetMapping("/{id}")
    @Operation(summary = "클러스터 단건 조회")
    public ApiResponse<ProductCluster> findById(@PathVariable Long id) {
        return ApiResponse.ok(clusterService.findById(id));
    }

    @GetMapping("/{id}/items")
    @Operation(summary = "클러스터 내 상품 목록 조회")
    public ApiResponse<List<ProductClusterItem>> findItems(@PathVariable Long id) {
        return ApiResponse.ok(clusterService.findItemsByClusterId(id));
    }
}