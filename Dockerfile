# stable/Containerfile
#
# Build a Podman container image from the latest
# stable version of Podman on the Fedoras Updates System.
# https://bodhi.fedoraproject.org/updates/?search=podman
# This image can be used to create a secured container
# that runs safely with privileges within the container.
#
#FROM registry.fedoraproject.org/fedora:latest
FROM registry.access.redhat.com/ubi8/ubi-minimal:8.4-200
# Don't include container-selinux and remove
# directories used by dnf that are just taking
# up space.
# TODO: rpm --setcaps... needed due to Fedora (base) image builds
#       being (maybe still?) affected by
#       https://bugzilla.redhat.com/show_bug.cgi?id=1995337#c3
RUN microdnf install -y dnf
RUN dnf -y update && \
    rpm --setcaps shadow-utils 2>/dev/null && \
    dnf -y install git maven tar java-11-openjdk-devel.x86_64 && \
    dnf clean all && \
    rm -rf /var/cache /var/log/dnf* /var/log/yum.* && \
    alternatives --set java_sdk_11_openjdk /usr/lib/jvm/java-11-openjdk-11.0.17.0.8-2.el8_6.x86_64 && \
    adduser --system -s /bin/bash -u 100730000 -g 0 podman && \
#echo -e "podman:1:999\npodman:1001:64535" > /etc/subuid; \
#echo -e "podman:1:999\npodman:1001:64535" > /etc/subgid;
    groupadd podman && \
#RUN mkdir -p /home/podman/.local/share/containers && \
#    chown podman:podman -R /home/podman && \
#    usermod -G root podman
    export JAVA_HOME="/usr/lib/jvm/java-11-openjdk"
COPY /script.sh /home/podman/
COPY /docker /home/podman/
RUN chmod +x /home/podman/docker && \
# RUN mv /usr/bin/docker /usr/bin/docker.old
    cp /home/podman/docker /usr/local/bin/podman && \
    cp /home/podman/docker /usr/local/bin/docker && \
    export PATH="$PWD:$PATH" && \
    chmod +x /home/podman/script.sh &&  \
    chgrp podman /home/podman/script.sh && \
    chown podman:podman -R /home/podman/
USER 100730000
RUN export JAVA_HOME="/usr/lib/jvm/java-11-openjdk"
# RUN /home/podman/script.sh
COPY entrypoint.sh /entrypoint.sh
WORKDIR /home/podman
RUN export JAVA_HOME="/usr/lib/jvm/java-11-openjdk"
ENV JAVA_HOME="/usr/lib/jvm/java-11-openjdk"
CMD ["tail",  "-f",  "/dev/null"]
