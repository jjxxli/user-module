package com.example.user.common;

/**
 * 业务异常：Service 里遇到"用户不存在""密码错误"就抛它，
 * 由 GlobalExceptionHandler 统一转成 JSON。
 */
public class BizException extends RuntimeException {

    private final Integer code;

    public BizException(String message) {
        this(400, message);
    }

    public BizException(Integer code, String message) {
        super(message);
        this.code = code;
    }

    public Integer getCode() {
        return code;
    }
}