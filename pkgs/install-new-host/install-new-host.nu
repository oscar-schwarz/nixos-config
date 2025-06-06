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
];
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


def main [ ip_address: string machine_name: string ] {
    # This script needs to be run as sudo
    if (^bash -c 'echo $EUID') != "0" {
        error make {
            msg: "This command must be run as sudo."
        }
    }

    # At first we create a stub hardware configuration
    let hardware_config_path = "./machines/" + $machine_name + "/default.nix"
    mkdir (^dirname $hardware_config_path)
    # get the hardware configuration from nixos-anywhere (its just a nix throw expression)
    http get https://raw.githubusercontent.com/nix-community/nixos-anywhere-examples/refs/heads/main/hardware-configuration.nix | save $hardware_config_path

    # Then we append a new host to the hosts.nix file
    open ./hosts.nix
        | lines | take (($in | length) - 1) | str join "\n" # remove last line
        | ($in + $'
  ($NEW_HOSTNAME) = {
      machine = "($machine_name)";
      ip-address = "($ip_address)"; 
  };
}
')




    # generate an ssh key
    # ^ssh-keygen -N "" -t ed25519 -f $SSH_KEY_PATH

}


