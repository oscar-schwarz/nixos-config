def --wrapped main [ 
    --hostname: string 
    --flake-path: path
    --disable-git-commit
    --flake: string 
    ...rest: string
] {
    let flakePath = $flake_path | default "~/nixos"
    let host = $hostname | default (^hostname)

    if not $disable_git_commit {
        cd $flake_path
        ^git add --all
    }

    let flakeFlag = $flake | default ($flakePath + "#" + $host)

    do {
        let result = ^sudo nixos-rebuild --flake $flakeFlag ...$rest | complete

        $result
    }
}