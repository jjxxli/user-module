DROP TABLE IF EXISTS t_user;

CREATE TABLE t_user (
                        id          BIGINT       AUTO_INCREMENT PRIMARY KEY,
                        username    VARCHAR(50)  NOT NULL UNIQUE,          -- 账号，必须唯一
                        password    VARCHAR(100) NOT NULL,                 -- BCrypt 密文（60 位）
                        nickname    VARCHAR(50),
                        create_time DATETIME     DEFAULT CURRENT_TIMESTAMP
);