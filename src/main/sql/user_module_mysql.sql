CREATE DATABASE IF NOT EXISTS userdb DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;
USE userdb;

DROP TABLE IF EXISTS t_user;

CREATE TABLE t_user (
                        id          BIGINT       AUTO_INCREMENT PRIMARY KEY,
                        username    VARCHAR(50)  NOT NULL UNIQUE COMMENT '账号',
                        password    VARCHAR(100) NOT NULL COMMENT 'BCrypt 密文',
                        nickname    VARCHAR(50)  COMMENT '昵称',
                        create_time DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间'
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '用户表';

-- 预置演示账号 demo / 123456
INSERT INTO t_user (username, password, nickname)
VALUES ('demo', '$2a$10$K17ia1qq95JuDjAtkxvZN.FiQa9Nv8IR0szkfPkTaHtR.pmTQCv1.', '演示用户');

SELECT * FROM t_user;