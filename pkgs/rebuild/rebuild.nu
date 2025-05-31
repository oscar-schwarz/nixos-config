def quick-commit [] {
    ^git status

}

def --wrapped main [ 
    --hostname: string 
    --flake-path: path
    --disable-git-commit
    --flake: string 
    ...rest: string
] {
    let flakePath = $flake_path | default "~/nixos"
    let host = $hostname | default (^hostname)

    let previousPWD = $env.PWD
    if not $disable_git_commit {
        cd $flakePath
        ^git add --all
    }

    let flakeFlag = $flake | default ($flakePath + "#" + $host)

    do --ignore-errors {
        let result = (^sudo nixos-rebuild --flake $flakeFlag ...$rest) | complete
        $result
        # if ($result.exit_code == 0) {
        #     ^git commit -m "Successful Rebuild"
        #     ^git push
        # }
    }

    cd $previousPWD
}