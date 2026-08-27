package com.productresearch.apiserver.domain.auth.dto;

import jakarta.validation.constraints.*;

public record SignupRequest(@NotBlank String organizationName, String businessNumber, @NotBlank String name,
                            @NotBlank @Email String email, @NotBlank @Size(min = 8, max = 72) String password,
                            String phone) {}
