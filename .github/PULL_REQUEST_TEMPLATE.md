<!--
PR 标题请使用提交规范格式（Squash 合并后它就是 main 上的提交信息）：
  <type>(<scope>): <subject>
  例：feat(auth): 新增手机号验证码登录
-->

## 1. 变更内容

<!-- 一句话说明这个 PR 做了什么、为什么这么做 -->

-

## 2. 关联 Issue

<!-- 没有就写「无」。合并后自动关闭：Closes #12 -->

Closes #

## 3. 变更类型

- [ ] `feat` 新功能
- [ ] `fix` 缺陷修复
- [ ] `docs` 文档
- [ ] `refactor` 重构（不改变行为）
- [ ] `test` 测试
- [ ] `ci` / `build` 构建与流水线
- [ ] `chore` 杂项
- [ ] `perf` 性能优化
- [ ] `style` 格式调整
- [ ] 破坏性变更（BREAKING CHANGE，请在此说明影响与迁移方式）

## 4. 自测方式

<!-- 贴出可复现的验证方式：启动命令、接口地址、请求体、期望结果 / 截图 -->

1.
2.

## 5. 影响范围与兼容性

<!-- 影响哪些接口 / 表结构 / 配置项？是否需要其他人同步改动？ -->

-

## 6. 提交前检查清单

- [ ] 已在本地跑通 `./mvnw -B -ntp verify`（Windows 可用 `mvnw.cmd -B -ntp verify`）
- [ ] 已确认没有提交 `application-local.yml`、数据库密码、密钥、大文件
- [ ] 新代码符合分层：Controller → Service → Mapper，入参用 DTO 并加校验
- [ ] 异常统一走 `BizException` + `GlobalExceptionHandler`，没有吞异常
- [ ] 已补充 / 更新相关文档与 `api-test.http` 示例（如需要）
- [ ] 提交信息符合 Conventional Commits，分支名符合 `feature/xxx` 规范
