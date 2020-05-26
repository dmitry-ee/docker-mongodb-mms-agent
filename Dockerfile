FROM 	debian:buster-slim as build

      # install agent
COPY  mms-aam-10.2.11.5927-1.deb /tmp/mms.deb
RUN   dpkg -i /tmp/mms.deb

FROM debian:buster-slim

# DEFAULT ENVS
ENV 	MONGO_MMS_AGENT_BUILD	10.2.11.5927-1

ENV   MONGO_MMS_API_KEY ""
ENV   MONGO_MMS_GROUP_ID ""
ENV   MONGO_MMS_BASE_URL ""

      # copy bin + generated .config file
COPY  --from=build /opt/mongodb-mms-automation/bin/mongodb-mms-automation-agent /usr/bin/mongodb-mms-automation-agent
COPY  --from=build /etc/mongodb-mms/automation-agent.config /etc/mongodb-mms/automation-agent.config

      # apt instal deps
RUN 	apt update \
      && apt install -y --no-install-recommends libsasl2-2 libgssapi-krb5-2 \
      # cleanup
      && apt-get -qqy autoremove \
      && apt-get -qqy clean \
      && rm -rf /var/lib/apt/*

LABEL description="MongoDB Enterprise OpsManager (non-official) MMS Agent (repo forked from some italian guy)"
LABEL maintainer="Farkhad Akhmetshin # fakhmetshin@alfabank.ru #"

ADD   docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/usr/bin/mongodb-mms-automation-agent", "-f", "/etc/mongodb-mms/automation-agent.config"]
