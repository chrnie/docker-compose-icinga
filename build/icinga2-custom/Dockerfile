FROM  buildpack-deps:scm as netways-repo
RUN ["/bin/bash", "-exo", "pipefail", "-c", "curl -s https://packages.netways.de/netways-repo.asc | gpg --dearmor > /netways.gpg; DIST=$(awk -F\"[)(]+\" '/VERSION=/ {print $2}' /etc/os-release); echo \"deb https://packages.netways.de/plugins/debian ${DIST} main\" | tee /netways-plugins.list"]

FROM icinga/icinga2:master as icinga2-custom
USER root

COPY --from=netways-repo /netways.gpg /etc/apt/trusted.gpg.d/netways.gpg
COPY --from=netways-repo /netways-plugins.list /etc/apt/sources.list.d/netways-plugins.list

RUN ["/bin/bash", "-exo", "pipefail", "-c", "apt-get update; export DEBIAN_FRONTEND=noninteractive; apt-get install --no-install-{recommends,suggests} -y netways-plugins-mysql-health; apt-get clean; rm -vrf /var/lib/apt/lists/*"]


USER icinga

