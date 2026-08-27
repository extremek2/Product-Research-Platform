package com.productresearch.apiserver.domain.shipment.controller;

import com.productresearch.apiserver.domain.shipment.dto.*;
import com.productresearch.apiserver.domain.shipment.entity.ShipmentCase;
import com.productresearch.apiserver.domain.shipment.service.ShipmentService;
import com.productresearch.apiserver.global.response.ApiResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/api/v1/shipments")
@RequiredArgsConstructor
public class ShipmentController {
    private final ShipmentService shipmentService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<ShipmentResponse> create(@Valid @RequestBody CreateShipmentRequest request) {
        return ApiResponse.ok("shipment created", shipmentService.create(request));
    }

    @GetMapping
    public ApiResponse<List<ShipmentResponse>> findAll(
            @RequestParam UUID organizationId,
            @RequestParam(required = false) ShipmentCase.Status status,
            @RequestParam(required = false) ShipmentCase.Priority priority,
            @RequestParam(required = false) ShipmentCase.Stage stage,
            @RequestParam(defaultValue = "false") boolean includeArchived) {
        return ApiResponse.ok(shipmentService.findAll(organizationId, status, priority, stage, includeArchived));
    }

    @GetMapping("/{shipmentId}")
    public ApiResponse<ShipmentResponse> findOne(@PathVariable UUID shipmentId, @RequestParam UUID organizationId) {
        return ApiResponse.ok(shipmentService.findOne(shipmentId, organizationId));
    }

    @PatchMapping("/{shipmentId}")
    public ApiResponse<ShipmentResponse> update(@PathVariable UUID shipmentId, @RequestParam UUID organizationId,
                                                @Valid @RequestBody UpdateShipmentRequest request) {
        return ApiResponse.ok(shipmentService.update(shipmentId, organizationId, request));
    }

    @PostMapping("/{shipmentId}/archive")
    public ApiResponse<ShipmentResponse> archive(@PathVariable UUID shipmentId, @RequestParam UUID organizationId) {
        return ApiResponse.ok(shipmentService.archive(shipmentId, organizationId));
    }

    @PostMapping("/{shipmentId}/documents")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<TransportDocumentResponse> addDocument(@PathVariable UUID shipmentId, @RequestParam UUID organizationId,
                                                               @Valid @RequestBody CreateTransportDocumentRequest request) {
        return ApiResponse.ok("document created", shipmentService.addDocument(shipmentId, organizationId, request));
    }

    @GetMapping("/{shipmentId}/documents")
    public ApiResponse<List<TransportDocumentResponse>> findDocuments(@PathVariable UUID shipmentId,
                                                                      @RequestParam UUID organizationId) {
        return ApiResponse.ok(shipmentService.findDocuments(shipmentId, organizationId));
    }
}
