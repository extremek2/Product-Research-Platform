package com.productresearch.apiserver.domain.auth.service;

import com.productresearch.apiserver.domain.identity.entity.*;
import com.productresearch.apiserver.domain.identity.repository.*;
import com.productresearch.apiserver.global.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class CurrentActor {
    private final AppUserRepository userRepository;
    private final OrganizationRepository organizationRepository;
    private final OrganizationMemberRepository memberRepository;

    @Transactional(readOnly = true)
    public Context require() {
        JwtAuthenticationToken authentication = (JwtAuthenticationToken) SecurityContextHolder.getContext().getAuthentication();
        AppUser user = userRepository.findByPublicId(UUID.fromString(authentication.getToken().getSubject()))
                .orElseThrow(() -> new ResourceNotFoundException("인증 사용자를 찾을 수 없습니다."));
        UUID organizationPublicId = UUID.fromString(authentication.getToken().getClaimAsString("organizationId"));
        Organization organization = organizationRepository.findByPublicId(organizationPublicId)
                .orElseThrow(() -> new ResourceNotFoundException("인증 조직을 찾을 수 없습니다."));
        OrganizationMember member = memberRepository.findByUserIdAndOrganizationIdAndStatus(user.getId(), organization.getId(), OrganizationMember.Status.ACTIVE)
                .orElseThrow(() -> new ResourceNotFoundException("활성 조직 소속을 찾을 수 없습니다."));
        return new Context(user, organization, member);
    }

    public record Context(AppUser user, Organization organization, OrganizationMember member) {}
}
