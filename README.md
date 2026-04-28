# yach-cli

知音楼 / Yach OpenAPI 的轻量命令行封装，重点解决 AI Agent 和命令行场景下的文档读写、创建后权限补齐、消息和基础群操作。

当前版本是可分享的最小版：不包含任何内置密钥，不假设使用者是 Tal，也不会把 app secret 写进脚本。

## 安装

本地仓库安装：

```bash
./install.sh
```

发布到 GitHub 后，可以改成一条命令安装：

```bash
curl -fsSL https://raw.githubusercontent.com/<org>/yach-cli/main/install.sh | bash
```

当前仓库的一键安装命令：

```bash
curl -fsSL https://raw.githubusercontent.com/zpygo1/yachcli/main/install.sh | bash
```

安装后确认：

```bash
yach --version
yach --help
```

## 初始化

```bash
yach init
yach doctor
```

`yach init` 会写入：

```text
~/.config/yach/config.json
```

文件权限会设置为 `0600`。也可以不写配置，直接用环境变量：

```bash
export YACH_APP_KEY="your_app_key"
export YACH_APP_SECRET="your_app_secret"
export YACH_DEFAULT_ADMIN_WORK_CODE="143277"
```

配置优先级：

```text
环境变量 > ~/.config/yach/config.json > 默认值
```

## 常用命令

```bash
yach token
yach user <工号>
yach user-id <userid>
yach msg <工号> "内容"
yach msg-md <工号> "标题" "Markdown 内容"
yach group-list
yach group-msg <group_id> "内容"
yach group-users <group_id> 1 100
```

文档：

```bash
yach doc-create "文档名" newdoc
yach doc-create "文档名" newdoc --admin 143277
yach doc-create "文档名" newdoc --collaborator 123456:editor
yach doc-read "<URL或guid>"
yach doc-text "<URL或guid>"
yach doc-append "<URL或guid>" "追加的 Markdown"
yach doc-admin-add "<URL或guid>" 143277
yach doc-collaborator-add "<URL或guid>" 123456 editor
```

## 创建文档后的权限补齐

推荐先设置默认管理员：

```bash
yach config set default-admin 143277
```

之后：

```bash
yach doc-create "项目说明" newdoc
```

会在创建成功后自动调用管理员接口。如果创建成功但加管理员失败，CLI 会返回补救命令，例如：

```bash
yach doc-admin-add "<文档URL>" 143277
```

也可以显式指定：

```bash
yach doc-create "项目说明" newdoc --admin 143277
```

如果确实不需要自动加管理员：

```bash
yach doc-create "临时文档" newdoc --no-admin
```

## 健康检查

只检查本地依赖和配置：

```bash
yach doctor --offline
```

检查配置并获取 token：

```bash
yach doctor
```

查看 token 缓存状态：

```bash
yach auth status
```

## 本地验证

改动后先跑最小检查：

```bash
./tests/smoke.sh
```

## 安全说明

- 不要把 app key、app secret、access token 提交到 Git。
- 不要把 `~/.config/yach/config.json` 分享给别人。
- `yach token` 会输出 access token，只在调试时使用。
- 分享仓库前确认 `bin/yach` 和 README 里没有真实密钥。

## 当前边界

- 表格读取和复杂文档导出只作为 best-effort，不承诺所有知音楼文档类型都能稳定解析。
- 删除文档、消息历史等高风险或未验证接口暂不开放。
- 群消息、文档追加、权限修改都会真实写线上数据，执行前请确认目标。
