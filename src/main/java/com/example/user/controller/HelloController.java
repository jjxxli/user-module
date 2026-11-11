package com.example.user.controller;

import com.example.user.common.BizException;
import com.example.user.common.Result;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
public class HelloController {

    @GetMapping("/api/hello")
    public Result<Map<String, Object>> hello() {
        return Result.ok(Map.of("message", "接口通了！"));
    }

    /** 临时测试用：验证全局异常处理是否生效，测完可以删掉 */
    @GetMapping("/api/error")
    public Result<Void> error() {
        throw new BizException(400, "这是一条测试业务异常");
    }
}