package com.example.user.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

/**
 * 密码加密器。
 * BCrypt 三个特点：
 *  1) 自带随机盐，同一个密码每次加密结果都不同；
 *  2) 是"慢哈希"，暴力破解成本远高于 MD5/SHA；
 *  3) 校验用 matches(明文, 密文)，不要自己写 equals。
 */
@Configuration
public class PasswordConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
