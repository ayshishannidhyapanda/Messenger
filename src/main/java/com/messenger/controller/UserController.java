package com.messenger.controller;

import com.messenger.dto.OtpVerifyDto;
import com.messenger.dto.UserCreateDTO;
import com.messenger.models.Users;
import com.messenger.service.OtpService;
import com.messenger.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

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

@RestController
@RequestMapping("/v1")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;
    private final OtpService otpService;

    @PostMapping("/register")
    ResponseEntity<Users> createUser(@Valid @RequestBody UserCreateDTO userCreateDTO) {
        Users created = userService.createUser(userCreateDTO);

        if (userCreateDTO.getMobNumber() != null && !userCreateDTO.getMobNumber().isBlank()) {

            otpService.sendSmsOtp(userCreateDTO.getMobNumber());

        }
        if (userCreateDTO.getEmail() != null && !userCreateDTO.getEmail().isBlank()) {

            otpService.sendMailOtp(userCreateDTO.getEmail());

        }
        return new ResponseEntity<>(created, HttpStatus.CREATED);
    }

    @PostMapping("/verifyOtp")
    String otpVerify(@RequestBody OtpVerifyDto otpVerifyDto) {
        return otpService.verifyOtp(otpVerifyDto);
    }

    @PostMapping("/sendOtp")
    ResponseEntity<String> sendOtp(@RequestBody java.util.Map<String, String> body) {
        String mobNumber = body.get("mobNumber");
        if (mobNumber == null || mobNumber.isBlank()) {
            return ResponseEntity.badRequest().body("Mobile number is required");
        }
        otpService.sendSmsOtp(mobNumber);
        return ResponseEntity.ok("OTP sent to " + mobNumber);
    }


}
