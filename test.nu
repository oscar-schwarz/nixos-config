def remove-double-space [] {
    if ($in =~ "  ") {
        $in | str replace "  " " " | remove-double-space
    } else $in
}

cat status.txt
    | lines
    | each {remove-double-space | str trim}
    | where {$in =~ "new file|modified|deleted"}