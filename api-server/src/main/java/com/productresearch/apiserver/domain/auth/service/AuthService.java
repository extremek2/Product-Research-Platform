package com.productresearch.apiserver.domain.auth.service;

import com.productresearch.apiserver.domain.auth.dto.*;
import com.productresearch.apiserver.domain.auth.entity.RefreshSession;
import com.productresearch.apiserver.domain.auth.repository.RefreshSessionRepository;
import com.productresearch.apiserver.domain.identity.entity.*;
import com.productresearch.apiserver.domain.identity.repository.*;
import com.productresearch.apiserver.global.exception.BusinessException;
import com.productresearch.apiserver.global.exception.AuthenticationFailedException;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.*;

@Service
@RequiredArgsConstructor
public class AuthService {
    private final OrganizationRepository organizationRepository; private final AppUserRepository userRepository;
    private final OrganizationMemberRepository memberRepository; private final RefreshSessionRepository refreshRepository;
    private final PasswordEncoder passwordEncoder; private final TokenService tokenService; private final CurrentActor currentActor;
    @Value("${app.auth.refresh-token-days}") private long refreshDays;

    @Transactional
    public Tokens signup(SignupRequest request) {
        if (userRepository.existsByEmailIgnoreCase(request.email())) throw new BusinessException("이미 등록된 이메일입니다.");
        Organization organization = organizationRepository.save(new Organization(request.organizationName(), Organization.Type.SHIPPER, request.businessNumber(), request.email(), request.phone()));
        AppUser user = userRepository.save(AppUser.registered(request.email(), passwordEncoder.encode(request.password()), request.name(), request.phone()));
        OrganizationMember member = memberRepository.save(new OrganizationMember(organization, user, OrganizationMember.Role.OWNER));
        return issue(user, member);
    }

    @Transactional
    public Tokens login(LoginRequest request) {
        AppUser user = userRepository.findByEmailIgnoreCase(request.email()).orElseThrow(() -> new AuthenticationFailedException("이메일 또는 비밀번호가 올바르지 않습니다."));
        if (user.getStatus() != AppUser.Status.ACTIVE || user.getPasswordHash() == null || !passwordEncoder.matches(request.password(), user.getPasswordHash()))
            throw new AuthenticationFailedException("이메일 또는 비밀번호가 올바르지 않습니다.");
        List<OrganizationMember> memberships = memberRepository.findAllByUserIdAndStatus(user.getId(), OrganizationMember.Status.ACTIVE);
        OrganizationMember member = selectMembership(memberships, request.organizationId());
        if (member.getOrganization().getStatus() != Organization.Status.ACTIVE) throw new BusinessException("비활성 조직입니다.");
        user.recordLogin(); return issue(user, member);
    }

    @Transactional
    public Tokens refresh(String rawToken) {
        RefreshSession session = refreshRepository.findByTokenHash(tokenService.hash(rawToken)).orElseThrow(() -> new AuthenticationFailedException("유효하지 않은 Refresh Token입니다."));
        if (!session.isUsable(LocalDateTime.now())) throw new AuthenticationFailedException("만료되었거나 폐기된 Refresh Token입니다.");
        OrganizationMember member = memberRepository.findByUserIdAndOrganizationIdAndStatus(session.getUser().getId(), session.getOrganization().getId(), OrganizationMember.Status.ACTIVE)
                .orElseThrow(() -> new BusinessException("활성 조직 소속이 아닙니다."));
        session.used(); session.revoke(); return issue(session.getUser(), member);
    }

    @Transactional
    public void logout(String rawToken) { refreshRepository.findByTokenHash(tokenService.hash(rawToken)).ifPresent(RefreshSession::revoke); }

    @Transactional(readOnly = true)
    public AuthResponse.UserContext me() { CurrentActor.Context c = currentActor.require(); return context(c.user(), c.member()); }

    private OrganizationMember selectMembership(List<OrganizationMember> memberships, UUID organizationId) {
        if (memberships.isEmpty()) throw new BusinessException("활성 조직 소속이 없습니다.");
        if (organizationId == null && memberships.size() == 1) return memberships.get(0);
        if (organizationId == null) throw new BusinessException("로그인할 조직을 선택해 주세요.");
        return memberships.stream().filter(m -> m.getOrganization().getPublicId().equals(organizationId)).findFirst()
                .orElseThrow(() -> new BusinessException("선택한 조직에 소속되어 있지 않습니다."));
    }

    private Tokens issue(AppUser user, OrganizationMember member) {
        String refresh = tokenService.newRefreshToken();
        refreshRepository.save(new RefreshSession(user, member.getOrganization(), tokenService.hash(refresh), LocalDateTime.now().plusDays(refreshDays)));
        return new Tokens(new AuthResponse(tokenService.createAccessToken(user, member), tokenService.accessTokenSeconds(), context(user, member)), refresh);
    }
    private AuthResponse.UserContext context(AppUser user, OrganizationMember member) { return new AuthResponse.UserContext(user.getPublicId(), user.getName(), user.getEmail(), member.getOrganization().getPublicId(), member.getOrganization().getName(), member.getMemberRole()); }
    public record Tokens(AuthResponse response, String refreshToken) {}
}
