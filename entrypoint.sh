#!/usr/bin/env bash

ENTRYPOINT=${ENTRYPOINT:=$1}
ENTRYPOINT=${ENTRYPOINT:=server}

if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${USER_NAME:-default}:x:$(id -u):0:${USER_NAME:-default} user:${HOME}:/sbin/nologin" >> /etc/passwd
  fi
fi

display_usage() {
    echo "Usage: ${0} <server|shell|help>"
    echo
    echo "If the first argument isn't one of the above modes,"
    echo "the arguments will be exec'd directly, i.e.:"
    echo
    echo "  ${0} uptime"
}

if [[ "${ENTRYPOINT}" = "help" ]]
then
    display_usage
    exit 0
fi


case "$ENTRYPOINT" in
    "shell")
        echo "Entering shell mode"
        exec /bin/bash
        ;;
    "server")
        cp config/ca.crt /etc/pki/ca-trust/source/anchors
        update-ca-trust extract
        openssl s_server -accept 8443 -HTTP -cert config/ssl.crt -key config/ssl.key
        ;;
    *)
        echo "Running '$ENTRYPOINT'"
        exec $ENTRYPOINT
        ;;
esac

