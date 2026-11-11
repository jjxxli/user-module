package com.example.user.service;

import com.example.user.common.BizException;
import com.example.user.dto.LoginRequest;
import com.example.user.dto.RegisterRequest;
import com.example.user.entity.User;
import com.example.user.mapper.UserMapper;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

/**
 * 用户业务层：注册的规则都在这里。
 * Controller 只负责"收参数、返回结果"，不写业务判断。
 */
@Service
public class UserService {

    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserMapper userMapper, PasswordEncoder passwordEncoder) {
        this.userMapper = userMapper;
        this.passwordEncoder = passwordEncoder;
    }

    /**
     * 注册四步：
     *  1. 两次密码是否一致；
     *  2. 用户名是否已被占用（查库）；
     *  3. 密码加密后插入数据库；
     *  4. 返回用户信息（密码置空，绝不能把密文回传给前端）。
     */
    public User register(RegisterRequest request) {
        // 1. 两次密码一致
        if (!request.getPassword().equals(request.getConfirmPassword())) {
            throw new BizException("两次输入的密码不一致");
        }

        // 2. 查重（findByUsername 查不到返回 null）
        String username = request.getUsername().trim();
        if (userMapper.findByUsername(username) != null) {
            throw new BizException("用户名已被占用，请换一个");
        }

        // 3. 加密 + 入库
        User user = new User();
        user.setUsername(username);
        user.setPassword(passwordEncoder.encode(request.getPassword()));   // 明文 -> BCrypt 密文
        String nickname = request.getNickname();
        user.setNickname(nickname == null || nickname.isBlank() ? username : nickname.trim());

        userMapper.insert(user);      // insert 成功后 user.id 被回填
        user.setPassword(null);       // 4. 不返回密文
        return user;
    }

    /**
     * 登录：先按用户名"查库"，再按查到的结果给出不同反馈。
     *   查不到          → 404 该用户不存在，请先注册
     *   查到但密码不对   → 400 密码错误，请重试
     *   都对            → 返回用户信息（密码置空）
     *
     * 注意：真实产品通常两种情况都提示"用户名或密码错误"，避免被用来
     * 探测"哪些账号存在"（用户枚举）。课程演示要求区分反馈，所以这里分开；
     * 想合并只需把下面两条 message 改成同一句。
     */
    public User login(LoginRequest request) {
        // ① 查询用户
        User user = userMapper.findByUsername(request.getUsername().trim());

        // ② 查不到：无该用户
        if (user == null) {
            throw new BizException(404, "该用户不存在，请先注册");
        }

        // ③ 查到了：BCrypt 比对密码
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new BizException(400, "密码错误，请重试");
        }

        // ④ 都对
        user.setPassword(null);
        return user;
    }
}
