### General informations

This repository contains unattended configurations for my personal devices running on Linux and Windows.

**Devices**

| Device         | Type      | Operating system | Chassis                     | Configuration |
| :--------------| :---------| :----------------| :---------------------------| :-------------|
| **buran**      | Desktop   | Windows 11 24H2  | Custom                      | [unattended.xml](./desktops/buran/buran_unattended.xml) |
| **buran**      | WSL       | Ubuntu 24.04 LTS | Virtual machine (WSL2)      | [default.user-data](./wsl2/buran/default.user-data)     |
| **foton**      | Laptop    | Ubuntu 25.04     | Thinkpad P14s Gen 5 (Intel) | [foton.user-data](./laptops/foton/foton.user-data)      |
| **proton**     | Server    | Ubuntu 24.04 LTS | ASRock X300                 | [proton.user-data](./servers/proton/proton.user-data)   |

### How-to

**Desktops/Laptop/Servers**

For the desktop, laptop and server installations, Ventoy `autoinstall` feature is used to pass `user-data` (Ubuntu) or `unattended.xml` (Windows) configuration files to the respective installer.

We need to create a dedicated autoinstall folder on the Ventoy partition:

```
/autoinstall
  \-
```

**WSL2**

For WSL2, the new Cloud-Init [WSL datasource](https://docs.cloud-init.io/en/latest/reference/datasources/wsl.html) is used. This allows to bring your own custom distribution image and provision it in a standard and automated way. Regarding requirements, the image must at least include `systemd` and `cloud-init` packages.

The file located in [folder](./wsl2/default.user-data) must be placed at `%USERPROFILE%\.cloud-init\default.user-data`. As an example, we will import [an official Ubuntu 24.04 WSL image](https://cloud-images.ubuntu.com/wsl/releases/noble/current/) provided by Canonical: 

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
