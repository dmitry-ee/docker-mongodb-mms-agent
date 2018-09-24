FROM debian:jessie

# Set envs
ENV MONGO_MMS_AGENT_MAJOR		6.6
ENV MONGO_MMS_AGENT_VERSION	6.6.2
ENV MONGO_MMS_AGENT_BUILD		6.6.2.464-1

RUN apt-get -qqy update \
 && apt-get -qqy upgrade \
 && apt-get -qqy install curl \
 && apt-get -qqy install logrotate \
 && apt-get -qqy install supervisor \
 && apt-get -qqy install munin-node \
 && apt-get -qqy install libsasl2-2 \
 && curl -sSL https://cloud.mongodb.com/download/agent/monitoring/mongodb-mms-monitoring-agent_${MONGO_MMS_AGENT_BUILD}_amd64.ubuntu1604.deb -o mms.deb \
 && dpkg -i mms.deb \
 && rm mms.deb \
 && apt-get -qqy autoremove \
 && apt-get -qqy clean \
 && rm -rf /var/lib/apt/*

# Add munin-node conf
ADD conf/munin/munin-node.conf /etc/munin/munin-node.conf

# Add supervisord conf
ADD conf/supervisor /etc/supervisor

# Add entrypoint
ADD docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
