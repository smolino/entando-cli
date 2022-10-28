#!/bin/bash
bash <(curl -L "https://get.entando.org/cli") --update --release="v7.1.1"
source "$HOME/.entando/activate" --force
ent check-env develop --yes --lenient
source "$HOME/.entando/activate" --force
cd /home/podman
export JAVA_HOME="/usr/lib/jvm/java-11-openjdk"
