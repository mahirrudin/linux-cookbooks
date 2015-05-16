#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'build-essential'
}

function install()
{
    # Clean Up

    initializeFolder "${nodejsInstallFolder}"

    # Install

    if [[ "${nodejsVersion}" = 'latest' ]]
    then
        nodejsVersion="$(getLatestVersionNumber)"
        local -r url="http://nodejs.org/dist/latest/node-${nodejsVersion}-linux-x64.tar.gz"
    else
        if [[ "$(grep -o '^v' <<< "${nodejsVersion}")" = '' ]]
        then
            nodejsVersion="v${nodejsVersion}"
        fi

        local -r url="http://nodejs.org/dist/${nodejsVersion}/node-${nodejsVersion}-linux-x64.tar.gz"
    fi

    unzipRemoteFile "${url}" "${nodejsInstallFolder}"
    chown -R "$(whoami):$(whoami)" "${nodejsInstallFolder}"
    symlinkLocalBin "${nodejsInstallFolder}/bin"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${nodejsInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/node-js.sh.profile" '/etc/profile.d/node-js.sh' "${profileConfigData[@]}"

    # Install NPM Packages

    local package=''

    for package in "${nodejsInstallNPMPackages[@]}"
    do
        header "INSTALLING NODE-JS NPM PACKAGE ${package}"
        npm install "${package}" -g
    done

    # Clean Up

    local -r userHomeFolderPath="$(getCurrentUserHomeFolder)"

    rm -f -r "${userHomeFolderPath}/.cache" \
             "${userHomeFolderPath}/.node-gyp" \
             "${userHomeFolderPath}/.npm" \
             "${userHomeFolderPath}/.qws"

    # Display Version

    header 'DISPLAYING VERSIONS'

    info "Node Version: $(node --version)"
    info "NPM Version : $(npm --version)"
}

function getLatestVersionNumber()
{
    local -r versionPattern='v[[:digit:]]{1,2}\.[[:digit:]]{1,2}\.[[:digit:]]{1,3}'
    local -r shaSum256="$(getRemoteFileContent 'http://nodejs.org/dist/latest/SHASUMS256.txt.asc')"

    grep -E -o "node-${versionPattern}\.tar\.gz" <<< "${shaSum256}" | grep -E -o "${versionPattern}"
}

function main()
{
    local -r version="${1}"
    local -r installFolder="${2}"

    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING NODE-JS'

    # Override Default Config

    if [[ "$(isEmptyString "${version}")" = 'false' ]]
    then
        nodejsVersion="${version}"
    fi

    if [[ "$(isEmptyString "${installFolder}")" = 'false' ]]
    then
        nodejsInstallFolder="${installFolder}"
    fi

    # Install

    installDependencies
    install
    installCleanUp
}

main "${@}"