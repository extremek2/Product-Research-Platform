package com.productresearch.apiserver.domain.collaboration;

import jakarta.validation.constraints.*;
import java.util.UUID;

public final class CollaborationRequests {
    public enum CompanyType { FORWARDER, CUSTOMS_BROKER }
    public enum Level { VIEWER, CONTRIBUTOR }
    public record Company(@NotBlank @Size(max=200) String name, @NotNull CompanyType type) {}
    public record Attach(@NotNull UUID companyId) {}
    public record Invite(@NotBlank @Size(max=200) String name, @NotBlank @Email @Size(max=255) String email,
                         @NotNull Level accessLevel) {}
    public record Revoke(@NotBlank @Size(max=500) String reason) {}
    public record RequestLink(@NotNull UUID invitationId, @NotBlank @Email @Size(max=255) String email) {}
    public record Confirm(@NotBlank @Pattern(regexp="[A-Za-z0-9_-]{43}") String token) {}
}
