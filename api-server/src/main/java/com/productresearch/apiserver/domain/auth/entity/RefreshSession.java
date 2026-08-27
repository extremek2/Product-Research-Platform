package com.productresearch.apiserver.domain.auth.entity;

import com.productresearch.apiserver.domain.identity.entity.*;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "refresh_session")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class RefreshSession {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "user_id") private AppUser user;
    @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "organization_id") private Organization organization;
    @Column(name = "token_hash", nullable = false, unique = true) private String tokenHash;
    @Column(name = "expires_at", nullable = false) private LocalDateTime expiresAt;
    @Column(name = "revoked_at") private LocalDateTime revokedAt;
    @Column(name = "last_used_at") private LocalDateTime lastUsedAt;
    @Column(name = "created_at", nullable = false, updatable = false) private LocalDateTime createdAt;

    public RefreshSession(AppUser user, Organization organization, String tokenHash, LocalDateTime expiresAt) {
        this.user=user; this.organization=organization; this.tokenHash=tokenHash; this.expiresAt=expiresAt;
    }
    public boolean isUsable(LocalDateTime now) { return revokedAt == null && expiresAt.isAfter(now); }
    public void revoke() { revokedAt = LocalDateTime.now(); }
    public void used() { lastUsedAt = LocalDateTime.now(); }
    @PrePersist void create() { createdAt = LocalDateTime.now(); }
}
