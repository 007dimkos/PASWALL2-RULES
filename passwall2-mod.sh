#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

clear
echo -e "${CYAN}Модифицированный скрипт установки Passwall2 от AmirHossein${NC}"
echo -e "${CYAN}Теперь с автоматическим меню выбора любой доступной версии (без ручного поиска)! (by Grok)${NC}"
echo ""
echo "1. Полная установка последней версии (как оригинальный скрипт, перезапишет настройки!)"
echo "2. Обновить только Passwall2 и Xray из репозитория (без перезаписи настроек)"
echo "3. Выбрать и установить любую доступную версию (автоматический список с откатом)"
echo "4. Выход"
echo ""
read -p "Выбери номер (1-4): " choice

check_and_add_repo() {
    echo -e "${GREEN}Проверка и добавление репозитория...${NC}"
    if ! grep -q "passwall_luci" /etc/opkg/customfeeds.conf 2>/dev/null; then
        wget -O /tmp/passwall.pub https://master.dl.sourceforge.net/project/openwrt-passwall-build/passwall.pub
        opkg-key add /tmp/passwall.pub
        rm /tmp/passwall.pub
        
        read release arch <<< $( . /etc/openwrt_release ; echo ${DISTRIB_RELEASE%.*} $DISTRIB_ARCH )
        for feed in passwall_luci passwall_packages passwall2; do
            echo "src/gz $feed https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-$release/$arch/$feed" >> /etc/opkg/customfeeds.conf
        done
    fi
    opkg update
}

if [ "$choice" = "1" ]; then
    echo -e "${YELLOW}Запуск полной установки последней версии (как в оригинале)...${NC}"
    # === Оригинальный код Amir без изменений ===
    echo "Running as root..."
    sleep 2
    clear

    uci set system.@system[0].zonename='Asia/Tehran'
    uci set network.wan.peerdns="0"
    uci set network.wan6.peerdns="0"
    uci set network.wan.dns='1.1.1.1'
    uci set network.wan6.dns='2001:4860:4860::8888'
    uci set system.@system[0].timezone='<+0330>-3:30'
    uci commit system
    uci commit network
    uci commit
    /sbin/reload_config

    SNNAP=`grep -o SNAPSHOT /etc/openwrt_release | sed -n '1p'`
    if [ "$SNNAP" == "SNAPSHOT" ]; then
        echo -e "${YELLOW} SNAPSHOT Version Detected ! ${NC}"
        rm -f passwalls.sh && wget https://raw.githubusercontent.com/amirhosseinchoghaei/Passwall/main/passwalls.sh && chmod 777 passwalls.sh && sh passwalls.sh
        exit 1
    else
        echo -e "${GREEN} Updating Packages ... ${NC}"
    fi

    opkg update
    wget -O passwall.pub https://master.dl.sourceforge.net/project/openwrt-passwall-build/passwall.pub
    opkg-key add passwall.pub
    >/etc/opkg/customfeeds.conf
    read release arch <<< $( . /etc/openwrt_release ; echo ${DISTRIB_RELEASE%.*} $DISTRIB_ARCH )
    for feed in passwall_luci passwall_packages passwall2; do
      echo "src/gz $feed https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-$release/$arch/$feed" >> /etc/opkg/customfeeds.conf
    done

    opkg update
    sleep 3
    opkg remove dnsmasq
    sleep 3
    opkg install dnsmasq-full
    sleep 2
    opkg install wget-ssl
    sleep 1
    opkg install unzip
    sleep 2
    opkg install luci-app-passwall2
    sleep 3
    opkg install kmod-nft-socket
    sleep 2
    opkg install kmod-nft-tproxy
    sleep 2
    opkg install ca-bundle
    sleep 1
    opkg install kmod-inet-diag
    sleep 1
    opkg install kernel
    sleep 1
    opkg install kmod-netlink-diag
    sleep 1
    opkg install kmod-tun
    sleep 1
    opkg install ipset

    >/etc/banner
    echo "    ___    __  ___________  __  ______  __________ ___________   __
   /   |  /  |/  /  _/ __ \/ / / / __ \/ ___/ ___// ____/  _/ | / /
  / /| | / /|_/ // // /_/ / /_/ / / / /\__ \\__ \ / __/  / //  |/ /
 / ___ |/ /  / // // _  _/ __  / /_/ /___/ /__/ / /____/ // /|  /
/_/  |_/_/  /_/___/_/ |_/_/ /_/\____//____/____/_____/___/_/ |_/                                                                                                
telegram : @AmirHosseinTSL" >> /etc/banner

    RESULT5=`ls /etc/init.d/passwall2`
    if [ "$RESULT5" == "/etc/init.d/passwall2" ]; then
        echo -e "${GREEN} Passwall.2 Installed Successfully ! ${NC}"
    else
        echo -e "${RED} Can not Download Packages ... Check your internet Connection . ${NC}"
        exit 1
    fi

    DNS=`ls /usr/lib/opkg/info/dnsmasq-full.control`
    if [ "$DNS" == "/usr/lib/opkg/info/dnsmasq-full.control" ]; then
        echo -e "${GREEN} dnsmaq-full Installed successfully ! ${NC}"
    else
        echo -e "${RED} Package : dnsmasq-full not installed ! (Bad internet connection .) ${NC}"
        exit 1
    fi

    opkg install xray-core
    sleep 2
    RESULT=`ls /usr/bin/xray`
    if [ "$RESULT" == "/usr/bin/xray" ]; then
        echo -e "${GREEN} XRAY : OK ! ${NC}"
    else
        echo -e "${YELLOW} XRAY : NOT INSTALLED X ${NC}"
        sleep 2
        echo -e "${YELLOW} Trying to install Xray on temp Space ... ${NC}"
        sleep 2
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
    echo -e "${YELLOW}** Installation Completed ** ${NC}"
    echo -e "${MAGENTA} Made With Love By : AmirHossein ${NC}"
    /sbin/reload_config

elif [ "$choice" = "2" ]; then
    check_and_add_repo
    echo -e "${GREEN}Обновление Passwall2 и Xray...${NC}"
    opkg install luci-app-passwall2 --force-reinstall
    opkg install xray-core --force-reinstall
    /etc/init.d/passwall2 restart 2>/dev/null
    echo -e "${GREEN}Готово! Текущая версия: $(opkg info luci-app-passwall2 | grep Version)${NC}"

elif [ "$choice" = "3" ]; then
    echo -e "${YELLOW}Автоматический поиск и выбор версии Passwall2...${NC}"
    . /etc/openwrt_release
    if echo "$DISTRIB_DESCRIPTION" | grep -qi snapshot; then
        base_path="snapshots/packages"
        echo "Обнаружена SNAPSHOT-версия OpenWRT — пытаемся найти пакеты в snapshots..."
    else
        release=${DISTRIB_RELEASE%.*}
        base_path="releases/packages-$release"
    fi
    arch=$DISTRIB_ARCH
    folder_url="https://sourceforge.net/projects/openwrt-passwall-build/files/$base_path/$arch/passwall_luci"

    echo "Загрузка списка из: $folder_url"
    html=$(wget -qO- "$folder_url/" )
    if [ -z "$html" ] || echo "$html" | grep -qi "not found\|folder empty"; then
        echo -e "${RED}Папка не найдена или пустая. Нет пакетов для вашей версии/архитектуры. Попробуйте опцию 1.${NC}"
        exit 1
    fi

    mapfile -t files < <(echo "$html" | grep -o 'luci-app-passwall2_[^<]*_all\.ipk' | sort -Vr)
    if [ ${#files[@]} -eq 0 ]; then
        echo -e "${RED}Не найдено ни одной версии Passwall2 для вашего роутера.${NC}"
        exit 1
    fi

    echo -e "${GREEN}Найдено ${#files[@]} версий (новейшие сверху):${NC}"
    for i in "${!files[@]}"; do
        file="${files[$i]}"
        version=$(echo "$file" | sed 's/luci-app-passwall2_//;s/_all\.ipk//')
        echo "$((i+1)). $version"
    done

    read -p "Выберите номер версии для установки/отката: " num
    if ! [[ "$num" =~ ^[0-9]+$ ]] || [ "$num" -lt 1 ] || [ "$num" -gt ${#files[@]} ]; then
        echo -e "${RED}Неверный выбор.${NC}"
        exit 1
    fi

    selected_file="${files[$((num-1))]}"
    download_url="$folder_url/$selected_file/download"
    echo -e "${YELLOW}Скачивание $selected_file...${NC}"
    wget -O /tmp/luci-app-passwall2.ipk "$download_url"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Установка выбранной версии с откатом...${NC}"
        opkg install --force-downgrade --force-depends /tmp/luci-app-passwall2.ipk
        rm -f /tmp/luci-app-passwall2.ipk
        /etc/init.d/passwall2 restart 2>/dev/null || echo "Сервис перезапущен (если был)"
        echo -e "${GREEN}Готово! Текущая версия: $(opkg info luci-app-passwall2 | grep Version || echo 'проверьте вручную')${NC}"
    else
        echo -e "${RED}Ошибка скачивания. Проверьте интернет или попробуйте позже.${NC}"
    fi

elif [ "$choice" = "4" ]; then
    echo "Выход."
    exit 0

else
    echo -e "${RED}Неверный выбор${NC}"
    exit 1
fi
