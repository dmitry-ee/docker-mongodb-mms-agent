FROM 		debian:jessie

# DEFAULT ENVS
ENV 		MONGO_MMS_AGENT_MAJOR	10.2
ENV 		MONGO_MMS_AGENT_VERSION	10.2.11
ENV 		MONGO_MMS_AGENT_BUILD	10.2.11.5927-1

RUN 		apt-get -qqy update \
      && apt-get -qqy upgrade \
      && apt-get -qqy install curl \
      && apt-get -qqy install logrotate \
      && apt-get -qqy install supervisor \
      && apt-get -qqy install munin-node \
      && apt-get -qqy install libsasl2-2
ADD   mms-aam-10.2.11.5927-1.deb /mms.deb

RUN   dpkg -i mms.deb \
      && rm mms.deb \
      && apt-get -qqy autoremove \
      && apt-get -qqy clean \
      && rm -rf /var/lib/apt/*

LABEL 		description="MongoDB Enterprise OpsManager (non-official) MMS Agent (repo forked from some italian guy)"
LABEL 		maintainer="Farkhad Akhmetshin # fakhmetshin@alfabank.ru #"

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
