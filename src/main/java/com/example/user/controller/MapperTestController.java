package com.example.user.controller;

import com.example.user.common.Result;
import com.example.user.entity.User;
import com.example.user.mapper.UserMapper;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/test")
public class MapperTestController {

    private final UserMapper userMapper;

    public MapperTestController(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    // GET /api/test/user?username=demo
    @GetMapping("/user")
    public Result<User> find(@RequestParam String username) {
        return Result.ok(userMapper.findByUsername(username));
    }

    // GET /api/test/users
    @GetMapping("/users")
    public Result<List<User>> all() {
        return Result.ok(userMapper.findAll());
    }
}