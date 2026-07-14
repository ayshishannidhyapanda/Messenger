package com.messenger.config;

import com.messenger.dto.ApiResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.factory.PasswordEncoderFactories;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import tools.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

/*
 * Copyright (c) 2026 Ayshi Shannidhya Panda. All rights reserved.
 *
 * This source code is confidential and intended solely for internal use.
 * Unauthorized copying, modification, distribution, or disclosure of this
 * file, via any medium, is strictly prohibited.
 *
 * Project: Messenger
 * Author: Ayshi Shannidhya Panda
 * Created on: 06-01-2026
 */

@Configuration
public class WebSecurityConfig {

    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

    private static final String[] PUBLIC_POST_ENDPOINTS = {
            "/v1/register",
            "/v1/verifyOtp",
            "/v1/login",
            "/api/v1/register",
            "/api/v1/verifyOtp",
            "/api/v1/login"
    };

    private static final String[] AUTHENTICATED_WEBSOCKET_ENDPOINTS = {
            "/ws",
            "/ws/**",
            "/api/ws",
            "/api/ws/**"
    };

    private static final String[] AUTHENTICATED_API_ENDPOINTS = {
            "/v1/**",
            "/actuator/**",
            "/api/**"
    };

    private static final String[] CSRF_IGNORED_ENDPOINTS = {
            "/v1/**",
            "/actuator/**",
            "/api/**"
    };

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                .csrf(csrf -> csrf.ignoringRequestMatchers(CSRF_IGNORED_ENDPOINTS))
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/error").permitAll()
                        .requestMatchers(
                                "/", "/index.html", "/main.dart.js", "/flutter.js",
                                "/flutter_bootstrap.js", "/flutter_service_worker.js",
                                "/favicon.png", "/manifest.json", "/version.json",
                                "/assets/**", "/icons/**", "/canvaskit/**"
                        ).permitAll()
                        .requestMatchers("/api/actuator/health", "/actuator/health").permitAll()
                        .requestMatchers(HttpMethod.POST, PUBLIC_POST_ENDPOINTS).permitAll()
                        .requestMatchers(AUTHENTICATED_WEBSOCKET_ENDPOINTS).authenticated()
                        .requestMatchers(AUTHENTICATED_API_ENDPOINTS).authenticated()
                        .anyRequest().permitAll()
                )
                .exceptionHandling(exception -> exception
                        .authenticationEntryPoint((request, response, authException) ->
                                writeApiError(
                                        request,
                                        response,
                                        HttpStatus.UNAUTHORIZED,
                                        "AUTH_REQUIRED",
                                        "Authentication is required for this endpoint"
                                ))
                        .accessDeniedHandler((request, response, accessDeniedException) ->
                                writeApiError(
                                        request,
                                        response,
                                        HttpStatus.FORBIDDEN,
                                        "ACCESS_DENIED",
                                        "You are not allowed to access this endpoint"
                                ))
                )
                .formLogin(AbstractHttpConfigurer::disable)
                .httpBasic(AbstractHttpConfigurer::disable)
                .sessionManagement(session -> session
                        .sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED)
                        .maximumSessions(1));
        return http.build();
    }

    @Bean
    public org.springframework.web.cors.CorsConfigurationSource corsConfigurationSource() {
        org.springframework.web.cors.CorsConfiguration config = new org.springframework.web.cors.CorsConfiguration();
        config.setAllowedOriginPatterns(java.util.List.of("*"));
        config.setAllowedMethods(java.util.List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        config.setAllowedHeaders(java.util.List.of("*"));
        config.setAllowCredentials(true);
        org.springframework.web.cors.UrlBasedCorsConfigurationSource source =
                new org.springframework.web.cors.UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }


    @Bean
    public PasswordEncoder passwordEncoder() {
        return PasswordEncoderFactories.createDelegatingPasswordEncoder();
    }

    private void writeApiError(HttpServletRequest request,
                               HttpServletResponse response,
                               HttpStatus status,
                               String errorCode,
                               String message) throws IOException {
        response.setStatus(status.value());
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);

        ApiResponse<Void> body = ApiResponse.error(
                status,
                status.getReasonPhrase(),
                errorCode,
                message,
                request.getRequestURI()
        );

        OBJECT_MAPPER.writeValue(response.getWriter(), body);
    }
}


