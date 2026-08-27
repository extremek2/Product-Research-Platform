package com.productresearch.apiserver.domain.auth.dto;

import com.productresearch.apiserver.domain.identity.entity.OrganizationMember;
import java.util.UUID;

public record AuthResponse(String accessToken, long expiresInSeconds, UserContext user) {
    public record UserContext(UUID userId, String name, String email, UUID organizationId,
                              String organizationName, OrganizationMember.Role role) {}
}
