<div align="center">
  <img src="https://raw.githubusercontent.com/microsoft/vscode-icons/main/icons/light/gear.svg" alt="Config Logo" width="150"/>

  **Unattended configurations**

  ---
</div>

## 📋 Overview

[![License](https://img.shields.io/github/license/f-bn/unattended-configs)](./LICENSE)
[![GitHub](https://img.shields.io/badge/Repository-GitHub-181717?logo=github)](https://github.com/f-bn/unattended-configs)

This repository contains automated installation and provisioning configurations for my personal devices running Linux and Windows.

- 🔧 **Automated setup** - Fully unattended installations with minimal user interaction
- 🖥️ **Multi-platform** - Supports Ubuntu (bare-metal and WSL2), Fedora CoreOS and Windows
- 🔄 **Version-controlled** - Track and manage configuration changes over time

Complemented with dotfile management via [`chezmoi`](https://github.com/f-bn/dotfiles).

## 📦 Available Configurations

| Device | Type | OS | Hardware | Configuration |
|--------|------|----|---------| --------------|
| **[buran](./desktops/buran/)** | Desktop | Windows 11 24H2 | Custom build | [unattended.xml](./desktops/buran/unattended.xml) |
| **[buran](./wsl2/)** | WSL | Ubuntu 24.04 | WSL2 | [ubuntu.user-data](./wsl2/ubuntu.user-data) |
| **[foton](./laptops/foton/)** | Laptop | Ubuntu 25.10 | Thinkpad P14s Gen 5 | [autoinstall.user-data](./laptops/foton/autoinstall.user-data) |
| **[soyuz](./servers/soyuz/)** | Server | Fedora CoreOS 43 | Beelink SER5 PRO | [ignition.yaml](./servers/soyuz/ignition.yaml) |

### Legacy Configurations

| Device | Type | OS | Hardware | Configuration |
|--------|------|----|---------| --------------|
| **[proton](./servers/proton/)** | Server | Ubuntu 24.04 LTS | ASRock DeskMini X300 | [autoinstall.user-data](./servers/proton/autoinstall.user-data) |

## 🚀 Quick Start

### Desktops, Laptops & Servers

All physical installations leverage Ventoy's `autoinstall` plugin to automatically pass configuration files to the respective installers:

- **Ubuntu (Desktop/Server)** - Cloud-Init `user-data` format
- **Fedora CoreOS** - Ignition `ignition.yaml` format  
- **Windows** - `autounattend.xml` format

#### Ventoy setup

Create the following structure in the Ventoy partition:

```
/autoinstall/
├── desktops/
│   └── buran/
│       └── unattended.xml
├── laptops/
│   └── foton/
│       └── autoinstall.user-data
├── servers/
│   └── proton/
│       └── autoinstall.user-data
├── wsl2/
│   └── ubuntu.user-data
/ventoy/
└── ventoy.json
ubuntu-24.04.2-live-server-amd64.iso
ubuntu-25.04-desktop-amd64.iso
win11_24h2.iso
...
```

Configure `ventoy.json` to map ISOs to configuration files:

```json
{
    "auto_install":[
        {
            "image": "/ubuntu-**.**.*-live-server-amd64.iso",
            "template": ["/autoinstall/servers/proton/autoinstall.user-data"]
        },
        {
            "image": "/ubuntu-**.**-desktop-amd64.iso",
            "template": ["/autoinstall/laptops/foton/autoinstall.user-data"]
        },
        {
            "image": "/win11_****.iso",
            "template": ["/autoinstall/desktops/buran/unattended.xml"]
        }
    ]
}
```

Boot the USB key, select an ISO, and choose the automated installation option.

### WSL2

Uses Cloud-Init's [WSL datasource](https://docs.cloud-init.io/en/latest/reference/datasources/wsl.html) for provisioning.

Place `default.user-data` at `%USERPROFILE%\.cloud-init\default.user-data`, then:

```powershell
# Import Ubuntu image
wsl --import Linux <install-folder> ubuntu.tar.gz

# Wait for provisioning
wsl -d Linux -- cloud-init status --wait

# Restart
wsl --shutdown
wsl -d Linux
```

## 📚 References

- [Cloud-Init](https://cloud-init.io/)
- [Ubuntu Autoinstall Reference](https://canonical-subiquity.readthedocs-hosted.com/en/latest/reference/autoinstall-reference.html)
- [Ventoy](https://www.ventoy.net/en/index.html)
- [Ventoy Autoinstall Plugin](https://www.ventoy.net/en/plugin_autoinstall.html)
- [Unattend Generator (Windows)](https://schneegans.de/windows/unattend-generator/)

## License

See [LICENSE](./LICENSE) file for details.
