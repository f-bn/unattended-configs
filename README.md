### General informations

This repository contains unattended configurations for my personal devices running on Linux and Windows.

**Devices**

| Device         | Type      | Operating system | Chassis                     | Configuration |
| :--------------| :---------| :----------------| :---------------------------| :-------------|
| **buran**      | Desktop   | Windows 11 24H2  | Custom                      | [unattended.xml](./desktops/buran_unattended.xml) |
| **buran**      | WSL       | Ubuntu 24.04 LTS | Virtual machine (WSL2)      | [default.user-data](./wsl2/default.user-data)     |
| **foton**      | Laptop    | Ubuntu 25.04     | Thinkpad P14s Gen 5 (Intel) | [foton.user-data](./laptops/foton.user-data)      |
| **proton**     | Server    | Ubuntu 24.04 LTS | ASRock DeskMini X300        | [proton.user-data](./servers/proton.user-data)   |

### How-to

**Desktops/Laptop/Servers**

For the desktops, laptops and servers installations, Ventoy `autoinstall` feature is used to pass `autoinstall`/`user-data` (Ubuntu) or `autounattend.xml` (Windows) configuration files to the respective installer.

In order to setup Ventoy `autoinstall`, we need to create a hierarchy in the **Ventoy** partition (where ISOs are stored on the USB key) by placing the unattended configurations in expected folders. Here the current hierarchy used for this repository:

```shell
/autoinstall/
├── desktops/
│   └── buran_unattended.xml
├── laptops/
│   └── foton.user-data
├── servers/
│   └── proton.user-data
/ventoy/
└── ventoy.json
ubuntu-24.04.2-live-server-amd64.iso
ubuntu-25.04-desktop-amd64.iso
win11_24h2.iso
```

The `ventoy.json` file defines which unattended file(s) is to be used with a given ISO file. You can have multiple configurations for an ISO file if needed.

In the following configuration, I define that:
  - **Ubuntu Server** ISOs are linked to my *proton* server unattended configuration
  - **Ubuntu Desktop** ISOs are linked to my *foton* laptop unattended configuration
  - **Windows 11** ISOs are linked to my *buran* desktop unattended configuration

```json
{
    "auto_install":[
        {
            "image": "/ubuntu-**.**.*-live-server-amd64.iso",
            "template": [
                "/autoinstall/servers/proton.user-data"
            ]
        },
        {
            "image": "/ubuntu-**.**-live-server-amd64.iso",
            "template": [
                "/autoinstall/servers/proton.user-data"
            ]
        },
        {
            "image": "/ubuntu-**.**-desktop-amd64.iso",
            "template": [
                "/autoinstall/laptops/foton.user-data"
            ]
        },
        {
            "image": "/ubuntu-**.**.*-desktop-amd64.iso",
            "template": [
                "/autoinstall/laptops/foton.user-data"
            ]
        },
        {
            "image": "/win11_****.iso",
            "template": [
                "/autoinstall/desktops/buran_unattended.xml"
            ]
        }
    ]
}
```

Once done, simply boot the USB key on a device, then select the ISO in the Ventoy menu. You will have 2 options for each ISO:
* Boot without an installation template
* Boot with `/autoinstall/**/**` template depending on the selected ISO

If the boot option with installation template is chosen, the installation will be launched in a fully automatted manner !

**WSL2**

For WSL2, the new Cloud-Init [WSL datasource](https://docs.cloud-init.io/en/latest/reference/datasources/wsl.html) is used. This allows to bring your own custom distribution image and provision it in a standard and automated way. Regarding requirements, the image must at least include `systemd` and `cloud-init` packages.

The `default.user-data` file located in [wsl2](./wsl2/default.user-data) folder must be placed at `%USERPROFILE%\.cloud-init\default.user-data`.

As an example, we will import [an official Ubuntu 24.04 WSL image](https://cloud-images.ubuntu.com/wsl/releases/noble/current/) provided by Canonical: 

```shell
PS C:\WSL> wsl --import Linux <install folder> ubuntu.tar.gz
```

Launch the WSL2 by waiting for `cloud-init` to provision your instance:

```shell
PS C:\WSL> wsl -d Linux -- cloud-init status --wait
...................................................................................................
status: done
```

As *cloud-init* will shutdown the WSL distribution at the end of provisionning, shutdown the WSL and start it again to avoid any issues:

```shell
PS C:\WSL> wsl --shutdown
PS C:\WSL> wsl -d Linux
```

And voilà !

### References

- Cloud-Init: https://cloud-init.io/
- Ubuntu autoinstall reference: https://canonical-subiquity.readthedocs-hosted.com/en/latest/reference/autoinstall-reference.html
- Ventoy: https://www.ventoy.net/en/index.html
- Ventoy Autoinstall plugin: https://www.ventoy.net/en/plugin_autoinstall.html
- Unattend Generator (Windows): https://schneegans.de/windows/unattend-generator/