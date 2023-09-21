default:
    just --list

download-alpine:
    mkdir -p var/
    skopeo --insecure-policy copy -a docker://docker.io/library/alpine:latest oci-archive://$PWD/var/alpine.tar.gz

test-skopeo-docker:
    skopeo --debug login --tls-verify=false -u user -p password 127.0.0.1:5000
    skopeo --debug --insecure-policy copy --dest-tls-verify=false -a oci-archive://$PWD/var/alpine.tar.gz docker://127.0.0.1:5000/user/alpine
    skopeo --debug logout 127.0.0.1:5000

test-skopeo-zot:
    skopeo --debug login --tls-verify=false -u user -p password 127.0.0.1:5001
    skopeo --debug --insecure-policy copy --dest-tls-verify=false -a oci-archive://$PWD/var/alpine.tar.gz docker://127.0.0.1:5001/user/alpine
    skopeo --debug logout 127.0.0.1:5001

test-regclient-docker:
    regctl --verbosity debug registry set --tls=disabled 127.0.0.1:5000
    regctl --verbosity debug registry login -u user -p password 127.0.0.1:5000
    regctl --verbosity debug image import 127.0.0.1:5000/user/alpine $PWD/var/alpine.tar.gz
    regctl --verbosity debug registry logout 127.0.0.1:5000

test-regclient-zot:
    regctl --verbosity debug registry set --tls=disabled 127.0.0.1:5001
    regctl --verbosity debug registry login -u user -p password 127.0.0.1:5001
    regctl --verbosity debug image import 127.0.0.1:5001/user/alpine $PWD/var/alpine.tar.gz
    regctl --verbosity debug registry logout 127.0.0.1:5001

test-all: test-skopeo-docker test-skopeo-zot test-regclient-docker

login:
    skopeo --debug login --tls-verify=false -u user -p password 127.0.0.1:5000
    skopeo --debug login --tls-verify=false -u user -p password 127.0.0.1:5001
    regctl --verbosity debug registry set --tls=disabled 127.0.0.1:5000
    regctl --verbosity debug registry login -u user -p password 127.0.0.1:5000
    regctl --verbosity debug registry set --tls=disabled 127.0.0.1:5001
    regctl --verbosity debug registry login -u user -p password 127.0.0.1:5001

logout:
    skopeo --debug logout 127.0.0.1:5000
    skopeo --debug logout 127.0.0.1:5001
    regctl --verbosity debug registry set --tls=disabled 127.0.0.1:5000
    regctl --verbosity debug logout 127.0.0.1:5000
    regctl --verbosity debug registry set --tls=disabled 127.0.0.1:5001
    regctl --verbosity debug logout 127.0.0.1:5001
