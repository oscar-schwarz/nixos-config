const HOSTNAMES = [
    "biome-fest",
    "blind-spots",
    "haunt-muskie",
    "dreiton",
    "aria-math",
    "taswell",
    "dead-voxel",
    "moog-city",
    "concrete-halls",
    "floating-trees",
    "wet-hands",
]

# Creates a new host.
# Creates an SSH key, appends a blank host config to `hosts.nix` and a secrets configurations in .sops.yaml
export def "main create" [ ip_address: string ] {
    let NEW_HOSTNAME = $HOSTNAMES 
        | where {|hostname| 
            ^nix flake show --quiet --quiet --json
                | from json
                | get "nixosConfigurations"
                | columns 
                | find $hostname 
                | is-empty
        }
        | first

    let SSH_KEY_PATH = "/etc/ssh/id_ed25519_" + $NEW_HOSTNAME

    # This script needs to be run as sudo
    if (^bash -c 'echo $EUID') != "0" {error make {msg: "This command must be run as sudo."}}

    # Get ssh password
    let SSHPASS = do {
        mut password = "";
        while (try {^sshpass -p $password ssh $"root@($ip_address)" exit; return true} catch {return false}) {
            $password = input -s $"Please provide the SSH password for root@($ip_address)"
        }
    }

    print "Correct password!"
    exit

    # At first we create a stub hardware configuration
    let hardware_config_path = "./hardware/" + $NEW_HOSTNAME + ".nix"
    mkdir (^dirname $hardware_config_path)
    # get the hardware configuration from nixos-anywhere (its just a nix throw expression)
    if (not ($hardware_config_path | path exists)) {
        http get https://raw.githubusercontent.com/nix-community/nixos-anywhere-examples/refs/heads/main/hardware-configuration.nix | save $hardware_config_path
    } else {
        print $"($hardware_config_path) exists, keeping file"
    }

    # generate a new ssh key
    ^ssh-keygen -t ed25519 -f $SSH_KEY_PATH -N "" -C ("root@" + $NEW_HOSTNAME)
    # add age key to age keys file
    let privateAgeKey = ^ssh-to-age -private-key -i $SSH_KEY_PATH
    ($privateAgeKey + "\n") | save --append /root/.config/sops/age/keys.txt

    # Then we append a new host to the hosts.nix file
    open ./hosts.nix
        | lines | take (($in | length) - 1) | str join "\n" # remove last line
        | ($in + $'
  ($NEW_HOSTNAME) = {
    ip-address = "($ip_address)";
    ssh = {
      public-key = "(^ssh-keygen -y -f $SSH_KEY_PATH)";
      allow-connections-from = [ "(^hostname)" ];
    }; 
  };
}
'       )
        | save hosts.nix --force
    # add new file rules to .sops.yaml
    ^cat .sops.yaml
        | str replace "creation_rules:" $"  - &($NEW_HOSTNAME) ($privateAgeKey | age-keygen -y)\ncreation_rules:"
        | do {
            $in + $"
  - path_regex: ($NEW_HOSTNAME).yaml$
    key_groups:
    - age:
      - *($NEW_HOSTNAME)
"       }
        | save .sops.yaml --force
}