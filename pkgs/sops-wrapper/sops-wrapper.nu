const SSH_KEYS_DIR = "/etc/ssh"

def check-sudo [] {
# make sure that the command is run as sudo
    if (^bash -c 'echo $EUID') != "0" {
        error make {
            msg: "This command must be run as sudo."
            help: "sudo sops ..."
        }
    }
}

def make-decryptable [ file?: path ] {
    # the path to the age key defined in the nix config
    let ageKeyPath = ^nix eval --impure --raw --expr $"\(__getFlake \"($env.PWD)\"\).outputs.nixosConfigurations.(^hostname).config.sops.age.keyFile"

    if $file == null {
        ^ssh-to-age -private-key -i $"($SSH_KEYS_DIR)/id_ed25519" -o $ageKeyPath
        exit  
    }

    open .sops.yaml
        | get creation_rules
        | where {|row| $file =~ $row.path_regex}
        | get key_groups.age | first | first
        | each {|$publicAgeKey|
            ls $SSH_KEYS_DIR
                | get name
                | where {|file| (open $file) =~ "OPENSSH PRIVATE KEY"} 
                | each {|sshKeyFile|
                    ^ssh-to-age -private-key -i $sshKeyFile # to private age key
                }
                | where {|$privateAgeKey|
                    $privateAgeKey | save --force /tmp/ageKey # save to temp file as age-keygen needs file input
                    return ($publicAgeKey == (^age-keygen -y /tmp/ageKey))
                }
                | if ($in | length) > 0 {
                    first
                } else {
                    null
                }
        }
        | if ($in | length) > 0 {
            $in | first | save --force $ageKeyPath
        } else {
            error make {
                msg: $"No SSH key found in ($SSH_KEYS_DIR) that can decrypt $($file)"
            }
        }
}

def --wrapped main [ file: path ...rest ] {
    check-sudo

    make-decryptable $file

    do --ignore-errors { # errors are okay here
        # must be called with sudo
        ^sops $file ...$rest
    }

    # reset impersonation
    make-decryptable
}