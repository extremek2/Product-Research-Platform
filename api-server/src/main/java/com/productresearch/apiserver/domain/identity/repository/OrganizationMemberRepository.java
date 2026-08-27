package com.productresearch.apiserver.domain.identity.repository;

import com.productresearch.apiserver.domain.identity.entity.OrganizationMember;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OrganizationMemberRepository extends JpaRepository<OrganizationMember, Long> {
    boolean existsByOrganizationIdAndUserIdAndStatus(Long organizationId, Long userId, OrganizationMember.Status status);
}
