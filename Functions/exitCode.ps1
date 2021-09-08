# exitCode function for scripts with many possibly exit codes.
function exitCode($i) {
    switch ($i) {
        0 {$comment = "Success"}
        1 {$comment = "Error 1"}
        2 {$comment = "Error 2"}
        3 {$comment = "Error 3"}
        4 {$comment = "Complete"}
    }

    Write-Host "Completed with exit code $i : $comment"

    if ($i -eq 0 -or $i -eq 4) {
        exit 0
    }
    else {
        exit $i
    }
}

<# Call the function

if (-not($condition) {
    Write-Host "Condition is false"
    exitCode(1)
}
else {
    Write-Host "Condition is true"
    exitCode(0)
}

#>