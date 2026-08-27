package com.productresearch.apiserver.domain.auth.repository;

import com.productresearch.apiserver.domain.auth.entity.RefreshSession;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface RefreshSessionRepository extends JpaRepository<RefreshSession, Long> {
    Optional<RefreshSession> findByTokenHash(String tokenHash);
}
