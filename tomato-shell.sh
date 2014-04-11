#########################################################################
# File Name: route.sh
# Author: Kim Kong
# mail: kongqingzhang@gmail.com
# Created Time:    1/12 10:51:14 2014
#########################################################################
#!/bin/sh
sleep 20
wan1_if=ppp0
wan1_ip=$(ifconfig ppp0 | grep "inet addr" | cut -d":" -f2 | cut -d" " -f1)
wan1_gw=$(ifconfig ppp0 | grep "inet addr" | cut -d":" -f3 | cut -d" " -f1)
wan2_if=ppp1
wan2_ip=$(ifconfig ppp1 | grep "inet addr" | cut -d":" -f2 | cut -d" " -f1)
wan2_gw=$(ifconfig ppp1 | grep "inet addr" | cut -d":" -f3 | cut -d" " -f1)
wan3_if=ppp2
wan3_ip=$(ifconfig ppp2 | grep "inet addr" | cut -d":" -f2 | cut -d" " -f1)
wan3_gw=$(ifconfig ppp2 | grep "inet addr" | cut -d":" -f3 | cut -d" " -f1)

echo "Wan1 IP:$wan1_ip"
echo "Wan1 Gateway:$wan1_gw"
echo "Wan2 IP:$wan2_ip"
echo "Wan2 Gateway:$wan2_gw"
echo "Wan3 IP:$wan3_ip"
echo "Wan3 Gateway:$wan3_gw"

echo "Set adv routing..."



ip rule add lookup main prio 32766
ip rule add lookup default prio 32767
ip rule add from $wan1_ip table 1 prio 50 
ip rule add fwmark 0x100 table 1 prio 51
ip rule add from $wan2_ip table 2 prio 100 
ip rule add fwmark 0x200 table 2 prio 101
ip rule add from $wan3_ip table 3 prio 150
ip rule add fwmark 0x300 table 3 prio 151



echo "Set PREROUTING..."

iptables -t mangle -F PREROUTING

iptables -t mangle -A PREROUTING -i $wan1_if -m state --state NEW -j CONNMARK --set-mark 0x100

iptables -t mangle -A PREROUTING -i $wan2_if -m state --state NEW -j CONNMARK --set-mark 0x200

iptables -t mangle -A PREROUTING -i $wan3_if -m state --state NEW -j CONNMARK --set-mark 0x300

iptables -t mangle -A PREROUTING -i br0 -m state --state RELATED,ESTABLISHED -j CONNMARK --restore-mark

echo "Set POSTROUTING..."

iptables -t mangle -F POSTROUTING

iptables -t mangle -A POSTROUTING -o $wan1_if -m state --state NEW -j CONNMARK --set-mark 0x100

iptables -t mangle -A POSTROUTING -o $wan2_if -m state --state NEW -j CONNMARK --set-mark 0x200

iptables -t mangle -A POSTROUTING -o $wan3_if -m state --state NEW -j CONNMARK --set-mark 0x300


#iptables -t mangle -A POSTROUTING -p udp --dport 53 -j CONNMARK --set-mark 0x100
#iptables -t mangle -A POSTROUTING -p udp --dport 8000 -j CONNMARK --set-mark 0x100
#iptables -t mangle -A POSTROUTING -p udp --dport 9001 -j CONNMARK --set-mark 0x100
#iptables -t mangle -A POSTROUTING -p udp --dport 4000 -j CONNMARK --set-mark 0x100
#iptables -t mangle -A POSTROUTING -p tcp --dport 16000 -j MARK --set-mark 0x100
#iptables -t mangle -A POSTROUTING -p tcp --dport 80 -j MARK --set-mark 0x100
#iptables -t mangle -A POSTROUTING -p tcp --dport 22 -j MARK --set-mark 0x100
iptables -t mangle -A PREROUTING -p tcp -m multiport --dports 80,8080,20,21,16000,22 -s 192.168.1.0/24 -j MARK --set-mark 0x100
iptables -t mangle -A PREROUTING -p udp -m multiport --dports 53,4000,8000,9001 -s 192.168.1.0/24 -j MARK --set-mark 0x100
iptables -t mangle -A PREROUTING -p icmp -j MARK --set-mark 0x100
iptables -t mangle -A PREROUTING -p icmp -s 192.168.1.0/24 -j MARK --set-mark 0x100

echo "Set Nat..."

echo "Set default gateway..."
#ip route add default scope global equalize nexthop via $wan1_gw dev ppp0 weight 1 nexthop via $wan2_gw dev ppp1 weight 1 nexthop via $wan3_gw dev ppp2 weight 1

echo "finished."

