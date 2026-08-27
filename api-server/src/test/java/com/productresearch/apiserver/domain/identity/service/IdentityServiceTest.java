package com.productresearch.apiserver.domain.identity.service;

import com.productresearch.apiserver.domain.identity.dto.*;
import com.productresearch.apiserver.domain.identity.entity.*;
import com.productresearch.apiserver.domain.identity.repository.*;
import com.productresearch.apiserver.global.exception.BusinessException;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.*;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class IdentityServiceTest {
    @Mock OrganizationRepository organizationRepository;
    @Mock AppUserRepository appUserRepository;
    @Mock OrganizationMemberRepository memberRepository;
    @InjectMocks IdentityService identityService;

    private CreateOrganizationRequest request() {
        return new CreateOrganizationRequest("화주 A", Organization.Type.SHIPPER, null, null, null,
                "owner@example.com", "담당자", null);
    }

    @Test
    void createsOrganizationOwnerAndMembershipTogether() {
        when(appUserRepository.existsByEmailIgnoreCase("owner@example.com")).thenReturn(false);
        when(organizationRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));
        when(appUserRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

        OrganizationResponse response = identityService.createOrganization(request());

        assertThat(response.organizationType()).isEqualTo(Organization.Type.SHIPPER);
        assertThat(response.ownerStatus()).isEqualTo(AppUser.Status.INVITED);
        assertThat(response.organizationId()).isNotNull();
        assertThat(response.ownerUserId()).isNotNull();
        verify(memberRepository).save(argThat(member -> member.getMemberRole() == OrganizationMember.Role.OWNER));
    }

    @Test
    void rejectsDuplicateOwnerEmail() {
        when(appUserRepository.existsByEmailIgnoreCase("owner@example.com")).thenReturn(true);

        assertThatThrownBy(() -> identityService.createOrganization(request()))
                .isInstanceOf(BusinessException.class)
                .hasMessageContaining("이미 등록된");
        verifyNoInteractions(organizationRepository, memberRepository);
    }
}
