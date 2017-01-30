# cybersecurity-virtualize-windows-host
****************************************
Windows Host Virtualizer
****************************************

=============
License
=============

Set of scripts to manage and virtualize windows host as Virtual Machine under Ubuntu (installed or livecd).
Copyright (C) 2017 Alexandre CABROL PERALES on behalf of Sopra Steria Cybersecurity.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.

=============
Description
=============

This set of script have been developped to be able to virtualize a Windows Host and run it opn Ubuntu LiveCD or Dual Boot (installed next to windows).

They help to simulate as close as possible the existing hardware to cheat Windows hardware recognition.

This scripts could be use for Digital Forensic and Reverse Engineering.

=============
Requirements
=============

The reference platform is Ubuntu 16.04 LTS as LiveCD or Dual Boot install.
Internet connection usable with Ubuntu (Wired of Wifi).

=============
Step by step
=============
- Boot on windows, open an administrator session and run [.reg file](kvm-migration-fix.reg) (i'm not sur this step still mandatory)
- Shutdown windows
- Boot on Ubuntu system
- Connect to internet if you don't have kvm and virt-manager already installed
- Assuming windows host hard disk drive is /dev/sda (otherwise replace this value in the script) run the [virtualisation script](setHostWindowsVM.sh)
- wait for virt-manager windows pop
- start windows-host VM (CAREFULL IF YOU HAVE DUAL BOOT YOU MUST SELECT WINDOWS BEFORE AUTO SELECTION!)
- enjoy your new virtual machine


=============
Other information
=============
- You can use virtio driver by installing https://fedoraproject.org/wiki/Windows_Virtio_Drivers#Direct_download into Windows Host.

=============
Todo List
=============
- [ ] Any idea?


`Learn more <https://github.com/soprasteria/cybersecurity-virtualize-windows-host>`_.

