FROM 		debian:jessie

# DEFAULT ENVS
ENV 		MONGO_MMS_AGENT_MAJOR	7.0
ENV 		MONGO_MMS_AGENT_VERSION	7.0.0
ENV 		MONGO_MMS_AGENT_BUILD	7.0.0.481-1

RUN 		apt-get -qqy update \
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

LABEL 		description="MongoDB Enterprise OpsManager (non-official) MMS Agent (repo forked from some italian guy)"
LABEL 		maintainer="Dmitry Evdokimov # devdokimoff@gmail.com / devdokimov@alfabank.ru #"

# LINKIN' SOME MUNIN PLUGINS ACCORDING TO:
# https://docs.opsmanager.mongodb.com/current/tutorial/configure-monitoring-munin-node/
RUN   rm /etc/munin/plugins/* \
      && ln -s /usr/share/munin/plugins/cpu /etc/munin/plugins/cpu \
      && ln -s /usr/share/munin/plugins/iostat /etc/munin/plugins/iostat \
      && ln -s /usr/share/munin/plugins/iostat_ios /etc/munin/plugins/iostat_ios

ADD 		conf/munin/munin-node.conf /etc/munin/munin-node.conf
ADD 		conf/munin/munin-node-plugin.conf /etc/munin/plugin-conf.d/munin-node
ADD 		conf/supervisor /etc/supervisor

ADD 		docker-entrypoint.sh /
ENTRYPOINT 		["/docker-entrypoint.sh"]

CMD 		["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
