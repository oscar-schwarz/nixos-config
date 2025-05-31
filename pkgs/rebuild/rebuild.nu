def quick-commit [] {
    ^git status

}

def --wrapped main [ 
    --hostname: string 
    --flake-path: path
    --disable-git-commit
    --flake: string
    command?: string
    ...rest: string
] {
    let flakePath = $flake_path | default ($env.HOME + "/nixos")
    let host = $hostname | default (^hostname)

    if $command == null {
        ^nixos-rebuild
        exit
    }

    let previousPWD = $env.PWD
    if not $disable_git_commit {
        cd $flakePath
        ^git add --all
        cd $previousPWD
    }

    let flakeFlag = $flake | default ($flakePath + "#" + $host)

    
    ^sudo nixos-rebuild --flake $flakeFlag $command ...$rest
        
    if not $disable_git_commit {
        cd $flakePath
        ^git commit -m "Successful Rebuild"
        cd $previousPWD
    }
}