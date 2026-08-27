package com.productresearch.apiserver.domain.identity.repository;

import com.productresearch.apiserver.domain.identity.entity.Organization;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.*;

public interface OrganizationRepository extends JpaRepository<Organization, Long> {
    Optional<Organization> findByPublicId(UUID publicId);
}
