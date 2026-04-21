# Single source of truth for SSH public keys.
# Reference these instead of hardcoding keys elsewhere.
{
  users = {
    philip = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIELlZIKOjzYwlQKX1axFreOXhZQz5MuPscRi2PDba1zi philip@mactan"
    ];
  };

  systems = {
    vegeta = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQC13nevyvkrL8rYnQh2GTcM8XUmhDWVvNRlUEd3Mkz root@vegeta";
  };
}
