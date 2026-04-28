# Yach CLI

Yach CLI 是一个面向知音楼 / Yach OpenAPI 的命令行工具，用于在终端或 AI Agent 工作流中操作知音楼消息、用户、群和在线文档。

它适合这些场景：

- 在命令行里读取、创建、追加知音楼在线文档。
- 创建文档后自动补充管理员或协作者权限。
- 查询用户、群成员和数字伙伴所在群。
- 通过数字伙伴发送个人消息、群消息和 Markdown 消息。
- 给 AI Agent 提供稳定、可脚本化的知音楼操作入口。

Yach CLI 不内置任何 app key、app secret 或 access token。所有凭据都由使用者通过初始化引导或环境变量自行配置。

## 安装

一条命令安装：

```bash
curl -fsSL https://raw.githubusercontent.com/zpygo1/yachcli/main/install.sh | bash
```

安装脚本会把 `yach` 安装到：

```text
~/.local/bin/yach
```

如果当前 shell 还没有加载 `~/.local/bin`，先执行：

```bash
export PATH="$HOME/.local/bin:$PATH"
```

确认安装结果：

```bash
yach --version
yach --help
```

从本地仓库安装：

```bash
bash install.sh
```

## 凭据申请

使用 Yach CLI 前，需要先在知音楼侧准备一个数字伙伴应用，并获取 app key 和 app secret。

申请方式：

1. 在知音楼中创建数字伙伴。
2. 进入该数字伙伴的开发者选项。
3. 复制 app key 和 app secret。
4. 打开该数字伙伴所需的 OpenAPI 权限。
5. 如果要使用文档创建、文档读取、文档追加、管理员/协作者能力，需要确认文档相关 API 权限已开启。
6. 如果要发送消息、查询用户或操作群，需要确认消息、用户、群相关 API 权限已开启。

凭据只保存在本机，不要提交到 Git，也不要发给他人。

## 初始化

推荐使用交互式初始化：

```bash
yach init
```

初始化过程会依次引导填写：

- Yach app key
- Yach app secret
- 默认文档管理员工号，可留空
- OpenAPI Base URL，默认是 `https://yach-oapi.zhiyinlou.com`

初始化后配置会写入：

```text
~/.config/yach/config.json
```

配置文件权限会设置为 `0600`，只允许当前用户读取。

初始化完成后运行健康检查：

```bash
yach doctor
```

只检查本地依赖和配置，不访问网络：

```bash
yach doctor --offline
```

查看 token 缓存状态：

```bash
yach auth status
```

## 环境变量配置

也可以跳过 `yach init`，直接通过环境变量配置：

```bash
export YACH_APP_KEY="your_app_key"
export YACH_APP_SECRET="your_app_secret"
export YACH_DEFAULT_ADMIN_WORK_CODE="your_work_code"
export YACH_BASE_URL="https://yach-oapi.zhiyinlou.com"
```

配置优先级：

```text
环境变量 > ~/.config/yach/config.json > 默认值
```

## 能力清单

### 基础与认证

| 命令 | 能力 |
|---|---|
| `yach init` | 交互式配置 app key、app secret、默认管理员工号和 OpenAPI 地址 |
| `yach doctor` | 检查依赖、配置和 token 获取 |
| `yach doctor --offline` | 只检查本地依赖和配置 |
| `yach auth status` | 查看本地 token 缓存状态 |
| `yach token` | 获取 access token，主要用于调试 |
| `yach config show` | 查看当前本地配置，app secret 会脱敏 |
| `yach config set default-admin <工号>` | 设置创建文档后默认添加的管理员工号 |

### 用户

| 命令 | 能力 |
|---|---|
| `yach user <工号>` | 按工号查询用户信息 |
| `yach user-id <userid>` | 按 userid 查询用户信息 |

### 消息

| 命令 | 能力 |
|---|---|
| `yach msg <工号> <内容>` | 向指定工号发送文本私信 |
| `yach msg-md <工号> <标题> <Markdown内容>` | 向指定工号发送 Markdown 私信 |
| `yach group-msg <group_id> <内容>` | 以数字伙伴身份向指定群发送文本消息 |

### 群

| 命令 | 能力 |
|---|---|
| `yach group-list` | 查询数字伙伴所在群，返回可用于群消息的 `group_id` |
| `yach group-users <group_id> [页码] [数量]` | 查询指定群成员 |

### 在线文档

| 命令 | 能力 |
|---|---|
| `yach doc-create <名称> [类型]` | 创建在线文档 |
| `yach doc-read <URL或guid>` | 读取在线文档内容，优先读取 Markdown，失败时尝试导出 docx 后提取文本 |
| `yach doc-text <URL或guid>` | 读取在线文档纯文本内容 |
| `yach doc-append <URL或guid> <Markdown内容>` | 向在线文档追加 Markdown 内容 |
| `yach doc-admin-add <URL或guid> <工号>` | 给文档添加管理员 |
| `yach doc-collaborator-add <URL或guid> <工号> [editor\|reader\|commentator]` | 给文档添加协作者 |

文档类型支持：

```text
newdoc
spreadsheet
presentation
mindmap
```

## 文档创建与权限补齐

知音楼文档创建后，常见情况是：文档虽然创建成功，但还需要把某个用户添加为管理员或协作者，否则该用户无法正常访问或编辑文档。

Yach CLI 把这个流程封装进了文档创建命令。

设置默认管理员工号：

```bash
yach config set default-admin <你的工号>
```

之后创建文档：

```bash
yach doc-create "项目说明" newdoc
```

CLI 会在创建成功后自动尝试把默认管理员添加为文档管理员。

也可以每次创建时显式指定管理员：

```bash
yach doc-create "项目说明" newdoc --admin <你的工号>
```

创建文档时同步添加协作者：

```bash
yach doc-create "项目说明" newdoc --collaborator <协作者工号>:editor
```

协作者角色支持：

```text
editor
reader
commentator
```

如果不希望创建后自动添加管理员：

```bash
yach doc-create "临时文档" newdoc --no-admin
```

如果文档已创建，需要后续补权限：

```bash
yach doc-admin-add "<文档URL或guid>" <管理员工号>
yach doc-collaborator-add "<文档URL或guid>" <协作者工号> editor
```

如果创建文档成功但添加管理员失败，CLI 会输出可直接执行的补救命令。

## 示例

创建文档并把自己设为管理员：

```bash
yach doc-create "周会纪要" newdoc --admin <你的工号>
```

读取文档：

```bash
yach doc-read "https://yach-doc-shimo.zhiyinlou.com/docs/xxxx"
```

追加内容：

```bash
yach doc-append "https://yach-doc-shimo.zhiyinlou.com/docs/xxxx" "## 今日进展\n\n- 已完成 CLI 初始化"
```

查询用户：

```bash
yach user <工号>
```

发送 Markdown 私信：

```bash
yach msg-md <工号> "通知" "### 文档已创建\n\n请查看最新内容。"
```

查询数字伙伴所在群：

```bash
yach group-list
```

向群发送消息：

```bash
yach group-msg <group_id> "这是一条来自 Yach CLI 的消息"
```

## 本地验证

改动后可以运行最小检查：

```bash
bash tests/smoke.sh
```

该检查只验证脚本语法、基础命令、离线 doctor 和本地安装流程，不会访问知音楼 OpenAPI。

## 安全说明

- 不要把 app key、app secret、access token 提交到 Git。
- 不要把 `~/.config/yach/config.json` 分享给他人。
- `yach config show` 会隐藏 app secret。
- `yach token` 会输出 access token，只建议调试时使用。
- 群消息、文档追加、权限修改都会真实写入线上数据，执行前请确认目标。

## 当前边界

- 表格读取和复杂文档导出属于 best-effort，不承诺所有知音楼文档类型都能稳定解析。
- 删除文档、消息历史等高风险或未验证接口暂不开放。
- 当前协作者添加优先支持按用户工号添加，不覆盖部门协作者等更复杂授权模型。
