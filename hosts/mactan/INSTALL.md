# mactan install guide

## Before touching the USB

1. **Disable BitLocker** — Settings → Privacy & Security → Device Encryption → turn off (or Control Panel → BitLocker Drive Encryption → Turn off). Wait for decryption to finish, can take a while.
2. **Shrink Windows partition** — Disk Management → right click C: → Shrink Volume → shrink by 200GB
3. **Make phix repo public** on GitHub
4. **Flash NixOS ISO** (64-bit x86_64 graphical) to USB with Balena Etcher

## BIOS

5. Restart → mash `F2` or `Del` to get into BIOS
6. Disable Secure Boot (you'll re-enable it later with lanzaboote)
7. Set USB as first boot device
8. Save and reboot

## In the live environment

9. Open a terminal (don't use the Calamares GUI installer)

10. **Find your disk**
    ```bash
    lsblk
    ```
    Look for your NVMe drive (probably `nvme0n1`) and confirm you can see the free space after C:.

11. **Partition with cfdisk**
    ```bash
    cfdisk /dev/nvme0n1
    ```
    - Use arrow keys to select the free space
    - Select `[ New ]` → hit enter (it will default to the full free space, that's fine)
    - Select `[ Write ]` → type `yes` → confirm
    - Select `[ Quit ]`

    Then confirm it was created:
    ```bash
    lsblk
    ```
    Note the new partition number (e.g. `nvme0n1p7`) — you'll use it below.

12. **Encrypt the partition with LUKS**
    ```bash
    cryptsetup luksFormat /dev/nvme0n1pX   # replace X with your new partition number
    # type YES in caps when prompted, then set your passphrase — don't forget it

    cryptsetup open /dev/nvme0n1pX nixos
    # enter your passphrase
    ```

13. **Format and mount**
    ```bash
    mkfs.ext4 /dev/mapper/nixos

    mount /dev/mapper/nixos /mnt
    mkdir -p /mnt/boot
    mount /dev/nvme0n1p1 /mnt/boot    # EFI partition — partition 1, Windows made this
    ```

14. **Generate hardware config**
    ```bash
    nixos-generate-config --root /mnt
    ```

15. **Create home directory with correct ownership**
    ```bash
    mkdir -p /mnt/home/philip
    chown 1000:100 /mnt/home/philip
    ```
    This prevents home-manager from failing on first boot due to the directory being owned by root.

16. **Clone the flake**
    ```bash
    nix-shell -p git
    mkdir -p /mnt/home/philip/.config
    git clone https://github.com/philip-730/phix /mnt/home/philip/.config/phix
    ```

17. **Copy hardware config into the flake**
    ```bash
    cp /mnt/etc/nixos/hardware-configuration.nix /mnt/home/philip/.config/phix/hosts/mactan/
    ```

18. **Get the UUID of your encrypted partition**
    ```bash
    lsblk -f
    ```
    Find your partition (e.g. `nvme0n1p7`) and copy the UUID next to it.

19. **Add LUKS to mactan config** — first check if `nixos-generate-config` already detected it:
    ```bash
    cat /mnt/etc/nixos/hardware-configuration.nix | grep luks
    ```
    If you see a `luks.devices` entry, you're done — it's already handled. If not, edit `hosts/mactan/default.nix` and add:
    ```nix
    boot.initrd.luks.devices."nixos" = {
      device = "/dev/disk/by-uuid/YOUR-UUID-HERE";
    };
    ```

20. **Commit and push**
    ```bash
    cd /mnt/home/philip/.config/phix
    git add hosts/mactan/
    git commit -m "feat(mactan): add hardware configuration and LUKS setup"
    git push
    ```

21. **Install**
    ```bash
    nixos-install --flake /mnt/home/philip/.config/phix#mactan
    ```
    It will ask you to set a root password at the end — set one and don't forget it.

22. **Set philip's password**
    ```bash
    nixos-enter --root /mnt -c "passwd philip"
    ```
    Do this before rebooting. `nixos-install` only sets the root password — without this step `philip` has no password and you won't be able to log in at the TTY.

23. **Reboot**
    ```bash
    reboot
    ```
    Remove the USB when it shuts down.

## First boot

- GRUB will show NixOS and Windows — pick NixOS
- Type your LUKS passphrase when prompted (before the login screen)
- Log in at the TTY with username `philip` and the password you set during install
- Type `Hyprland` to launch the desktop

> **Note:** Step 15 should prevent this, but if home-manager failed to create files (Hyprland won't start, home directory looks empty), the directory was likely recreated as root. Fix it:
> ```bash
> sudo chown -R philip:users /home/philip
> sudo nixos-rebuild switch --flake ~/.config/phix#mactan
> ```
> Then try launching Hyprland again.

## After first boot — add to mactan config

```nix
hardware.bluetooth.enable = true;
services.pipewire = {
  enable = true;
  alsa.enable = true;
  pulse.enable = true;
};
```

Then rebuild:
```bash
sudo nixos-rebuild switch --flake ~/.config/phix#mactan
```

---

## Lanzaboote (Secure Boot) — do this after everything is working

### 1. Add to flake inputs

```nix
lanzaboote = {
  url = "github:nix-community/lanzaboote/v0.4.1";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

And pass it through in outputs:
```nix
outputs = { self, nixpkgs, nix-darwin, home-manager, lanzaboote, ... }@inputs:
```

### 2. Add to mactan config

```nix
imports = [
  ./hardware-configuration.nix
  inputs.lanzaboote.nixosModules.lanzaboote
];

boot.loader.grub.enable = lib.mkForce false; # lanzaboote takes over boot
boot.lanzaboote = {
  enable = true;
  pkiBundle = "/etc/secureboot";
};
```

### 3. Generate and enroll keys

```bash
sudo nix run nixpkgs#sbctl -- create-keys
sudo nixos-rebuild switch --flake ~/.config/phix#mactan
sudo nix run nixpkgs#sbctl -- enroll-keys --microsoft
```

### 4. Enable Secure Boot in BIOS

- Reboot into BIOS
- Enable Secure Boot
- Save and reboot

### 5. Verify

```bash
sudo nix run nixpkgs#sbctl -- verify
```

All files should show as signed.
