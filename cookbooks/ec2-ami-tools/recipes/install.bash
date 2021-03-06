#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'ruby')" = 'false' || ! -d "${EC2_AMI_TOOLS_RUBY_INSTALL_FOLDER_PATH}" ]]
    then
        "$(dirname "${BASH_SOURCE[0]}")/../../ruby/recipes/install.bash" "${EC2_AMI_TOOLS_RUBY_INSTALL_FOLDER_PATH}"
    fi
}

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${EC2_AMI_TOOLS_INSTALL_FOLDER_PATH}"

    # Install

    unzipRemoteFile "${EC2_AMI_TOOLS_DOWNLOAD_URL}" "${EC2_AMI_TOOLS_INSTALL_FOLDER_PATH}"

    local -r unzipFolder="$(
        find "${EC2_AMI_TOOLS_INSTALL_FOLDER_PATH}" \
            -maxdepth 1 \
            -xtype d \
        2> '/dev/null' |
        tail -1
    )"

    if [[ "$(isEmptyString "${unzipFolder}")" = 'true' || "$(trimString "$(wc -l <<< "${unzipFolder}")")" != '1' ]]
    then
        fatal 'FATAL : multiple unzip folder names found'
    fi

    if [[ "$(ls -A "${unzipFolder}")" = '' ]]
    then
        fatal "FATAL : folder '${unzipFolder}' empty"
    fi

    # Move Folder

    moveFolderContent "${unzipFolder}" "${EC2_AMI_TOOLS_INSTALL_FOLDER_PATH}"
    symlinkUsrBin "${EC2_AMI_TOOLS_INSTALL_FOLDER_PATH}/bin"
    rm -f -r "${unzipFolder}"

    # Config Profile

    createFileFromTemplate \
        "$(dirname "${BASH_SOURCE[0]}")/../templates/ec2-ami-tools.sh.profile" \
        '/etc/profile.d/ec2-ami-tools.sh' \
        '__INSTALL_FOLDER_PATH__' \
        "${EC2_AMI_TOOLS_INSTALL_FOLDER_PATH}"

    # Display Version

    displayVersion "$(ec2-ami-tools-version)"

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING EC2-AMI-TOOLS'

    checkRequireLinuxSystem
    checkRequireRootUser

    installDependencies
    install
    installCleanUp
}

main "${@}"