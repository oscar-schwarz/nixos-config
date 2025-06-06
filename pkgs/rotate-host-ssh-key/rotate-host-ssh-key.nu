let SSH_KEY_PATH = ^nix eval --impure --raw --expr $"__head \(__getFlake \"($env.PWD)\"\).outputs.nixosConfigurations.(^hostname).config.sops.age.sshKeyPaths"

def get-sops-file [hostname: string] {
    "secrets/" + $hostname + ".yaml"
}

def main [host?: string] {
    # make sure that the command is run as sudo
    if (^bash -c 'echo $EUID') != "0" {
        error make { msg: "This command must be run as sudo." }
    }

    # if hostname is null, then choose current host
    let hostname = $host | default (^hostname)
    let sshKeyPath = $SSH_KEY_PATH + (if ($host != null) {"_" + $host} else {""})
    
    # At first move old ssh key to _old
    mv $sshKeyPath ($sshKeyPath + "_old")

    # Then generate new key and a public key
    ^ssh-keygen -t ed25519 -f $sshKeyPath -N "" -C ("root@" + $hostname)

    # Now we need to replace the old public key in hosts.nix with the new one
    open "./hosts.nix" 
        | str replace (
            ^nix eval --impure --raw --expr $"\(__getFlake \"($env.PWD)\"\).outputs.nixosConfigurations.($hostname).config.hosts.this.ssh.public-key"
        ) (^ssh-keygen -y -f $sshKeyPath) 
        | save "./hosts.nix" --force


    # before generating new age key decrypt secrets file
    ^sops --decrypt (get-sops-file $hostname) | save /tmp/decryptSops --force
    
    # Now generate new age key to correct location
    ^ssh-to-age -private-key -i $sshKeyPath -o (
        ^nix eval --impure --raw --expr $"\(__getFlake \"($env.PWD)\"\).outputs.nixosConfigurations.($hostname).config.sops.age.keyFile"
    )
    # update .sops.yaml
    ^cat .sops.yaml
        | do {
            let prevPubAgeKey = $in 
                | lines 
                | where {$in =~ "&" + $hostname} 
                | first
                | split row " "
                | last
            
            $in | str replace $prevPubAgeKey (^age-keygen -y "/tmp/ageKey")
        }
        | save ".sops.yaml" --force


    # ^sops --encrypt "/tmp/decryptSops"
}