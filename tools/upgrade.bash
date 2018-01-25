#!/bin/bash -e

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../libraries/util.bash"

    header 'UPGRADING INSTALLATION'
    runUpgrade

    "$(dirname "${BASH_SOURCE[0]}")/clean-up.bash"
}

main "${@}"