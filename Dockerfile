FROM registry.redhat.io/rhel7:7.6
LABEL maintainer "thomasmckay@redhat.com"

ENV CERTTEST /cert-test
RUN mkdir $CERTTEST
WORKDIR $CERTTEST

RUN INSTALL_PKGS="\
        openssl \
        wget \
        iputils \
        " && \
    yum install -y yum-utils && \
    yum-config-manager --quiet --disable "*" >/dev/null && \
    yum-config-manager --quiet --enable \
        rhel-7-server-rpms \
        rhel-7-server-optional-rpms \
        --save >/dev/null && \
    yum -y --setopt=tsflags=nodocs --setopt=skip_missing_names_on_install=False install $INSTALL_PKGS && \
    yum -y update && \
    yum -y clean all

RUN mkdir $CERTTEST/bin && \
    curl -fsSL -o $CERTTEST/bin/cfssljson https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 && \
    curl -fsSL -o $CERTTEST/bin/cfssl https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 && \
    curl -fsSL -o $CERTTEST/bin/jwtproxy https://github.com/coreos/jwtproxy/releases/download/v0.0.1/jwtproxy-linux-x64 && \
    chmod 0755 $CERTTEST/bin/cfssl $CERTTEST/bin/cfssljson $CERTTEST/bin/jwtproxy

COPY entrypoint.sh .
COPY certs-create.sh .
COPY page.html .

EXPOSE 8443 6060

RUN chgrp -R 0 $CERTTEST && \
    chmod -R g=u $CERTTEST

VOLUME [$CERTTEST/config]

ENTRYPOINT [ "/cert-test/entrypoint.sh" ]
CMD [ "server" ]

#USER 1001