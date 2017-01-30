#!/bin/bash

# Bash script to attach an usb device to a VM.
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


if [ $# -lt 2 ]
  then
    echo "$0 vm_name usb_device_keyword"
   echo "############"
    echo "USB DEVICE LIST"
    lsusb
   echo "#####"
   echo "VM LIST"
   virsh list --all
    exit 1
fi


USBDEV=($(lsusb|grep $2|sed 's/[^ ]\+ \+[^ ]\+ \+[^ ]\+ \+[^ ]\+ \+[^ ]\+ \+\([^ ]\+\) .*/\1/'|tr ":" "\n"))
echo $USBDEV
echo "<hostdev mode='subsystem' type='usb'>" > /tmp/usb_${USBDEV[0]}-${USBDEV[1]}.xml
echo "  <source>" >> /tmp/usb_${USBDEV[0]}-${USBDEV[1]}.xml
echo "    <vendor id='0x${USBDEV[0]}'/>" >> /tmp/usb_${USBDEV[0]}-${USBDEV[1]}.xml
echo "    <product id='0x${USBDEV[1]}'/>" >> /tmp/usb_${USBDEV[0]}-${USBDEV[1]}.xml
echo "  </source>" >> /tmp/usb_${USBDEV[0]}-${USBDEV[1]}.xml
echo "</hostdev>" >> /tmp/usb_${USBDEV[0]}-${USBDEV[1]}.xml
ls /tmp/usb_${USBDEV[0]}-${USBDEV[1]}.xml
virsh attach-device $1 /tmp/usb_${USBDEV[0]}-${USBDEV[1]}.xml

