#!/bin/bash -e

function main()
{
    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    "${appPath}/essential.bash"

    "${appPath}/../cookbooks/jdk/recipes/install.bash"
}

main "${@}"