#!/bin/bash
set -e

# Setup mongodb-mms-agent
if [ ! "$MONGO_MMS_API_KEY" ] || [ ! "$MONGO_MMS_GROUP_ID" ]; then
    {
        echo 'error: MMS_API_KEY or MMS_GROUP_ID was not specified'
        echo 'try something like: docker run -e MMS_API_KEY=... -w MMS_GROUP_ID=... ...'
        echo '(see https://mms.mongodb.com/settings/monitoring-agent for your mmsApiKey)'
        echo
    } >&2
    exit 1
fi

config_tmp="$(mktemp)"
cat /etc/mongodb-mms/monitoring-agent.config > "$config_tmp"
printf "\nenableMunin=true" >> "$config_tmp"

set_config() {
    key="$1"
    value="$2"
    sed_escaped_value="$(echo "$value" | sed 's/[\/&]/\\&/g')"
    sed -ri "s/^($key)[ ]*=.*$/\1 = $sed_escaped_value/" "$config_tmp"
}


if [ -n "$MONGO_MMS_DISABLE_STAT_CPU" ]; then
    rm -f /etc/munin/plugins/cpu
fi
if [ -n "$MONGO_MMS_DISABLE_STAT_DISK" ]; then
    rm -f /etc/munin/plugins/iostat_ios
    rm -f rm /etc/munin/plugins/iostat
fi

set_config mmsApiKey "$MONGO_MMS_API_KEY"
set_config mmsGroupId "$MONGO_MMS_GROUP_ID"
set_config mmsBaseUrl "$MONGO_MMS_BASE_URL"

cat "$config_tmp" > /etc/mongodb-mms/monitoring-agent.config
rm "$config_tmp"

# Setup munin-node
config_tmp="$(mktemp)"
cat /etc/munin/munin-node.conf > "$config_tmp"

# allow interface address ...
echo $( ip route get 8.8.8.8 | head -n 1 | awk '{print "allow ^"$7"$"}' | sed 's@\.@\\.@g' | sed 's@[0-9]*\$@[0-9]*\$@g' ) >> "$config_tmp"

cat "$config_tmp" > /etc/munin/munin-node.conf
rm "$config_tmp"

exec "$@"
