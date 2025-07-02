# Install a nixos configuration with nixos-anywhere to a remote host.
export def --wrapped "main install" [hostname: string ...rest: string] {
    let ip_address = ^nix eval --expr $"\(import ./hosts.nix\).($hostname).ip-address" --impure --raw

    # # Get ssh password
    # export-env { $env.SSHPASS = (
    #     ^sshpass -p (
    #         input -s $"Please provide the SSH password for root@($ip_address):"
    #     ) ssh $"root@($ip_address)" exit
    # )}

    # print "Correct password!"

    ^nixos-anywhere --flake $".#($hostname)" --generate-hardware-config nixos-generate-config $"./hardware/($hostname).nix" --target-host $"root@($ip_address)" ...$rest
}