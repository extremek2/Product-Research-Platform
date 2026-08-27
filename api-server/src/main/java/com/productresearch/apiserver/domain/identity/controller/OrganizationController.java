package com.productresearch.apiserver.domain.identity.controller;

import com.productresearch.apiserver.domain.identity.dto.*;
import com.productresearch.apiserver.domain.identity.service.IdentityService;
import com.productresearch.apiserver.global.response.ApiResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/organizations")
@RequiredArgsConstructor
public class OrganizationController {
    private final IdentityService identityService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<OrganizationResponse> create(@Valid @RequestBody CreateOrganizationRequest request) {
        return ApiResponse.ok("organization created", identityService.createOrganization(request));
    }
}
