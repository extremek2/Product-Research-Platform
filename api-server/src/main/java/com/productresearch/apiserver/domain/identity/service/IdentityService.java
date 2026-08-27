package com.productresearch.apiserver.domain.identity.service;

import com.productresearch.apiserver.domain.identity.dto.*;
import com.productresearch.apiserver.domain.identity.entity.*;
import com.productresearch.apiserver.domain.identity.repository.*;
import com.productresearch.apiserver.global.exception.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class IdentityService {
    private final OrganizationRepository organizationRepository;
    private final AppUserRepository appUserRepository;
    private final OrganizationMemberRepository memberRepository;

    @Transactional
    public OrganizationResponse createOrganization(CreateOrganizationRequest request) {
        if (appUserRepository.existsByEmailIgnoreCase(request.ownerEmail())) {
            throw new BusinessException("이미 등록된 사용자 이메일입니다.");
        }
        Organization organization = organizationRepository.save(new Organization(request.name(), request.organizationType(),
                request.businessNumber(), request.email(), request.phone()));
        AppUser owner = appUserRepository.save(new AppUser(request.ownerEmail(), request.ownerName(), request.ownerPhone()));
        memberRepository.save(new OrganizationMember(organization, owner, OrganizationMember.Role.OWNER));
        return OrganizationResponse.of(organization, owner);
    }

    @Transactional(readOnly = true)
    public Organization requireOrganization(UUID publicId) {
        return organizationRepository.findByPublicId(publicId)
                .orElseThrow(() -> new ResourceNotFoundException("조직을 찾을 수 없습니다."));
    }

    @Transactional(readOnly = true)
    public AppUser requireMember(UUID userPublicId, Organization organization) {
        AppUser user = appUserRepository.findByPublicId(userPublicId)
                .orElseThrow(() -> new ResourceNotFoundException("사용자를 찾을 수 없습니다."));
        if (!memberRepository.existsByOrganizationIdAndUserIdAndStatus(organization.getId(), user.getId(), OrganizationMember.Status.ACTIVE)) {
            throw new BusinessException("해당 사용자는 화물 소유 조직의 활성 구성원이 아닙니다.");
        }
        return user;
    }
}
