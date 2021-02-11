#!/bin/bash
#l2i (Wegare)
clear
host2="$(cat /root/akun/l2i.txt | tr '\n' ' '  | awk '{print $1}')" 
user2="$(cat /root/akun/l2i.txt | tr '\n' ' '  | awk '{print $2}')" 
pass2="$(cat /root/akun/l2i.txt | tr '\n' ' '  | awk '{print $3}')" 
psk2="$(cat /root/akun/l2i.txt | tr '\n' ' '  | awk '{print $4}')" 
echo "Inject l2tp/ipsec by wegare"
echo "1. Sett Profile"
echo "2. Start Inject"
echo "3. Stop Inject"
echo "4. Enable auto booting & auto rekonek"
echo "5. Disable auto booting & auto rekonek"
echo "e. exit"
read -p "(default tools: 2) : " tools
[ -z "${tools}" ] && tools="2"
if [ "$tools" = "1" ]; then

echo "Masukkan bug.com.host:port" 
read -p "default bug.com.host:port: $host2 : " host
[ -z "${host}" ] && host="$host2"

echo "Masukkan username" 
read -p "default username: $user2 : " user
[ -z "${user}" ] && user="$user2"

echo "Masukkan password" 
read -p "default password: $pass2 : " pass
[ -z "${pass}" ] && pass="$pass2"

echo "Masukkan IPsec PSK" 
read -p "default IPsec PSK: $psk2 : " psk
[ -z "${psk}" ] && psk="$psk2"

cat << EOF > /etc/ipsec.conf
config setup

conn %default
    ikelifetime=60m
    keylife=20m
    rekeymargin=3m
    keyingtries=1
    keyexchange=ikev1
    authby=secret
    ike=aes128-sha1-modp1024,3des-sha1-modp1024!
    esp=aes128-sha1-modp1024,3des-sha1-modp1024!

conn L2TP-PSK
    keyexchange=ikev1
    left=%defaultroute
    auto=add
    authby=secret
    type=transport
    leftprotoport=17/1701
    rightprotoport=17/1701
    right=$host
EOF

cat << EOF > /etc/ipsec.secrets
: PSK ""$psk""
EOF

cat << EOF > /etc/xl2tpd/xl2tpd.conf
[lac myVPN]
lns = $host
ppp debug = yes
pppoptfile = /etc/ppp/options.l2tpd.client
length bit = yes
EOF

cat << EOF > /etc/ppp/options.l2tpd.client
ipcp-accept-local
ipcp-accept-remote
refuse-eap
require-mschap-v2
noccp
noauth
logfile /var/log/xl2tpd.log
idle 1800
mtu 1410
mru 1410
defaultroute
usepeerdns
debug
connect-delay 5000
name $user
password $pass
EOF

echo "$host
$user
$pass
$psk" > /root/akun/l2i.txt
echo "Sett Profile Sukses"
sleep 2
clear
/usr/bin/l2i
elif [ "${tools}" = "2" ]; then
ipmodem="$(route -n | grep -i 0.0.0.0 | head -n1 | awk '{print $2}')" 
echo "ipmodem=$ipmodem" > /root/akun/ipmodem.txt
host="$(cat /root/akun/l2i.txt | tr '\n' ' '  | awk '{print $1}')" 
route="$(cat /root/akun/ipmodem.txt | grep -i ipmodem | cut -d= -f2 | tail -n1)"
sleep 1
/etc/init.d/ipsec start 2>/dev/null
/etc/init.d/xl2tpd start 2>/dev/null
mkdir -p /var/run/xl2tpd
touch /var/run/xl2tpd/l2tp-control
echo "c myVPN" > /var/run/xl2tpd/l2tp-control
ipsec up L2TP-PSK &
sleep 10
route add $host gw $route metric 0 2>/dev/null
pp="$(route -n | grep ppp | head -n1 | awk '{print $8}')" 
inet="$(ip r | grep $pp | head -n1 | awk '{print $9}')" 
route add default gw $inet metric 0 2>/dev/null
iptables -A POSTROUTING --proto tcp -t nat -o $pp -j MASQUERADE 2>/dev/null
sleep 1
fping -l google.com > /dev/null 2>&1 &
elif [ "${tools}" = "3" ]; then
mkdir -p /var/run/xl2tpd
touch /var/run/xl2tpd/l2tp-control
echo "d myVPN" > /var/run/xl2tpd/l2tp-control
ipsec down L2TP-PSK &
/etc/init.d/ipsec stop 2>/dev/null
/etc/init.d/xl2tpd stop 2>/dev/null
host="$(cat /root/akun/l2i.txt | tr '\n' ' '  | awk '{print $1}')" 
route="$(cat /root/akun/ipmodem.txt | grep -i ipmodem | cut -d= -f2 | tail -n1)" 
bles="$(iptables -t nat -v -L POSTROUTING -n --line-number | grep ppp | head -n1 | awk '{print $1}')" 
killall -q l2i fping charon
route del "$host" gw "$route" metric 0 2>/dev/null
iptables -t nat -D POSTROUTING $bles 2>/dev/null
killall dnsmasq 
/etc/init.d/dnsmasq start > /dev/null
sleep 2
echo "Stop Suksess"
sleep 2
clear
/usr/bin/l2i
elif [ "${tools}" = "4" ]; then
cat <<EOF>> /etc/crontabs/root

# BEGIN AUTOREKONEKL2I
*/1 * * * *  autorekonek-l2i
# END AUTOREKONEKL2I
EOF
sed -i '/^$/d' /etc/crontabs/root 2>/dev/null
/etc/init.d/cron restart
echo "Enable Suksess"
sleep 2
clear
/usr/bin/l2i
elif [ "${tools}" = "5" ]; then
sed -i "/^# BEGIN AUTOREKONEKL2I/,/^# END AUTOREKONEKL2I/d" /etc/crontabs/root > /dev/null
/etc/init.d/cron restart
echo "Disable Suksess"
sleep 2
clear
/usr/bin/l2i
elif [ "${tools}" = "e" ]; then
clear
exit
else 
echo -e "$tools: invalid selection."
exit
fi