#!/bin/bash

# Bash script to start windows host as Virtual Machine under Ubuntu (installed or livecd).
# Copyright (C) 2017 Alexandre CABROL PERALES on behalf of Sopra Steria Cybersecurity.

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.



# install virt-manager and kvm
sudo apt-get install -y virt-manager qemu-kvm

#add current user to libvirt group
sudo usermod -a -G libvirt $USER

#set libvirt as current group
newgrp libvirt &


#LOAD VARIABLE FOR LIBVIRT XML FILE

bios_vendor=`sudo dmidecode --string bios-vendor`
bios_version=`sudo dmidecode --string bios-version`
bios_release_date=`sudo dmidecode --string bios-release-date`
bios_revision=`sudo dmidecode |grep -i bios|grep -i revision|sed 's/.*: \(.*\)$/\1/g'`

system_manufacturer=`sudo dmidecode --string system-manufacturer`
system_product_name=`sudo dmidecode --string system-product-name`
system_version=`sudo dmidecode --string system-version`
system_serial_number=`sudo dmidecode --string system-serial-number`
system_uuid=`sudo dmidecode --string system-uuid`
sku=`sudo dmidecode -t 1 |grep -i sku|sed 's/.*: \(.*\)$/\1/g'`
system_family=`sudo dmidecode -t 1 |grep -i family|sed 's/.*: \(.*\)$/\1/g'`

baseboard_manufacturer=`sudo dmidecode --string baseboard-manufacturer`
baseboard_product_name=`sudo dmidecode --string baseboard-product-name`
baseboard_version=`sudo dmidecode --string baseboard-version`
baseboard_serial_number=`sudo dmidecode --string baseboard-serial-number`
baseboard_asset_tag=`sudo dmidecode --string baseboard-asset-tag`

vcpu_number=`grep -c processor /proc/cpuinfo`
cpu_bridge_version=`sudo dmidecode --string processor-version|sed 's/[^-]\+-.\(.\).*/\1/'`
flags=`lscpu |grep Flags|sed 's/Flags:\s\+//'`

total_memory=`free -m |grep Mem|sed 's/Mem:\s\+\([0-9]\+\).*/\1/'`
half_memory=`expr $total_memory / 2`



#START LIBVIRT XML FILE WRITING
printf "<domain type='kvm'>\n\
  <name>host-windows</name>\n\
  <memory unit='MiB'>$half_memory</memory>\n\
  <currentMemory unit='MiB'>$half_memory</currentMemory>\n\
  <vcpu placement='static'>$vcpu_number</vcpu>\n\
  <sysinfo type='smbios'>\n\
    <bios>\n\
      <entry name='vendor'>$bios_vendor</entry>\n\
      <entry name='version'>$bios_version</entry>\n\
      <entry name='date'>$bios_release_date</entry>\n\
      <entry name='release'>$bios_revision</entry>\n\
    </bios>\n\
    <system>\n\
      <entry name='manufacturer'>$system_manufacturer</entry>\n\
      <entry name='product'>$system_product_name</entry>\n\
      <entry name='version'>$system_version</entry>\n\
      <entry name='serial'>$system_serial_number</entry>\n\
      <entry name='uuid'>$system_uuid</entry>\n\
      <entry name='sku'>$sku</entry>\n\
      <entry name='family'>$system_family</entry>\n\
    </system>\n\
  <baseBoard>\n\
    <entry name='manufacturer'>$baseboard_manufacturer</entry>\n\
    <entry name='product'>$baseboard_product_name</entry>\n\
    <entry name='version'>$baseboard_version</entry>\n\
    <entry name='serial'>$baseboard_serial_number</entry>\n\
    <entry name='asset'>$baseboard_asset_tag</entry>\n\
  </baseBoard>\n\
  </sysinfo>\n\
  <os>\n\
    <type arch='x86_64' machine='pc'>hvm</type>\n\
    <boot dev='hd'/>\n\
    <smbios mode='sysinfo'/>\n\
  </os>\n\
  <features>\n\
    <acpi/>\n\
  </features>\n">host-windows.xml

#DISABLED TOO MANY FLAGS UNSUPPORTED FROM HOST CPU
#THIS SETUP COULD BE MANDATORY IF YOU MOVE YOUR VM AFTERWARD ON DIFFERENT HARDWARE
#printf "  <cpu mode='custom' match='exact'>\n">>host-windows.xml

#if [ "$cpu_bridge_version" == "2" ]; then
#  printf "    <model fallback='allow'>SandyBridge</model>\n">>host-windows.xml
#else
#  printf "    <model fallback='allow'>IvyBridge</model>\n">>host-windows.xml
#fi

#printf "    <vendor>Intel</vendor>\n">>host-windows.xml

#for  flag in $flags
#do 
#printf "<feature policy='require' name='$flag'/>\n">>host-windows.xml
#done

 # printf "</cpu>\n\

# USE HARDWARE CPU SETUP INSTEAD OF SETUP
printf "  <cpu mode='host-model'>\n\
    <model fallback='allow'/>\n\
  </cpu>\n">>host-windows.xml

# FINISH THE LIBVIRT XML FILE
printf "  <clock offset='utc'/>\n\
  <on_poweroff>destroy</on_poweroff>\n\
  <on_reboot>restart</on_reboot>\n\
  <on_crash>restart</on_crash>\n\
  <devices>\n\
    <emulator>/usr/bin/kvm-spice</emulator>\n\
    <disk type='block' device='disk'>\n\
      <driver name='qemu' type='raw'/>\n\
      <source dev='/dev/sda'/>\n\
      <target dev='sda' bus='sata'/>\n\
      <address type='drive' controller='0' bus='0' target='0' unit='0'/>\n\
    </disk>\n\
    <controller type='sata' index='0'>\n\
      <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>\n\
    </controller>\n\
    <controller type='pci' index='0' model='pci-root'/>\n\
    <controller type='usb' index='0'>\n\
      <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x2'/>\n\
    </controller>\n\
    <interface type='network'>\n\
      <mac address='52:54:00:0e:8c:ab'/>\n\
      <source network='default'/>\n\
      <model type='rtl8139'/>\n\
      <address type='pci' domain='0x0000' bus='0x00' slot='0x06' function='0x0'/>\n\
    </interface>\n\
    <input type='mouse' bus='ps2'/>\n\
    <input type='keyboard' bus='ps2'/>\n\
    <graphics type='vnc' port='-1' autoport='yes' listen='0.0.0.0'>\n\
      <listen type='address' address='0.0.0.0'/>\n\
    </graphics>\n\
    <graphics type='spice' autoport='yes' listen='0.0.0.0'>\n\
      <listen type='address' address='0.0.0.0'/>\n\
    </graphics>\n\
    <video>\n\
      <model type='qxl' ram='65536' vram='65536' heads='1'/>\n\
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0'/>\n\
    </video>\n\
    <memballoon model='virtio'>\n\
      <address type='pci' domain='0x0000' bus='0x00' slot='0x04' function='0x0'/>\n\
    </memballoon>\n\
  <tpm model='tpm-tis'>\n\
    <backend type='passthrough'>\n\
      <device path='/dev/tpm0'/>\n\
    </backend>\n\
  </tpm>\n\
  </devices>\n\
</domain>">>host-windows.xml

# undefine former host windows vm
virsh undefine host-windows

#define new vm host
virsh define host-windows.xml

echo "WARNING IF YOU HAVE DUAL BOOT ON YOUR COMPUTER CHOOSE WINDOWS FAST ON VM BOOT"
virt-manager



