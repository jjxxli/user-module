# 贡献指南（CONTRIBUTING）

感谢参与「统考 408 刷题软件 · 用户模块」！本文件是**写代码和提 PR 时的操作手册**；角色分工、分支模型、评审 SLA、发布流程等完整规则见 **[docs/协作规范.md](docs/协作规范.md)**；第一次参与请先看 **[docs/新成员接入指南.md](docs/新成员接入指南.md)**。

一句话原则：**小步提交、小 PR、先评审后合并、main 永远可构建**。

---

## 1. 开发环境

| 依赖 | 版本 / 说明 | 自检命令 |
| --- | --- | --- |
| JDK | 17（推荐 Eclipse Temurin） | `java -version` |
| Maven | 使用仓库自带 Maven Wrapper，无需安装 | `./mvnw -v`（Windows：`.\mvnw.cmd -v`） |
| MySQL | 8.x（本地开发） | `mysql --version` |
| Git | 建议 2.40+，Windows 建议 Git for Windows（提供 `sh` / Git Bash） | `git --version` |
| IDE | IntelliJ IDEA（可选，推荐支持 HTTP Client） | — |

首次配置（每台机器一次）：

```powershell
# Windows PowerShell
.\scripts\install-hooks.ps1
# 若提示「禁止运行脚本」：powershell -ExecutionPolicy Bypass -File scripts/install-hooks.ps1
```

```bash
# Git Bash / macOS / Linux
bash scripts/install-hooks.sh
```

等价于 `git config core.hooksPath .githooks`。安装后用 `git config --get core.hooksPath` 验证输出 `.githooks`。

本地数据库配置：

1. 执行 `mysql -u root -p < src/main/sql/user_module_mysql.sql` 建库建表（含演示账号 `demo / 123456`）。
2. 复制 `src/main/resources/application-local.yml.example` 为同目录的 `application-local.yml`，填入**自己的** MySQL 账号密码。
3. `application-local.yml` 已被 `.gitignore` 忽略，且被 pre-commit 钩子拦截，**禁止提交**。
4. 不要改 `application.yml` 里的公共占位符来写死本机密码；CI 与测试使用 `test` profile（H2），完全不读本地 MySQL 配置。

---

## 2. 分支规范

> **当前为简单模式**：`main` 允许直接提交 / 直接 `push`（仅禁止 force push 与删除分支）。下面「只能通过 PR 合并」是切换到严格模式后的规则，建议现在就按分支 + PR 的习惯做。

`main` 是受保护分支：**只能通过 PR 合并，不能直接提交或直接 push**。

| 前缀 | 用途 | 示例 |
| --- | --- | --- |
| `feature/` | 新功能 | `feature/login-jwt`、`feature/question-page` |
| `fix/` | 修复缺陷 | `fix/register-dup`、`fix/exception-code` |
| `docs/` | 文档 | `docs/update-readme` |
| `refactor/` | 重构（不改外部行为） | `refactor/user-service` |
| `chore/` | 杂项（构建、依赖、配置） | `chore/upgrade-deps` |
| `hotfix/` | 紧急修复（从 `main` 切出，尽快合并） | `hotfix/login-500` |

命名规则：

- 前缀后使用**小写英文 kebab-case**（单词之间用 `-`），2～4 个单词，见名知意。
- 不要用中文、不要用大写、不要用下划线、不要用 `feature/张三的修改` 这类命名。
- 每个分支只做一件事；做完就合并、删除，不保留长期分支。

创建分支：

```bash
git switch main
git pull --ff-only origin main
git switch -c feature/login-jwt
```

---

## 3. 提交规范

### 3.1 格式

```text
<type>(<scope>): <subject>

<body（可选，说明为什么改）>

<footer（可选，关联 Issue）>
```

- **头部**：`type(scope): subject`，冒号为英文半角，冒号后**一个空格**。
- **subject**：中文，不超过 **50 字**，描述做了什么，**不加句号**。
- **scope**（建议）：`auth` | `user` | `common` | `config` | `docs` | `ci` | `deps`。
- **footer**：关联 Issue 写 `Closes #12`（PR 描述里写同样有效，合并后自动关闭 Issue）。
- 提交信息由 `commit-msg` 钩子校验，格式不符会被拒绝。

### 3.2 type 说明

| type | 含义 | 示例 |
| --- | --- | --- |
| `feat` | 新功能 | `feat(auth): 新增登录接口` |
| `fix` | 修复缺陷 | `fix(common): 统一业务异常返回码` |
| `docs` | 仅文档 | `docs: 补充新成员接入指南` |
| `style` | 代码格式（不影响逻辑） | `style: 统一缩进为 4 空格` |
| `refactor` | 重构（不改外部行为） | `refactor(user): 拆分注册校验逻辑` |
| `perf` | 性能优化 | `perf(user): 用户名查询增加索引` |
| `test` | 测试相关 | `test(auth): 补充登录失败用例` |
| `build` | 构建 / 依赖 | `build(deps): 升级 mybatis 到 3.0.3` |
| `ci` | CI 配置 | `ci: 缓存 Maven 依赖` |
| `chore` | 杂项 | `chore: 更新 .gitignore` |
| `revert` | 回滚某次提交 | `revert: 回滚登录接口改动` |

### 3.3 好 / 坏示例

```text
# ✅ 好
feat(auth): 实现登录接口并写入 Session
fix(user): 修复重复用户名并发注册时返回 500
docs: 更新 README 快速开始

# ❌ 坏（会被钩子或评审拒绝）
update
修改了一下
feat: update.
feature: 登录功能。
fix(auth): 修复登录接口在用户名不存在时的错误码，同时调整了全局异常、补充了参数校验、重构了 UserService 并升级了依赖
```

### 3.4 小步提交

- 一个提交只做一件可独立说明的事；能在 1 分钟内说清「改了什么、为什么」再提交。
- 不要把格式化、重构、功能、文档混在同一个提交里。
- 提交前先 `git status` + `git diff --cached` 检查，避免误提交 `.idea/`、`target/`、`application-local.yml`。

---

## 4. 编码规范

### 4.1 分层职责（必须遵守）

```text
Controller  →  收参数、触发校验、调用 Service、返回 Result<T>；不写业务判断
Service     →  业务规则、事务边界、抛 BizException；不直接拼 SQL、不碰 HttpServletRequest
Mapper      →  数据访问接口 + XML SQL；只做增删改查
Entity      →  数据库映射对象；不加请求校验注解
DTO         →  请求/响应对象；请求 DTO 上写 jakarta validation 注解
Common      →  Result、BizException、GlobalExceptionHandler 等跨模块能力
Config      →  Bean 配置（如 BCryptPasswordEncoder）
```

- Controller 方法保持短小：同类接口按资源放在同一个 Controller（如 `AuthController` 只处理 `/api/auth/**`）。
- 业务判断（查重、密码比对、状态流转）必须在 Service，便于单测与复用。
- 新增跨模块能力（统一返回、异常、分页封装等）放到 `common/`，不要复制粘贴。

### 4.2 统一返回与异常

- 所有接口返回 `Result<T>`：成功 `Result.ok(数据)` / `Result.ok("提示", 数据)`；失败用 `Result.fail(code, message)`。
- 业务错误一律 `throw new BizException(message)`（默认 400）或 `new BizException(code, message)`，由 `GlobalExceptionHandler` 统一转换，**不要自己 `try-catch` 后拼 JSON**。
- 参数校验失败由 `MethodArgumentNotValidException` 分支统一返回 400；数据库唯一键冲突兜底返回 400。
- 未知异常统一 500，**不要把堆栈或 SQL 暴露给前端**；日志里记录异常即可。
- 新增错误场景时，优先复用已有异常处理，不要新增返回结构。

### 4.3 参数校验

- 请求 DTO 上用 `jakarta.validation` 注解：`@NotBlank`、`@Size`、`@Pattern`、`@Email` 等，并写清中文 `message`。
- Controller 入参加 `@Valid`：`public Result<User> register(@Valid @RequestBody RegisterRequest request)`。
- 密码等敏感字段不要放进日志；校验信息不要回显用户输入内容的敏感部分。

### 4.4 持久层（MyBatis）

- SQL 写在 `src/main/resources/mappers/*.xml`，`mapper-locations: classpath:mappers/*.xml` 已配置。
- **必须使用 `#{}` 预编译参数**，禁止用 `${}` 拼接用户输入（SQL 注入）；表名、排序字段等确实需要动态拼接时，必须在 Java 侧用白名单校验。
- Mapper 接口多参数时使用 `@Param("name")`；返回列表用 `List<T>`；插入用 `useGeneratedKeys` 回填主键。
- 依赖 `map-underscore-to-camel-case: true` 做字段映射，不要手写一堆 `AS` 别名。
- 新增字段 / 新表时，同步更新三处：
  1. `src/main/resources/db/schema.sql` 与 `db/data.sql`（测试用 H2）；
  2. `src/main/sql/user_module_mysql.sql`（本机 MySQL 建库脚本）；
  3. 对应 Entity / Mapper XML / `docs/功能模块结构.md` 的数据表规划。
- 大批量操作注意性能与事务；Service 需要多步写操作时加 `@Transactional`。

### 4.5 密码与敏感数据

- 密码入库前必须 BCrypt 加密（`PasswordEncoder#encode`），校验用 `matches`，**不要自己实现哈希**。
- 返回给前端的用户对象必须把 `password` 置空（参考 `UserService`）。
- 任何密钥、Token、数据库密码不得写进 Java 代码、`application.yml`、测试代码或文档；AI Key 统一按 `docs/AI助教模块设计.md` 的 BYOK 方案处理。
- 日志中禁止打印密码、完整手机号 / 邮箱、Token、API Key；必要时脱敏。

### 4.6 配置管理

- `application.yml` 只放公共配置与占位符（`${MYSQL_URL:默认值}` 形式），会提交到仓库。
- 本机敏感配置只写 `application-local.yml`（已被忽略），模板是 `application-local.yml.example`。
- 测试配置在 `application-test.yml`，使用 H2 内存库，测试类加 `@ActiveProfiles("test")`，**不能依赖本地 MySQL**。
- CI 与本地使用同一条命令：`./mvnw -B -ntp verify`。

### 4.7 命名与代码风格

- 包结构：`com.example.user.<层>`；类名 PascalCase，方法/变量 camelCase，常量 UPPER_SNAKE_CASE。
- 4 空格缩进、UTF-8、LF 换行、文件末尾留空行；遵循仓库 `.editorconfig` 与 `.gitattributes`。
- 不提交无用注释与注释掉的代码；复杂业务写**为什么**，不写**是什么**。
- import 不使用通配符；删除无用 import。

### 4.8 测试

- 新增业务逻辑（尤其 Service）应补充测试：正常流程 + 至少一个异常流程。
- 测试类使用 `@SpringBootTest` / `@ActiveProfiles("test")`，数据库由 H2 + `db/schema.sql`、`db/data.sql` 初始化。
- 只改文档 / 注释可以不新增测试，但仍要保证 `verify` 通过。
- 提交 PR 前必须本地跑通：

```powershell
.\mvnw.cmd -B -ntp verify
```

```bash
./mvnw -B -ntp verify
```

### 4.9 接口与文档同步

- 新增或修改接口时，同步更新根目录 `api-test.http`，保证组员能直接复现。
- 接口路径、请求/响应结构、错误码有变化时，同步更新 README 的「接口速览」与相关设计文档。
- 修改协作流程、环境配置时，同步更新 README / CONTRIBUTING / docs 下对应文档。

---

## 5. PR 检查清单

发起 PR 前逐项确认：

- [ ] 分支从最新 `main` 切出，命名符合 `feature|fix|docs|refactor|chore|hotfix/` + kebab-case。
- [ ] 没有直接提交到 `main`，没有使用 `--no-verify` 绕过钩子。
- [ ] 提交信息符合 Conventional Commits（`type(scope): 中文 subject`，≤50 字），关联 Issue 写了 `Closes #N`。
- [ ] 改动范围聚焦，没有顺手改动无关文件；没有提交 `target/`、`.idea/`、大文件。
- [ ] **没有提交任何密码、密钥、Token、`application-local.yml`、`.env`、`*.pem`、`*.key`**。
- [ ] 本地 `./mvnw -B -ntp verify` 通过（与 CI 命令一致）。
- [ ] 新增 / 修改的接口已更新 `api-test.http`，必要时更新文档。
- [ ] PR 标题同样符合提交规范；已按 `.github/PULL_REQUEST_TEMPLATE.md` 完整填写：
  - **变更内容**：改了什么、为什么改；
  - **关联 Issue**：`Closes #12`；
  - **变更类型**：勾选对应的 type（feat / fix / docs…）；
  - **自测方式**：执行了哪些命令 / 调了哪些接口 / 预期结果；
  - **影响范围与兼容性**：影响的模块、接口、数据库、配置；
  - **提交前检查清单**：逐项勾选确认。
- [ ] 截图 / 接口返回示例（涉及接口或页面时尽量附上）。
- [ ] 自己先完整看一遍 diff，确认没有调试代码、`System.out.println` 和临时注释。

> PR 描述尽量让 Reviewer 不打开代码也能看懂「为什么改、怎么验证」。

---

## 6. Review 规则

- **响应时效**：收到 Review 请求后 **24 小时内**给出第一轮意见；忙不过来要在群里说明并转给其他成员。
- **评审依据**：优先看正确性、安全性、可维护性；风格问题交给 `.editorconfig` / 格式化工具，不揪细枝末节。
- **评论分级**（建议统一前缀）：
  - `[必须修改]`：阻塞合并，必须处理；
  - `[建议]`：可以讨论，不强制，由作者决定是否采纳；
  - `[提问]`：请求解释，澄清后即可。
- **Approve 门槛**：至少 **1 名非作者成员 Approve**；CI `build` 通过；所有评论已回复或标记解决。
- **作者职责**：对每条评论回复（采纳就改，不采纳说明理由）；修改后重新请求评审。
- **Reviewer 禁止**：未经阅读直接 Approve；代替作者 push 到 PR 分支；直接点合并（合并由 Owner 执行）。
- 发现**密钥泄露**时立即在 PR 里标红并通知 Owner，按安全事件处理（轮换密钥），不要只在评论里提一句就 Approve。

---

## 7. Issue 使用

- 开工前先搜 Issue，避免重复；没有对应 Issue 就先建一个（功能、修复、文档都可以建）。
- 新建 Issue 时使用仓库模板（空白 Issue 已禁用）：
  - **Bug 报告**（`bug_report.yml`）：环境、复现步骤、期望 / 实际结果；
  - **功能需求**（`feature_request.yml`）：背景、期望能力、优先级；
  - **开发任务**（`task.yml`）：任务目标、改动范围、完成标准（DoD）、负责人、分支名。
- 标题在模板前缀后补充简述，例如 `[task] 实现登录接口并写入 Session`、`[M1] 登录接口增加 Session 超时提示`。
- 领取任务：在 Issue 下留言并把自己设为 Assignee；完成后由关联 PR 的 `Closes #N` 自动关闭。
- 建议标签：`bug`、`enhancement`、`documentation`、`task`、`good first issue`（GitHub 默认标签即可，不强制）。

---

## 8. 发布流程

- 版本号遵循**语义化版本** `vMAJOR.MINOR.PATCH`，课程项目从 `v0.1.0` 开始（第一个里程碑 = 第一批交付 M7 + M1 + M2）。
- 只有 Owner（`jjxxli`）可以打 tag 和发布 Release；发布必须基于 `main` 上通过 CI 的最新提交。
- 发布步骤：

```bash
git switch main
git pull --ff-only origin main

# 1. 本地再验证一次（与 CI 相同）
./mvnw -B -ntp verify

# 2. 打附注 tag
git tag -a v0.1.0 -m "v0.1.0：第一批交付（M7 系统支撑 + M1 用户与登录）"

# 3. 推送 tag（push tag 不受 main 分支保护影响）
git push origin v0.1.0
```

- 在 GitHub 的 Releases 页面基于该 tag 发布 Release，自动生成变更列表，并写明本版本包含的模块与已知限制。

发布前检查清单：

- [ ] `main` 上 CI 全部绿灯；
- [ ] 没有未合并的 `hotfix/` 分支；
- [ ] README / 接口文档 / `api-test.http` 与实际一致；
- [ ] 数据库脚本可从零执行成功；
- [ ] 发布说明包含版本内容与已知问题。

---

## 9. 常见问题

### Q1：分支落后 `main`，rebase 冲突怎么办？

```bash
git fetch origin
git switch feature/login-jwt
git rebase origin/main
```

冲突处理：编辑冲突文件 → `git add <文件>` → `git rebase --continue`；想放弃这次 rebase 用 `git rebase --abort`。

> 本仓库 PR 使用 **Squash and merge**，所以合并前统一用 rebase 同步 `main`，**不要用 merge 把 main 合进功能分支**。

### Q2：rebase 之后 push 被拒怎么办？

功能分支 rebase 会改写历史，需要 force push，但**必须加 `--force-with-lease`**（先确认远端没有别人的新提交）：

```bash
git push --force-with-lease
```

**绝对禁止**对 `main` 或其他人的共享分支 force push。

### Q3：提交后发现改错了，怎么撤销？

```bash
# 最近一次提交还没 push：撤销提交，改动回到工作区
git reset --soft HEAD~1

# 已经 push 的提交：用 revert 生成一个反向提交（安全，不改写历史）
git revert <commit-hash>
git push
```

### Q4：不小心在 `main` 上本地提交了怎么办？

```bash
# 1. 把当前提交挪到新分支
git branch feature/my-change
# 2. main 回到远端状态
git switch main
git reset --hard origin/main
# 3. 切到新分支继续
git switch feature/my-change
```

如果已经 push 到 `main`：立即通知 Owner，由 Owner 评估回滚（`git revert`）——分支保护正常情况下不会允许这种 push。

### Q5：钩子没生效 / 提示找不到钩子？

```bash
git config --get core.hooksPath        # 应输出 .githooks
git config core.hooksPath .githooks    # 重新设置
```

Windows 下钩子是 `sh` 脚本，需要 Git for Windows（Git Bash）。如果钩子判断有误，**不要用 `git commit --no-verify` 绕过**，请找 Owner 修钩子。

### Q6：CI 的 `build` job 失败，但本地能跑？

- 在项目根目录执行与 CI 完全相同的命令：`./mvnw -B -ntp verify`（Windows：`.\mvnw.cmd -B -ntp verify`），确认不是缓存导致的假成功。
- 检查测试是否误用了本地 MySQL 配置；测试必须走 `test` profile + H2。
- 检查是否依赖了未提交的文件（例如本地新增的配置、脚本）。
- 检查 JDK 版本是否为 17（`java -version`）；CI 固定 Temurin 17。
- 修复后在 PR 里说明原因并 push，CI 会自动重跑；不要反复空提交触发重跑。

### Q7：提交被钩子拦了，提示大文件 / 敏感文件？

```bash
# 大文件：从暂存区移除并忽略（不要提交 target/、压缩包、视频）
git rm --cached <文件>
# 检查 .gitignore 是否已覆盖；敏感文件（密码/密钥）不要"改个名字"再提交，应放到本地配置或环境变量
```

### Q8：PR 需要改 `pom.xml`、`application.yml`、`api-test.http` 这类共享文件怎么办？

共享文件容易冲突：先在自己的 PR 里说明改动点，Owner 合并前协调其他正在修改同类文件的成员；能拆成单独 PR 的（如依赖升级 `build(deps)`）尽量拆开，减少互相等待。

### Q9：IDEA 里一堆灰色未跟踪文件（`target/`、`.idea/`）正常吗？

正常，已被 `.gitignore` 忽略。**不要**取消忽略或手动 `git add -f` 提交它们。

---

## 10. 参考

- [docs/协作规范.md](docs/协作规范.md) —— 角色分工、分支模型、PR 与评审 SLA、CI 门禁、发布与 tag
- [docs/新成员接入指南.md](docs/新成员接入指南.md) —— 上手步骤与 DSH 提示词
- [docs/功能模块结构.md](docs/功能模块结构.md) —— 模块划分与迭代顺序
- [Conventional Commits 1.0.0](https://www.conventionalcommits.org/zh-hans/v1.0.0/)
- [GitHub Flow 文档](https://docs.github.com/zh/get-started/using-github/github-flow)
