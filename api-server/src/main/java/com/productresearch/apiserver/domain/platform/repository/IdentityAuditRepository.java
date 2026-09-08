package com.productresearch.apiserver.domain.platform.repository;
import com.productresearch.apiserver.domain.platform.entity.IdentityAuditEvent;
import org.springframework.data.jpa.repository.JpaRepository;
public interface IdentityAuditRepository extends JpaRepository<IdentityAuditEvent, Long> {}
