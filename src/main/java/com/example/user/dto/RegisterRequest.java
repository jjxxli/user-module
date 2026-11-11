package com.example.user.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/**
 * 注册请求体：前端 POST 的 JSON 会被 Spring 转成这个对象。
 * 类上的 @NotBlank / @Size / @Pattern 会在进入 Controller 方法之前自动校验，
 * 校验不通过由 GlobalExceptionHandler 统一返回 400 + 提示语。
 *
 * 请求示例：
 * {"username":"zhangsan","password":"123456","confirmPassword":"123456","nickname":"张三"}
 */
public class RegisterRequest {

    @NotBlank(message = "用户名不能为空")
    @Pattern(regexp = "^[a-zA-Z0-9_]{4,20}$", message = "用户名需为 4-20 位字母、数字或下划线")
    private String username;

    @NotBlank(message = "密码不能为空")
    @Size(min = 6, max = 20, message = "密码长度需为 6-20 位")
    private String password;

    @NotBlank(message = "请再输入一次密码")
    private String confirmPassword;

    @Size(max = 20, message = "昵称最多 20 个字")
    private String nickname;

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getConfirmPassword() { return confirmPassword; }
    public void setConfirmPassword(String confirmPassword) { this.confirmPassword = confirmPassword; }

    public String getNickname() { return nickname; }
    public void setNickname(String nickname) { this.nickname = nickname; }
}
