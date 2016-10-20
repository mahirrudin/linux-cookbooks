#!/bin/bash -e

function install()
{
    umask '0022'

    installPackage 'vim' 'vim'

    mkdir -p '/etc/vim'
    cp -f "${APP_FOLDER_PATH}/../files/vimrc.local.conf" '/etc/vim/vimrc.local'
    chmod 644 '/etc/vim/vimrc.local'

    if [[ "$(isCentOSDistributor)" = 'true' || "$(isRedHatDistributor)" = 'true' ]]
    then
        local -r aliasCommand='alias vi=vim'
        local -r sourceCommand='source /etc/vim/vimrc.local'

        appendToFileIfNotFound '/etc/profile' "${aliasCommand}" "${aliasCommand}" 'false' 'false' 'true'
        appendToFileIfNotFound '/etc/vimrc' "${sourceCommand}" "${sourceCommand}" 'false' 'false' 'true'
    elif [[ "$(isUbuntuDistributor)" = 'false' ]]
    then
        fatal '\nFATAL : only support CentOS, RedHat or Ubuntu OS'
    fi

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING VIM'

    install
    installCleanUp
}

main "${@}"