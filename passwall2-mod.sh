#!/bin/sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

clear
echo -e "${CYAN}Модифицированный Passwall2 скрипт от AmirHossein (ash-compatible)${NC}"
echo -e "${CYAN}С меню выбора версии (by Grok)${NC}"
echo ""
echo "1. Полная установка последней версии (как оригинал Amir)"
echo "2. Обновить только Passwall2 и Xray"
echo "3. Выбрать и установить любую старую версию (автоматический список)"
echo "4. Выход"
echo ""
echo -n "Выбери (1-4): "
read choice

check_and_add_repo() {
    echo -e "${GREEN}Добавление репозитория...${NC}"
    if ! grep -q "passwall_luci" /etc/opkg/customfeeds.conf 2>/dev/null; then
        wget -O /tmp/passwall.pub https://master.dl.sourceforge.net/project/openwrt-passwall-build/passwall.pub
        opkg-key add /tmp/passwall.pub
        rm /tmp/passwall.pub
        
        . /etc/openwrt_release
        release=${DISTRIB_RELEASE%.*}
        arch=$DISTRIB_ARCH
        for feed in passwall_luci passwall_packages passwall2; do
            echo "src/gz $feed https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-$release/$arch/$feed" >> /etc/opkg/customfeeds.conf
        done
    fi
    opkg update
}

if [ "$choice" = "1" ]; then
    echo -e "${YELLOW}Полная установка последней версии (как у Amir)...${NC}"
    uci set system.@system[0].zonename='Asia/Tehran'
    uci set network.wan.peerdns="0"
    uci set network.wan6.peerdns="0"
    uci set network.wan.dns='1.1.1.1'
    uci set network.wan6.dns='2001:4860:4860::8888'
    uci set system.@system[0].timezone='<+0330>-3:30'
    uci commit
    /sbin/reload_config

    if grep -q SNAPSHOT /etc/openwrt_release; then
        echo -e "${YELLOW}SNAPSHOT версия — используй другой скрипт${NC}"
        exit 1
    fi

    opkg update
    wget -O passwall.pub https://master.dl.sourceforge.net/project/openwrt-passwall-build/passwall.pub
    opkg-key add passwall.pub
    > /etc/opkg/customfeeds.conf
    . /etc/openwrt_release
    release=${DISTRIB_RELEASE%.*}
    arch=$DISTRIB_ARCH
    for feed in passwall_luci passwall_packages passwall2; do
      echo "src/gz $feed https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-$release/$arch/$feed" >> /etc/opkg/customfeeds.conf
    done

    opkg update
    opkg remove dnsmasq
    opkg install dnsmasq-full wget-ssl unzip luci-app-passwall2 kmod-nft-socket kmod-nft-tproxy ca-bundle kmod-inet-diag kernel kmod-netlink-diag kmod-tun ipset

    > /etc/banner
    cat >> /etc/banner << 'EOF'
    ___    __  ___________  __  ______  __________ ___________   __
   /   |  /  |/  /  _/ __ \/ / / / __ \/ ___/ ___// ____/  _/ | / /
  / /| | / /|_/ // // /_/ / /_/ / / / /\__ \\__ \ / __/  / //  |/ /
 / ___ |/ /  / // // _  _/ __  / /_/ /___/ /__/ / /____/ // /|  /
/_/  |_/_/  /_/___/_/ |_/_/ /_/\____//____/____/_____/___/_/ |_/
telegram : @AmirHosseinTSL
EOF

    opkg install xray-core
    if [ ! -f /usr/bin/xray ]; then
        rm -f amirhossein.sh && wget https://raw.githubusercontent.com/amirhosseinchoghaei/mi4agigabit/main/amirhossein.sh && chmod 777 amirhossein.sh && sh amirhossein.sh
    fi

    cd /tmp
    wget -q https://amir3.space/iam.zip
    unzip -o iam.zip -d /
    cd

    uci set system.@system[0].zonename='Asia/Tehran'
    uci set system.@system[0].timezone='<+0330>-3:30'
    uci set passwall2.@global_forwarding[0]=global_forwarding
    uci set passwall2.@global_forwarding[0].tcp_no_redir_ports='disable'
    uci set passwall2.@global_forwarding[0].udp_no_redir_ports='disable'
    uci set passwall2.@global_forwarding[0].tcp_redir_ports='1:65535'
    uci set passwall2.@global_forwarding[0].udp_redir_ports='1:65535'
    uci set passwall2.@global[0].remote_dns='8.8.4.4'

    uci set passwall2.Direct=shunt_rules
    uci set passwall2.Direct.network='tcp,udp'
    uci set passwall2.Direct.remarks='IRAN'
    uci set passwall2.Direct.ip_list='0.0.0.0/8
10.0.0.0/8
100.64.0.0/10
127.0.0.0/8
169.254.0.0/16
172.16.0.0/12
192.0.0.0/24
192.0.2.0/24
192.88.99.0/24
192.168.0.0/16
198.19.0.0/16
198.51.100.0/24
203.0.113.0/24
224.0.0.0/4
240.0.0.0/4
255.255.255.255/32
::/128
::1/128
::ffff:0:0:0/96
64:ff9b::/96
100::/64
2001::/32
2001:20::/28
2001:db8::/32
2002::/16
fc00::/7
fe80::/10
ff00::/8
geoip:ir'
    uci set passwall2.Direct.domain_list='regexp:^.+\.ir$
geosite:category-ir'
    uci set passwall2.myshunt.Direct='_direct'
    uci commit passwall2
    uci commit system
    uci set system.@system[0].hostname=By-AmirHossein
    uci commit system
    uci set dhcp.@dnsmasq[0].rebind_domain='www.ebanksepah.ir 
my.irancell.ir'
    uci commit
    echo -e "${YELLOW}Готово!${NC}"
    /sbin/reload_config

elif [ "$choice" = "2" ]; then
    check_and_add_repo
    opkg install luci-app-passwall2 --force-reinstall
    opkg install xray-core --force-reinstall
    /etc/init.d/passwall2 restart 2>/dev/null
    echo -e "${GREEN}Обновлено!${NC}"

elif [ "$choice" = "3" ]; then
    echo -e "${YELLOW}Поиск версий Passwall2...${NC}"
    . /etc/openwrt_release
    if grep -q SNAPSHOT /etc/openwrt_release; then
        base_path="snapshots/packages"
    else
        release=${DISTRIB_RELEASE%.*}
        base_path="releases/packages-$release"
    fi
    arch=$DISTRIB_ARCH
    folder_url="https://sourceforge.net/projects/openwrt-passwall-build/files/$base_path/$arch/passwall_luci"

    html=$(wget --user-agent="Mozilla/5.0" -qO- "$folder_url/")
    if [ -z "$html" ]; then
        echo -e "${RED}Не удалось загрузить список (проверь интернет или репозиторий)${NC}"
        exit 1
    fi

    files=$(echo "$html" | sed -n 's/.*href="[^"]*\/\(\(luci-app-passwall2_[^"]*_all\.ipk\)\)\/download".*/\1/p' | sort -Vr)
    if [ -z "$files" ]; then
        echo -e "${RED}Нет версий для твоей архитектуры. Попробуй опцию 1.${NC}"
        exit 1
    fi

    count=0
    echo "$files" | while read file; do
        count=$((count+1))
        version=$(echo "$file" | sed 's/luci-app-passwall2_//;s/_all\.ipk//')
        echo "$count. $version"
    done

    echo -n "Выбери номер для отката: "
    read num
    selected=$(echo "$files" | sed -n "${num}p")
    if [ -z "$selected" ]; then
        echo -e "${RED}Неверный номер${NC}"
        exit 1
    fi

    wget --user-agent="Mozilla/5.0" -O /tmp/luci-app-passwall2.ipk "$folder_url/$selected/download"
    opkg install --force-downgrade --force-depends /tmp/luci-app-passwall2.ipk
    rm /tmp/luci-app-passwall2.ipk
    /etc/init.d/passwall2 restart 2>/dev/null
    echo -e "${GREEN}Установлено $selected${NC}"

elif [ "$choice" = "4" ]; then
    exit 0
else
    echo -e "${RED}Неправильный выбор${NC}"
fi
