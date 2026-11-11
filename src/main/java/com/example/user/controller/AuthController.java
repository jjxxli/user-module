package com.example.user.controller;

import com.example.user.common.Result;
import com.example.user.dto.LoginRequest;
import com.example.user.dto.RegisterRequest;
import com.example.user.entity.User;
import com.example.user.service.UserService;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 认证相关接口：
 *   POST /api/auth/register   注册
 *   POST /api/auth/login      登录（成功时把用户写进 Session）
 */
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    /** Session 中保存登录用户的 key（第 9 步拦截器会用同一个字符串） */
    public static final String SESSION_USER = "loginUser";

    private final UserService userService;

    public AuthController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping("/register")
    public Result<User> register(@Valid @RequestBody RegisterRequest request) {
        User user = userService.register(request);
        return Result.ok("注册成功，请登录", user);
    }

    @PostMapping("/login")
    public Result<User> login(@Valid @RequestBody LoginRequest request, HttpSession session) {
        User user = userService.login(request);

        // 登录成功：把用户存进 Session。
        // Tomcat 会下发 Set-Cookie: JSESSIONID=xxx，浏览器后续请求自动带上，
        // 服务端凭它找回这个 Session，就"记住"了当前用户。
        session.setAttribute(SESSION_USER, user);

        return Result.ok("登录成功", user);
    }
}
