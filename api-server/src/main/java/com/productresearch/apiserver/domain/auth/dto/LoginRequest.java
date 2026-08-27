package com.productresearch.apiserver.domain.auth.dto;

import jakarta.validation.constraints.*;
import java.util.UUID;

public record LoginRequest(@NotBlank @Email String email, @NotBlank String password, UUID organizationId) {}
