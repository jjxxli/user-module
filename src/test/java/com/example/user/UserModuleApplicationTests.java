package com.example.user;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

/**
 * 应用上下文冒烟测试。
 *
 * <p>使用 test profile（H2 内存库，见 application-test.yml），
 * 因此不依赖本地 MySQL，保证 CI（GitHub Actions）在无数据库环境中也能跑通。</p>
 */
@ActiveProfiles("test")
@SpringBootTest
class UserModuleApplicationTests {

    @Test
    void contextLoads() {
    }

}
