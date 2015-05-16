#!/bin/bash -e

function install()
{
    installAptGetPackages 'ufw'

    # Set Up Policies

    ufw --force reset
    ufw default deny incoming
    ufw default allow outgoing

    local policy=''

    for policy in "${ufwPolicies[@]}"
    do
        local -r rule=(${policy})

        ufw "${rule[@]}"
    done

    # Enable Service

    ufw --force enable
    ufw status verbose
}

function main()
{
    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING UFW'

    install
    installCleanUp
}

main "${@}"