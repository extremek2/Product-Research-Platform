package com.productresearch.apiserver.domain.identity.dto;

import com.productresearch.apiserver.domain.identity.entity.OrganizationMember;
import jakarta.validation.constraints.*;

public record ChangeMemberRequest(@NotNull OrganizationMember.Role role, @NotNull OrganizationMember.Status status,
                                  @NotNull @PositiveOrZero Long version, @NotBlank @Size(max=500) String reason) {}
