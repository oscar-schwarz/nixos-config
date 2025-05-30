
def impersonate [ hostname?: string ] {
    # the path to the age key defined in the nix config
    let ageKeyPath = ^nix eval --impure --raw --expr $"\(__getFlake \"($env.PWD)\"\).outputs.nixosConfigurations.(^hostname).config.sops.age.keyFile"

    if $hostname == null {
        ^ssh-to-age -private-key -i "/etc/ssh/id_ed25519" -o $ageKeyPath
        exit  
    }
    let availableHosts = ^ls /etc/ssh
        | split row "\n"
        | where {|filename| $filename =~ "^id_ed25519_.+$"}
        | str replace "id_ed25519_" ""
    let otherSshKeyFile = $"/etc/ssh/id_ed25519_($hostname)" 

    if not ($otherSshKeyFile | path exists) {
        error make {
            msg: $"Cannot impersonate ($hostname) as ($otherSshKeyFile) does not exist."
            help: $"The following hosts are available for impersonation: ($availableHosts | str join ', ')"
        }
    }

    print $"Impersonating ($hostname)..."
    ^ssh-to-age -private-key -i $otherSshKeyFile -o $ageKeyPath

}

def --wrapped main [ --impersonate-host: string ...rest ] {
    if $impersonate_host != null {
        impersonate $impersonate_host
    }

    # must be called with sudo
    ^sudo sops ...$rest

    # reset impersonation
    impersonate
}