# MihomoMacCLI - Mihomo 服务管理器

> [English](README_en.md)

**Mac OS 安装裸核 Clash/Mihomo 脚本：只需要执行一次，之后自动启动。**

---

## 安装

```bash
curl -fsSL https://raw.githubusercontent.com/livingfree2023/MihomoMacCLI/main/mihomo-mac-cli.sh | zsh
```

---

## 功能特性

- **安装 Mihomo** - 自动从 GitHub 下载并安装最新的 mihomo 程序
- **导入订阅** - 从 URL 或本地 .yaml 文件导入代理配置，支持自定义命名
- **多配置管理** - 存储多个配置文件并轻松切换
- **Launchd 服务** - 将 mihomo 安装为 macOS 系统服务，开机自动启动
- **系统代理** - 自动配置 macOS 系统代理设置
- **动态端口检测** - 从配置文件中提取代理端口（mixed-port 或 port）
- **MetaCubeXD 面板** - 在默认浏览器中打开 Web 管理面板
- **完整卸载** - 彻底清除服务、程序和所有配置文件

---

## 系统要求

- macOS（在 macOS 12+ 上测试）
- zsh shell（macOS 默认）
- curl
- python3（用于解析 GitHub API 响应）
- sudo 权限（用于安装到 /usr/local/bin）

---

## 使用方法

运行脚本以访问交互式菜单：

```bash
curl -fsSL https://raw.githubusercontent.com/livingfree2023/MihomoMacCLI/main/mihomo-mac-cli.sh | zsh
```

### 菜单选项

**[1] 安装 Mihomo**

下载适合您架构（arm64 或 amd64）的最新 mihomo 程序并安装到 `/usr/local/bin/mihomo`。

**[2] 导入订阅**

通过以下方式导入代理配置：
- 提供订阅 URL（http/https）
- 提供本地 .yaml 文件的路径

系统会提示您为配置命名（例如："home"、"airport"、"work"）。

**[3] 选择配置**

查看所有已导入的配置并在它们之间切换。当前激活的配置会以绿色标记。

**[4] 启动服务**

将 mihomo 安装为 launchd 服务：
- 系统启动时自动启动
- 崩溃时自动重启
- 在 Wi-Fi 接口上设置系统代理
- 使用配置文件中指定的端口

**[5] 停止服务**

停止运行中的 mihomo 服务并将系统代理设置恢复为关闭。

**[6] 打开 MetaCubeXD 面板**

在默认浏览器中打开 [MetaCubeXD](https://metacubex.github.io/metacubexd/) Web 面板以进行高级代理管理。

**[7] 卸载**

彻底移除：
- launchd 服务
- mihomo 程序
- 服务脚本和 plist 文件
- 可选：所有配置文件

**[0] 退出**

退出管理器。

---

## 文件结构

```
/usr/local/bin/mihomo                          # Mihomo 程序
~/.config/mihomo-mac-cli/
├── config.yaml                                # 指向当前配置的符号链接
├── configs/                                   # 所有导入的配置
│   ├── home.yaml
│   ├── airport.yaml
│   └── work.yaml
├── mihomo-service.sh                          # 自动生成的服务包装脚本
├── service.log                                # 服务标准输出日志
└── service.err                                # 服务错误输出日志

~/Library/LaunchAgents/
└── com.mihomo-mac-cli.service.plist                   # Launchd 服务定义
```

---

## 配置说明

您的 mihomo 配置文件（.yaml）至少应包含：

```yaml
mixed-port: 1080  # or port: 1080
mode: rule
```

脚本会自动从配置中的 `mixed-port` 或 `port` 字段检测代理端口。

### 示例配置

有关包含 DNS、代理提供者和路由规则的完整示例，请参阅 [mihomo 文档](https://wiki.metacubex.one/)。

---

## 工作原理

1. **服务安装**：脚本生成包装 shell 脚本和 launchd plist 文件，然后使用 `launchctl bootstrap` 注册服务。

2. **系统代理**：服务启动时，使用 `networksetup` 在 Wi-Fi 接口上配置 HTTP、HTTPS 和 SOCKS 代理设置。

3. **配置切换**：多个配置存储在 `~/.config/mihomo-mac-cli/configs/` 中。当前激活的配置是 `~/.config/mihomo-mac-cli/config.yaml` 的符号链接。

4. **端口检测**：脚本解析您的 YAML 配置以提取代理端口，确保系统代理与您的 mihomo 设置匹配。

---

## 故障排除

**服务无法启动**

检查错误日志：

```bash
cat ~/.config/mihomo-mac-cli/service.err
```

**代理不工作**

1. 验证服务是否运行：

```bash
launchctl print gui/$(id -u)/com.mihomo-mac-cli.service
```

2. 检查系统代理设置：

```bash
networksetup -getwebproxy Wi-Fi
```

3. 验证配置是否有效：

```bash
/usr/local/bin/mihomo -t -f ~/.config/mihomo-mac-cli/config.yaml
```

**无法连接到 API 提供者**

确保您的代理配置包含正确的 DNS 设置，并且在启动需要代理访问的应用程序之前 mihomo 服务正在运行。

---

## 卸载

要彻底移除 mihomo 及所有相关文件：

```bash
curl -fsSL https://raw.githubusercontent.com/livingfree2023/MihomoMacCLI/main/mihomo-mac-cli.sh | zsh
# 选择选项 [7] 卸载
```

或手动：

```bash
# 停止并移除服务
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.mihomo-mac-cli.service.plist
rm ~/Library/LaunchAgents/com.mihomo-mac-cli.service.plist

# 移除程序
sudo rm /usr/local/bin/mihomo

# 移除配置
rm -rf ~/.config/mihomo
```

---

## 贡献

欢迎贡献！请随时提交问题或拉取请求。

---

## 许可证

MIT 许可证 - 详情请参阅 [LICENSE](LICENSE) 文件。

---

## 致谢

- [mihomo](https://github.com/MetaCubeX/mihomo) - 核心代理引擎
- [MetaCubeXD](https://github.com/MetaCubeX/metacubexd) - Web 面板

---

## 支持

如果您遇到任何问题或有疑问，请[提交问题](https://github.com/livingfree2023/MihomoMacCLI/issues)。
