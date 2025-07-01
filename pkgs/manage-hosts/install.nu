# Install a nixos configuration with nixos-anywhere to a remote host.
export def "main install" [hostname: string] {
    let ip_address = ^nix eval --expr $"\(import ./hosts.nix\).($hostname).ip-address" --impure --raw

    # Get ssh password
    let SSHPASS = do {
        mut password = "";
        while (try {^sshpass -p $password ssh $"root@($ip_address)" exit; return true} catch {return false}) {
            $password = input -s $"Please provide the SSH password for root@($ip_address)"
        }
    }

    print "Correct password!"
}