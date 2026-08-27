package com.productresearch.apiserver.domain.shipment.repository;

import com.productresearch.apiserver.domain.shipment.entity.ShipmentCase;
import org.springframework.data.jpa.repository.*;
import java.util.*;

public interface ShipmentCaseRepository extends JpaRepository<ShipmentCase, Long>, JpaSpecificationExecutor<ShipmentCase> {
    Optional<ShipmentCase> findByPublicIdAndOwnerOrganizationPublicId(UUID publicId, UUID organizationPublicId);
    boolean existsByOwnerOrganizationIdAndCaseNumber(Long organizationId, String caseNumber);
}
