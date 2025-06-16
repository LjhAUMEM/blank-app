#!/bin/bash
#
# Author: nano

uname -a

# if [ ! -f "nezha-agent" ]; then
#     curl -LO https://github.com/nezhahq/agent/releases/latest/download/nezha-agent_linux_amd64.zip
#     unzip nezha-agent_linux_amd64.zip nezha-agent
#     rm nezha-agent_linux_amd64.zip
# fi

# if [ ! -f "cloudflared" ]; then
#     curl -L -o cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
# fi

# if [ ! -f "xray" ]; then
#     curl -LO https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
#     unzip Xray-linux-64.zip xray
#     rm Xray-linux-64.zip
# fi

is_nz_running="false"
is_cf_running="false"
is_main_running="false"

for pid_path in /proc/[0-9]*/; do
    if [ -r "${pid_path}cmdline" ]; then
        pid="${pid_path//[^0-9]/}"
        cmdline_file="${pid_path}cmdline"
        cmdline_output=$(xargs -0 < "$cmdline_file" 2>/dev/null)
        if echo "$cmdline_output" | grep -q "nezha-agent"; then
            # kill -9 "$pid"
            is_nz_running="true"
        fi
        if echo "$cmdline_output" | grep -q "xray"; then
            # kill -9 "$pid"
            is_xray_running="true"
        fi
        if echo "$cmdline_output" | grep -q "cloudflared"; then
            # kill -9 "$pid"
            is_cf_running="true"
        fi
        if echo "$cmdline_output" | grep -q "main"; then
            # kill -9 "$pid"
            is_main_running="true"
        fi
    fi
done

echo
echo "is_nz_running: $is_nz_running"
echo
echo "is_cf_running: $is_cf_running"
echo
echo "is_main_running: $is_main_running"
echo

###########################################

export NZ_SERVER=${NZ_SERVER:-""}
export NZ_CLIENT_SECRET=${NZ_CLIENT_SECRET:-""}
export NZ_TLS=${NZ_TLS:-"true"}
export NZ_INSECURE_TLS=${NZ_INSECURE_TLS:-"false"}
export NZ_DISABLE_AUTO_UPDATE=${NZ_DISABLE_AUTO_UPDATE:-"true"}
export NZ_UUID=${NZ_UUID:-""}

CF_TOKEN=${CF_TOKEN:-""}

ARGS=${ARGS:-"-cdn=false -reality=false -s=false"}

###########################################

if [ "$is_nz_running" = "false" ]; then
    chmod +x nezha-agent
    ./nezha-agent service -c config.yml install &>/dev/null
    nohup ./nezha-agent -c config.yml &>/dev/null &
fi

if [ "$is_cf_running" = "false" ]; then
    chmod +x cloudflared
    nohup ./cloudflared tunnel run --token "$CF_TOKEN" &>/dev/null &
fi

if [ "$is_main_running" = "false" ]; then
    chmod +x main
    nohup ./main $ARGS &>/dev/null &
fi

####################################################

for pid_path in /proc/[0-9]*/; do
    if [ -r "${pid_path}cmdline" ]; then
        pid="${pid_path//[^0-9]/}"
        echo -n "${pid}: "
        xargs -0 < "${pid_path}cmdline"
        echo
    fi
done

commands=("curl" "unzip" "ps" "ip" "hostname" "pkill" "grep" "openssl" "base64")
for cmd in "${commands[@]}"; do
    echo -n "$cmd "
    if command -v "$cmd" &> /dev/null; then
        echo "存在"
    else
        echo "不存在"
    fi
    echo
done