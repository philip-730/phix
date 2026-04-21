let
  keys = import ../modules/ssot/keys.nix;
in
{
  "tailscale_auth.age".publicKeys = keys.users.philip ++ [ keys.systems.vegeta ];
  "user_ssh.age".publicKeys = keys.users.philip ++ [ keys.systems.vegeta ];
}
