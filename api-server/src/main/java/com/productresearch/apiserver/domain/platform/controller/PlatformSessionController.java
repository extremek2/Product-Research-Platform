package com.productresearch.apiserver.domain.platform.controller;

import com.productresearch.apiserver.domain.auth.dto.AuthResponse;
import com.productresearch.apiserver.domain.auth.service.AuthService;
import com.productresearch.apiserver.global.response.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/system-admin")
@RequiredArgsConstructor
public class PlatformSessionController {
    private final AuthService auth;
    @GetMapping("/session")
    @PreAuthorize("hasRole('SYSTEM_ADMIN')")
    public ApiResponse<AuthResponse.UserContext> session() { return ApiResponse.ok(auth.me()); }
}
