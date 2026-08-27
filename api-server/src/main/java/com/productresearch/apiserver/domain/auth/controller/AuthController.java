package com.productresearch.apiserver.domain.auth.controller;

import com.productresearch.apiserver.domain.auth.dto.*;
import com.productresearch.apiserver.domain.auth.service.AuthService;
import com.productresearch.apiserver.global.exception.BusinessException;
import com.productresearch.apiserver.global.exception.AuthenticationFailedException;
import com.productresearch.apiserver.global.response.ApiResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {
    private static final String REFRESH_COOKIE = "trade_ops_refresh";
    private final AuthService authService;
    @Value("${app.auth.refresh-token-days}") private long refreshDays;
    @Value("${app.auth.secure-cookie}") private boolean secureCookie;

    @PostMapping("/signup")
    @ResponseStatus(HttpStatus.CREATED)
    public ResponseEntity<ApiResponse<AuthResponse>> signup(@Valid @RequestBody SignupRequest request) {
        return response(authService.signup(request), HttpStatus.CREATED);
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody LoginRequest request) {
        return response(authService.login(request), HttpStatus.OK);
    }

    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<AuthResponse>> refresh(@CookieValue(name = REFRESH_COOKIE, required = false) String token) {
        if (token == null) throw new AuthenticationFailedException("Refresh Token이 없습니다.");
        return response(authService.refresh(token), HttpStatus.OK);
    }

    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Void>> logout(@CookieValue(name = REFRESH_COOKIE, required = false) String token) {
        if (token != null) authService.logout(token);
        return ResponseEntity.ok().header(HttpHeaders.SET_COOKIE, cookie("", 0).toString()).body(ApiResponse.ok(null));
    }

    @GetMapping("/me")
    public ApiResponse<AuthResponse.UserContext> me() { return ApiResponse.ok(authService.me()); }

    private ResponseEntity<ApiResponse<AuthResponse>> response(AuthService.Tokens tokens, HttpStatus status) {
        return ResponseEntity.status(status).header(HttpHeaders.SET_COOKIE, cookie(tokens.refreshToken(), refreshDays * 86400).toString())
                .body(ApiResponse.ok(tokens.response()));
    }
    private ResponseCookie cookie(String value, long maxAge) {
        return ResponseCookie.from(REFRESH_COOKIE, value).httpOnly(true).secure(secureCookie).sameSite("Strict")
                .path("/api/v1/auth").maxAge(maxAge).build();
    }
}
