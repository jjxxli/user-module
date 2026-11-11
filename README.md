# 统考 408 刷题软件 · 用户模块（user-module）

[![CI](https://github.com/jjxxli/user-module/actions/workflows/ci.yml/badge.svg)](https://github.com/jjxxli/user-module/actions/workflows/ci.yml)

> 面向计算机统考 408 的在线刷题软件，本仓库负责其中的 **用户模块**：统一返回、全局异常、参数校验、BCrypt 密码加密、Session 登录与 MyBatis 持久化，是后续题库（M2）、做题（M3）、错题本（M4）等模块的技术底座。
>
> Spring Boot 课程小组作业 · 当前处于第一批交付（M7 系统支撑 + M1 用户与登录）。

---

## 技术栈

| 分类 | 选型 |
| --- | --- |
| 语言 / 构建 | Java 17、Maven Wrapper（`mvnw`，无需本机安装 Maven） |
| 框架 | Spring Boot 3.3.5、Spring Web、Spring Validation |
| 持久层 | MyBatis 3.0.3、MySQL 8（本地开发）、H2 内存库（测试 / CI） |
| 安全 | BCrypt（`spring-security-crypto`）、HttpSession 登录态 |
| 测试 | JUnit 5、Spring Boot Test（`@ActiveProfiles("test")` + H2） |
| 协作 / CI | Git hooks（`.githooks/`）、GitHub Actions（job `build`）、Dependabot |

---

## 功能概览

### 已完成（第一批）

- **M7 系统支撑**：统一返回 `Result<T>`、业务异常 `BizException`、全局异常处理 `GlobalExceptionHandler`、参数校验（jakarta validation）、MyBatis SQL 日志。
- **M1 用户与登录**：注册（两次密码一致性、用户名查重、BCrypt 加密）、登录（区分「用户不存在 404 / 密码错误 400」）、Session 保存登录态。

### 规划中

- **M2 题库查询**（P0，第二批）：科目列表、题目分页与多条件筛选、题目详情。
- **M3 做题与判卷**、**M4 错题本**、**M5 学习统计**、**M6 管理后台**。
- **M8 AI 助教**（加分项，BYOK 服务端代理）：深度解析、多轮追问、变式题生成、学情诊断。

> 模块划分、依赖关系、数据表规划与当前进度见 **[docs/功能模块结构.md](docs/功能模块结构.md)**。
> AI 助教的技术方案与 BYOK 安全约束见 **[docs/AI助教模块设计.md](docs/AI助教模块设计.md)**。
> 结构图、技术架构图等见 `docs/diagrams/`。

### 接口速览

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| POST | `/api/auth/register` | 注册：`username` / `password` / `confirmPassword` / `nickname` |
| POST | `/api/auth/login` | 登录：成功后写入 Session，返回 `Set-Cookie: JSESSIONID` |
| GET | `/api/test/users` | 演示：查询用户列表（Mapper 联调用） |

统一返回结构：`{"code": 200, "message": "操作成功", "data": {...}}`。

---

## 目录结构

```text
user-module/
├── .editorconfig                   # 统一编码 / 换行 / 缩进
├── .githooks/                      # 本地 Git 钩子：pre-commit / commit-msg / pre-push
├── .gitattributes                  # 换行归一化、二进制文件识别
├── .github/
│   ├── workflows/ci.yml            # GitHub Actions CI（job 名 build，分支保护必需检查）
│   ├── PULL_REQUEST_TEMPLATE.md    # PR 模板：变更内容 / 关联 Issue / 变更类型 / 自测方式 / 影响范围 / 检查清单
│   ├── ISSUE_TEMPLATE/             # Issue 模板：Bug 报告 / 功能需求 / 开发任务
│   ├── CODEOWNERS                  # 审查人自动指派（当前 Owner 兜底）
│   └── dependabot.yml              # Maven 与 GitHub Actions 依赖周更
├── .mvn/wrapper/                   # Maven Wrapper 配置
├── docs/
│   ├── 功能模块结构.md              # 模块划分、依赖、数据表规划、进度
│   ├── AI助教模块设计.md            # M8 AI 助教（BYOK）设计
│   ├── 协作规范.md                  # 完整协作规范（分支 / 提交 / PR / 评审 / 发布）
│   ├── 新成员接入指南.md            # 新同学上手手册 + 可复制的 DSH 提示词
│   └── diagrams/                    # 功能结构图、技术架构图（png / svg / puml / drawio）
├── scripts/
│   ├── install-hooks.ps1           # Windows 一键安装 Git 钩子
│   ├── install-hooks.sh            # Git Bash / macOS / Linux 一键安装
│   └── add-collaborators.ps1       # Owner 批量邀请组员为协作者（push 权限）
├── src/main/java/com/example/user/
│   ├── common/                     # Result、BizException、GlobalExceptionHandler
│   ├── config/                     # PasswordConfig（BCrypt Bean）
│   ├── controller/                 # AuthController、HelloController、MapperTestController
│   ├── dto/                        # LoginRequest、RegisterRequest（校验注解）
│   ├── entity/                     # User（与 t_user 表对应）
│   ├── mapper/                     # UserMapper 接口
│   ├── service/                    # UserService（业务规则）
│   └── demos/                      # Spring 入门示例代码，可忽略
├── src/main/resources/
│   ├── application.yml             # 公共配置：只放占位符与环境变量，禁止写真实密码
│   ├── application-local.yml.example  # 本机配置模板（复制为 application-local.yml）
│   ├── application-test.yml        # 测试配置：H2 内存库 + 自动建表/灌数据
│   ├── mappers/UserMapper.xml      # MyBatis SQL（#{} 预编译参数）
│   ├── db/                         # 测试用 H2 建表（schema.sql）与数据（data.sql）
│   └── static/index.html
├── src/main/sql/user_module_mysql.sql  # MySQL 建库建表脚本（含 demo 账号）
├── src/test/java/com/example/user/ # 冒烟测试，@ActiveProfiles("test")，不依赖 MySQL
├── api-test.http                   # 注册 / 登录接口用例（IDEA HTTP Client 可直接跑）
├── mvnw / mvnw.cmd                 # Maven Wrapper 启动脚本
├── pom.xml
├── CONTRIBUTING.md                 # 编码规范、PR 清单、Review 规则、常见问题
└── README.md
```

---

## 快速开始

### 1. 环境要求

- **JDK 17**（推荐 Eclipse Temurin），`java -version` 显示 17.x。
- **MySQL 8**（本地开发用；只跑测试可以不装，测试走 H2）。
- **Git**（建议 2.40+）；Windows 建议安装 [Git for Windows](https://git-scm.com/download/win)（钩子是 `sh` 脚本，需要它自带的 Git Bash）。
- **IntelliJ IDEA**（推荐 2023.3+，支持 HTTP Client 与 Maven 导入），可选。

Maven 已随项目提供 Wrapper（`mvnw` / `mvnw.cmd`），**不需要单独安装 Maven**。

### 2. 克隆仓库（Git 钩子是可选项）

```bash
git clone https://github.com/jjxxli/user-module.git
cd user-module
```

用 IDEA 导入：`File → Open`，选择仓库根目录即可；IDEA 会自动识别为 Maven 项目并依据 `pom.xml` 下载依赖（也已配置 Maven Wrapper，不需要手动指定 Maven 安装路径）。

**当前仓库是「简单模式」，可以不装钩子**（直接改代码、提交、push 到 `main` 即可）。想启用严格模式（必须走分支 + PR）时再装，每台机器只需一次：

```powershell
# Windows PowerShell
.\scripts\install-hooks.ps1
# 若提示「禁止运行脚本」，改用：
# powershell -ExecutionPolicy Bypass -File scripts/install-hooks.ps1
# 或手动设置
git config core.hooksPath .githooks
```

```bash
# Git Bash / macOS / Linux
bash scripts/install-hooks.sh
# 或手动设置
git config core.hooksPath .githooks
```

验证：`git config --get core.hooksPath` 输出 `.githooks`。

装了钩子之后，本地会拦住：在 `main` 上直接提交、大于 5 MB 的文件、敏感文件（`*.env`、`*.key`、`*.pem`、`application-local.yml` 等）、不符合规范的提交信息，以及直接 `push` 到 `main`。不装也完全不影响提交和推送。

### 3. 配置本地数据库（每台机器自己做一次）

```bash
# ① 建库、建表、灌入演示账号 demo / 123456（Git Bash）
mysql -u root -p < src/main/sql/user_module_mysql.sql
```

> PowerShell 不支持 `<` 输入重定向：先执行 `mysql -u root -p` 登录，再执行 `source E:/IDEA-project/user-module/src/main/sql/user_module_mysql.sql`（把路径换成你的仓库位置），或执行 `Get-Content src/main/sql/user_module_mysql.sql | mysql -u root -p`。

```powershell
# ② 复制本机配置模板（PowerShell）
Copy-Item src/main/resources/application-local.yml.example src/main/resources/application-local.yml
```

```bash
# ② 复制本机配置模板（Git Bash / macOS / Linux）
cp src/main/resources/application-local.yml.example src/main/resources/application-local.yml
```

然后编辑 `src/main/resources/application-local.yml`，把 `username` / `password` 改成**你自己电脑上**的 MySQL 账号密码。

- `application.yml` 只放占位符与环境变量（`MYSQL_URL` / `MYSQL_USERNAME` / `MYSQL_PASSWORD`），会提交到仓库。
- `application-local.yml` 已被 `.gitignore` 忽略，**永远不要提交**；钩子也会拦截它。
- 不想改文件也可以直接用环境变量注入数据库连接，见 `application.yml` 注释。

### 4. 启动应用

```powershell
# Windows PowerShell
.\mvnw.cmd spring-boot:run
```

```bash
# Git Bash / macOS / Linux
./mvnw spring-boot:run
```

- 端口：**8080**（`server.port=8080`）。
- 默认激活 `local` profile（有 `application-local.yml` 就读取真实数据库配置；CI / 测试使用 `test` profile 走 H2）。
- 演示账号：`demo` / `123456`（由 `src/main/sql/user_module_mysql.sql` 预置）。

### 5. 验证接口

用 IDEA 打开根目录的 `api-test.http`（HTTP Client），逐个点击运行；或直接用 curl：

```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test01","password":"123456","confirmPassword":"123456","nickname":"测试一"}'

curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"demo","password":"123456"}'
```

> Windows PowerShell 里 `curl` 是 `Invoke-WebRequest` 的别名，请用 `curl.exe`，或直接用 `api-test.http` / Postman。

### 6. 跑测试与构建（不依赖 MySQL）

```powershell
.\mvnw.cmd -B -ntp verify
```

```bash
./mvnw -B -ntp verify
```

测试类使用 `@ActiveProfiles("test")` + H2 内存库，命令与 CI 完全一致；**提交 PR 前必须本地跑通**。

> Linux / macOS 上如果提示 `mvnw: Permission denied`，执行 `chmod +x mvnw`（CI 里也做了同样处理）。

---

## 文档导航

| 文档 | 什么时候看 |
| --- | --- |
| **[docs/新成员接入指南.md](docs/新成员接入指南.md)** | **第一次参与项目必读**：上手步骤 + 可整段复制给 DSH/AI 助手的提示词（接入仓库 / 领任务开 PR / 做 Reviewer / CI 排错） |
| **[docs/协作规范.md](docs/协作规范.md)** | 完整规范：角色分工、分支模型、提交规范、PR/评审 SLA、CI 门禁、发布流程 |
| **[CONTRIBUTING.md](CONTRIBUTING.md)** | 编码规范、PR 检查清单、Review 规则、Issue 用法、常见问题（rebase / force-with-lease / 撤销提交） |
| **[docs/功能模块结构.md](docs/功能模块结构.md)** | 了解 7 大模块划分、依赖顺序、数据表规划与当前进度 |
| **[docs/AI助教模块设计.md](docs/AI助教模块设计.md)** | M8 AI 助教（BYOK）的功能、接口与安全设计 |

---

## 协作速查

> ⚠️ **当前协作模式：简单模式** —— 大家各自 `git pull --rebase` → 改代码 → `git commit` → `git push` 到 `main` 即可。
> `main` 允许直接推送（仍然禁止 `git push --force` 和删除 `main`）；CI 会自动跑但不拦截合并。
> 想切到**严格模式**（必须 PR + 1 人评审 + CI 通过才能合并）：装钩子 `git config core.hooksPath .githooks`，再到 GitHub `Settings → Branches` 恢复「Require a pull request before merging」和「Require status checks: build」。

### 日常三步

```bash
git pull --rebase                # ① 先同步别人的改动
# ② 改代码 / 加文件（Git 只跟踪文件，空文件夹不会被提交！）
git add -A && git commit -m "feat(user): 新增 xxx 接口"
git push                         # ③ 推到 main
```

- 两个人同时改**同一个文件**时，push 可能被拒（non-fast-forward）：再 `git pull --rebase` 解决冲突后 `git push`。
- 建议每次改动前先 pull，减少冲突。
- 新增文件夹里**至少放一个文件**（例如 `README.md`、`.gitkeep`），否则 Git 不会记录这个文件夹。

### 分支（可选，推荐逐步养成）

- 需要多人并行开发同一个模块时，从最新 `main` 切短期分支：`feature/`、`fix/`、`docs/`、`refactor/`、`chore/`、`hotfix/`。
- 命名用小写英文 kebab-case，例如 `feature/login-jwt`、`docs/update-readme`、`fix/register-dup`。
- 切分支后 push 自己的分支，再在 GitHub 开 PR，见下文「开 PR 三步」。

### 提交

```text
<type>(<scope>): <中文 subject，不超过 50 字，不加句号>
```

- `type` ∈ `feat` | `fix` | `docs` | `style` | `refactor` | `perf` | `test` | `build` | `ci` | `chore` | `revert`
- `scope` 建议：`auth` | `user` | `common` | `config` | `docs` | `ci` | `deps`
- 关联 Issue 在 footer 写 `Closes #12`。

示例：

```text
feat(auth): 实现登录接口并写入 Session
fix(common): 修复全局异常返回码不一致
docs: 补充新成员接入指南
```

### 开 PR 三步（可选，严格模式必用）

1. 从最新 `main` 切分支开发，小步提交，本地 `./mvnw -B -ntp verify` 通过后 push 自己的分支。
2. 在 GitHub 发起 PR，**按 `.github/PULL_REQUEST_TEMPLATE.md` 完整填写**（变更内容 / 关联 Issue / 变更类型 / 自测方式 / 影响范围 / 提交前检查清单）。
3. 等 **CI 的 `build` job 变绿** + **至少 1 人 Approve** + 解决全部评论后，由 Owner 用 **Squash and merge** 合并，分支自动删除。

```bash
git switch main
git pull --ff-only origin main
git switch -c feature/login-jwt

# ……开发，本地测试通过……

git add <改动的文件>
git commit -m "feat(auth): 实现登录接口并写入 Session" -m "Closes #12"
git push -u origin feature/login-jwt
```

---

## 安全红线（全员遵守）

- ❌ **禁止提交任何密码、密钥、Token、私钥**：真实数据库密码只写在本地 `application-local.yml`（已在 `.gitignore`），AI Key 等密钥只放环境变量。
- ❌ 禁止把用户密码明文或 BCrypt 密文返回给前端，禁止把敏感信息打进日志。
- ❌ 禁止直接 push `main`、禁止 `git push --force` 到共享分支、禁止用 `--no-verify` 绕过钩子。
- ❌ 禁止把大文件（> 5 MB，如压缩包、视频、`target/` 产物）提交进仓库。
- ✅ 发现密钥泄露：**立即通知 Owner 并轮换该密钥**，不要只删掉最新提交就当作已解决。

---

## 参与成员

- **Owner（仓库管理员）**：`jjxxli`，负责仓库设置、分支保护、PR 合并与版本发布。
- **成员**：按模块（M1 / M2 / M3 / M4 / M5 / M6 / M7 / M8）在 Issue 中认领任务，彼此互为 Reviewer。

第一次参与请直接阅读 **[docs/新成员接入指南.md](docs/新成员接入指南.md)**，按步骤完成环境配置，并把指南里的提示词粘贴到自己的 DSH/AI 助手中使用。
