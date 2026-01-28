#!/bin/bash

set -ex

# Initialize
if [[ $1 == init ]]; then

    # Initialize pass
    gpg --generate-key --batch /protonmail/gpgparams
    pass init pass-key

    # Extract certificate
    /protonmail/extract-cert.sh

    # Kill the other instance as only one can be running at a time.
    # This allows users to run entrypoint init inside a running container
    # which is useful in a k8s environment.
    # || true to make sure this would not fail in case there is no running instance.
    pkill proton-bridge || true

    # Login
    /protonmail/proton-bridge --cli $@

else

    # Check for changes in the certificate JSON and extract certificate again
    $(while inotifywait -e close_write /etc/traefik/acme; do echo "Extracting new certificate"; /protonmail/extract-cert.sh; done) &

    # socat will make the conn appear to come from 127.0.0.1 as
    # ProtonMail Bridge currently expects that
    # It also allows us to bind to the real ports :)
    socat TCP-LISTEN:25,fork TCP:127.0.0.1:1025 &
    socat TCP-LISTEN:143,fork TCP:127.0.0.1:1143 &

    # Start protonmail
    # Fake a terminal, so it does not quit because of EOF...
    rm -f faketty
    mkfifo faketty
    cat faketty | /protonmail/proton-bridge --cli $@

fi