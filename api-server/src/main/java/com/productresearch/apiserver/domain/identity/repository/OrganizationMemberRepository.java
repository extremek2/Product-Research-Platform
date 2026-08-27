package com.productresearch.apiserver.domain.identity.repository;

import com.productresearch.apiserver.domain.identity.entity.OrganizationMember;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.*;

public interface OrganizationMemberRepository extends JpaRepository<OrganizationMember, Long> {
    boolean existsByOrganizationIdAndUserIdAndStatus(Long organizationId, Long userId, OrganizationMember.Status status);
    List<OrganizationMember> findAllByUserIdAndStatus(Long userId, OrganizationMember.Status status);
    Optional<OrganizationMember> findByUserIdAndOrganizationIdAndStatus(Long userId, Long organizationId, OrganizationMember.Status status);
}
