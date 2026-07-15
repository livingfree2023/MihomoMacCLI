# MihomoMacCLI

> [中文文档](README.md)

**Install bare-metal Clash/Mihomo on macOS: run once, auto-starts on every boot.**

---

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/livingfree2023/MihomoMacCLI/main/mihomo-mac-cli.sh | zsh
```

---

## Features

- **Install Mihomo** - Automatically download and install the latest mihomo binary from GitHub releases
- **Import Subscriptions** - Import proxy configurations from URLs or local .yaml files with custom naming
- **Multi-Config Management** - Store multiple configurations and switch between them easily
- **Launchd Service** - Install mihomo as a macOS system service that starts automatically
- **System Proxy** - Automatically configure macOS system proxy settings
- **Dynamic Port Detection** - Extract proxy port from configuration files (mixed-port or port)
- **MetaCubeXD Dashboard** - Open the web-based management panel in your default browser
- **Complete Uninstall** - Clean removal of service, binary, and all configuration files

---

## Requirements

- macOS (tested on macOS 12+)
- zsh shell (default on macOS)
- curl
- python3 (for parsing GitHub API responses)
- sudo privileges (for installing to /usr/local/bin)

---

## Usage

Run the script to access the interactive menu:

```bash
curl -fsSL https://raw.githubusercontent.com/livingfree2023/MihomoMacCLI/main/mihomo-mac-cli.sh | zsh
```

### Menu Options

**[1] Install Mihomo**

Downloads the latest mihomo binary for your architecture (arm64 or amd64) and installs it to `/usr/local/bin/mihomo`.

**[2] Import Subscription**

Import a proxy configuration by:
- Providing a subscription URL (http/https)
- Providing a path to a local .yaml file

You'll be prompted to name the configuration (e.g., "home", "airport", "work").

**[3] Select Config**

View all imported configurations and switch between them. The active configuration is marked with a green indicator.

**[4] Start Service**

Install mihomo as a launchd service that:
- Starts automatically on system boot
- Restarts automatically if it crashes
- Sets system proxy on Wi-Fi interface
- Uses the port specified in your configuration file

**[5] Stop Service**

Stop the running mihomo service and restore system proxy settings to off.

**[6] Open MetaCubeXD Panel**

Open the [MetaCubeXD](https://metacubex.github.io/metacubexd/) web dashboard in your default browser for advanced proxy management.

**[7] Uninstall**

Completely remove:
- The launchd service
- The mihomo binary
- Service scripts and plist files
- Optionally, all configuration files

**[0] Exit**

Exit the manager.

---

## File Structure

```
/usr/local/bin/mihomo                          # Mihomo binary
~/.config/mihomo/
├── config.yaml                                # Symlink to active config
├── configs/                                   # All imported configurations
│   ├── home.yaml
│   ├── airport.yaml
│   └── work.yaml
├── mihomo-service.sh                          # Auto-generated service wrapper
├── service.log                                # Service stdout log
└── service.err                                # Service stderr log

~/Library/LaunchAgents/
└── com.mihomo.service.plist                   # Launchd service definition
```

---

## Configuration

Your mihomo configuration file (.yaml) should include at minimum:

```yaml
mixed-port: 1080  # or port: 1080
mode: rule
```

The script automatically detects the proxy port from `mixed-port` or `port` fields in your configuration.

### Example Configuration

For a complete example with DNS, proxy providers, and routing rules, see the [mihomo documentation](https://wiki.metacubex.one/).

---

## How It Works

1. **Service Installation**: The script generates a wrapper shell script and a launchd plist file, then registers the service with `launchctl bootstrap`.

2. **System Proxy**: When the service starts, it uses `networksetup` to configure HTTP, HTTPS, and SOCKS proxy settings on the Wi-Fi interface.

3. **Config Switching**: Multiple configurations are stored in `~/.config/mihomo/configs/`. The active configuration is a symlink at `~/.config/mihomo/config.yaml`.

4. **Port Detection**: The script parses your YAML configuration to extract the proxy port, ensuring the system proxy matches your mihomo settings.

---

## Troubleshooting

**Service won't start**

Check the error log:

```bash
cat ~/.config/mihomo/service.err
```

**Proxy not working**

1. Verify the service is running:

```bash
launchctl print gui/$(id -u)/com.mihomo.service
```

2. Check system proxy settings:

```bash
networksetup -getwebproxy Wi-Fi
```

3. Verify your configuration is valid:

```bash
/usr/local/bin/mihomo -t -f ~/.config/mihomo/config.yaml
```

**Can't connect to API providers**

Ensure your proxy configuration includes proper DNS settings and that the mihomo service is running before launching applications that need proxy access.

---

## Uninstall

To completely remove mihomo and all related files:

```bash
curl -fsSL https://raw.githubusercontent.com/livingfree2023/MihomoMacCLI/main/mihomo-mac-cli.sh | zsh
# Select option [7] Uninstall
```

Or manually:

```bash
# Stop and remove service
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.mihomo.service.plist
rm ~/Library/LaunchAgents/com.mihomo.service.plist

# Remove binary
sudo rm /usr/local/bin/mihomo

# Remove configuration
rm -rf ~/.config/mihomo
```

---

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

---

## License

MIT License - See [LICENSE](LICENSE) file for details.

---

## Credits

- [mihomo](https://github.com/MetaCubeX/mihomo) - The core proxy engine
- [MetaCubeXD](https://github.com/MetaCubeX/metacubexd) - Web dashboard

---

## Support

If you encounter any issues or have questions, please [open an issue](https://github.com/livingfree2023/MihomoMacCLI/issues).
