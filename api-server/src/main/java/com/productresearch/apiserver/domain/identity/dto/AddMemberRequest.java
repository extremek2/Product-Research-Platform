package com.productresearch.apiserver.domain.identity.dto;

import com.productresearch.apiserver.domain.identity.entity.OrganizationMember;
import jakarta.validation.constraints.*;

public record AddMemberRequest(@NotBlank @Email @Size(max=255) String email,
                               @NotNull OrganizationMember.Role role,
                               @NotBlank @Size(max=500) String reason) {}
