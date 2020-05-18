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
cat /etc/mongodb-mms/automation-agent.config > "$config_tmp"

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
    rm -f /etc/munin/plugins/iostat
fi

set_config mmsApiKey "$MONGO_MMS_API_KEY"
set_config mmsGroupId "$MONGO_MMS_GROUP_ID"
set_config mmsBaseUrl "$MONGO_MMS_BASE_URL"

cat "$config_tmp" > /etc/mongodb-mms/automation-agent.config
rm "$config_tmp"

exec "$@"
