# whonix-type ⌨️

> **Bypass Wayland clipboard isolation in Whonix 18 & QEMU/KVM virtual machines using hardware-level QMP keystroke injection.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Linux](https://img.shields.io/badge/Platform-Linux-blue.svg)]()
[![Target: QEMU / Proxmox VE / KVM](https://img.shields.io/badge/Target-Proxmox%20%7C%20QEMU-orange.svg)]()

---

## 🔍 The Problem

In **Whonix 18**, the desktop environment transitioned from X11 (XFCE) to **Wayland (LXQt + Labwc)**. 

Because of Wayland's security model, virtualization guest clipboard tools (such as `spice-vdagent` used by Proxmox noVNC or SPICE `virt-viewer`) are unable to bridge clipboard data into native Wayland applications (like Tor Browser, FeatherPad, or QTerminal). This is a confirmed upstream limitation:
* [Whonix Forum: Whonix 18 - Wayland based - KVM - Clipboard Sharing - Broken](https://forums.whonix.org/t/whonix-18-wayland-based-kvm-clipboard-sharing-broken/20857)

As a result, pasting passwords, URLs, or commands into Whonix 18 through noVNC or SPICE clipboards silently fails.

---

## 💡 The Solution

`whonix-type` bypasses the clipboard layer entirely. 

Instead of relying on guest agent daemons or display server clipboard protocols, `whonix-type` connects directly to the hypervisor's **QEMU Machine Protocol (QMP)** socket and emits native USB keyboard hardware scancodes. 

```
Host (Terminal / Script)
       │
       ▼
 [whonix-type]
       │ (QMP Socket)
       ▼
  QEMU Hypervisor
       │ (Simulated USB Keyboard Scancodes)
       ▼
Guest VM (Whonix 18 / Wayland)
 └── Tor Browser / Terminal / Password Prompt
```

Because input is received as real physical keyboard events:
- ✅ Works **100% reliably** on Wayland, X11, tty consoles, and BIOS prompts.
- ✅ Requires **zero guest agents** or modifications inside the VM.
- ✅ Preserves guest anonymity and security (no shared clipboard vulnerability).
- ✅ Compatible with **Proxmox VE**, **libvirt**, and standalone **QEMU**.

---

## 🚀 Installation

### Quick Install (Proxmox VE / Linux Host)

```bash
curl -fsSL https://raw.githubusercontent.com/Heretek-AI/whonix-type/main/install.sh | bash
```

Or manually clone and install:

```bash
git clone https://github.com/Heretek-AI/whonix-type.git
cd whonix-type
install -m 755 whonix-type /usr/local/bin/whonix-type
```

### Requirements
- Python 3.6+ (standard library only; zero external pip dependencies).
- Access to the VM's QMP socket (usually run as `root` on Proxmox VE).

---

## 📖 Usage

### Basic Usage

Click inside the target window or input field in your VM console (e.g., Tor Browser search bar, terminal, or password prompt), then run:

```bash
whonix-type "https://duckduckgogg42xjoc72x3sjasowoarfbgcmvfimaftt6twagswzczad.onion"
```

### Piping from STDIN

```bash
echo "sudo apt update && sudo apt dist-upgrade" | whonix-type
```

Or inject multi-line scripts or files:

```bash
cat myscript.sh | whonix-type
```

### Targeting Different VMs

By default, `whonix-type` targets **VM 111** (`Whonix-Workstation`). To type into the Gateway or another VM:

```bash
# Type into VM 110 (Whonix-Gateway)
whonix-type --vmid 110 "whonixcheck"

# Or set default via environment variable
export VMID=110
whonix-type "nyx"
```

### Custom QMP Socket Path (Standard QEMU / libvirt)

If you are running QEMU outside Proxmox VE:

```bash
whonix-type --socket /var/run/libvirt/qemu/run/whonix-workstation.monitor "my_secret_token"
```

### Adjusting Typing Delay

For applications with sluggish event loops, adjust the delay between keypresses (default is `0.01` seconds):

```bash
whonix-type --delay 0.05 "Slowly typed text"
```

---

## ⚙️ Options Reference

| Option | Flag | Default | Description |
| :--- | :--- | :--- | :--- |
| `--vmid` | `-v` | `111` | Target Proxmox VM ID |
| `--socket` | `-s` | `/var/run/qemu-server/{vmid}.qmp` | Direct path to QMP unix socket |
| `--delay` | `-d` | `0.01` | Inter-keystroke delay in seconds |
| `text` | *(positional)* | *stdin* | Text string to type into the guest |

---

## 🔒 Security Note

Whonix officially disables clipboard sharing by default to prevent accidental data leaks and clipboard-snooping malware from bridging the guest-host isolation boundary. 

`whonix-type` is strictly a **one-way push** from the trusted hypervisor host into the guest. It does not create a persistent bi-directional channel, preventing any compromise inside the guest VM from reading or monitoring your host clipboard.

---

## 📄 License

MIT License. See [LICENSE](LICENSE) for details.
