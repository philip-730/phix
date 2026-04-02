# mactan install guide

## Before touching the USB

1. **Shrink Windows partition** — Disk Management → right click C: → Shrink Volume → shrink by 200GB
2. **Make phix repo public** on GitHub
3. **Flash NixOS ISO** (64-bit x86_64 graphical) to USB with Balena Etcher

## BIOS

4. Restart → mash `F2` or `Del` to get into BIOS
5. Disable Secure Boot
6. Set USB as first boot device
7. Save and reboot

## In the live environment

8. Open a terminal (don't use the Calamares GUI installer)

9. **Find your disk**
   ```bash
   lsblk
   ```
   Look for your NVMe drive (probably `nvme0n1`) with the unallocated free space you made.

10. **Format the free space as ext4**
    ```bash
    mkfs.ext4 /dev/nvme0n1pX  # replace X with your new partition number
    ```

11. **Mount partitions**
    ```bash
    mount /dev/nvme0n1pX /mnt                  # your new NixOS root partition
    mkdir -p /mnt/boot
    mount /dev/nvme0n1p1 /mnt/boot             # existing EFI partition (Windows made this)
    ```
    > Not sure which partition is EFI? Run `lsblk -f` and look for the FAT32 partition ~100-500MB in size.

12. **Generate hardware config**
    ```bash
    nixos-generate-config --root /mnt
    ```

13. **Clone the flake**
    ```bash
    nix-shell -p git
    mkdir -p /mnt/home/philip/.config
    git clone https://github.com/philip-730/phix /mnt/home/philip/.config/phix
    ```

14. **Copy hardware config into the flake**
    ```bash
    cp /mnt/etc/nixos/hardware-configuration.nix /mnt/home/philip/.config/phix/hosts/mactan/
    ```

15. **Commit and push**
    ```bash
    cd /mnt/home/philip/.config/phix
    git add hosts/mactan/hardware-configuration.nix
    git commit -m "feat(mactan): add hardware configuration"
    git push
    ```

16. **Install**
    ```bash
    nixos-install --flake /mnt/home/philip/.config/phix#mactan
    ```
    It will ask you to set a root password at the end — set one and don't forget it.

17. **Reboot**
    ```bash
    reboot
    ```
    Remove the USB when it shuts down.

## First boot

- GRUB will show NixOS and Windows — pick NixOS
- Log in at the TTY with username `philip` and the password you set
- Type `Hyprland` to launch the desktop

## After first boot — add to mactan config

```nix
networking.networkmanager.enable = true;
users.users.philip.extraGroups = [ "wheel" "networkmanager" ];
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
