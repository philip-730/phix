{ ... }: {
  # Add zsh to /etc/shells so it is a valid login shell on NixOS.
  # Both NixOS hosts set users.users.<name>.shell = pkgs.zsh, so this
  # must be enabled at the system level too.
  programs.zsh.enable = true;
}
