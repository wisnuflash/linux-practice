# Attach Pass Through Disk
## Identify Disk
Before adding a physical disk to host make note of vendor, serial so that you'll know which disk to share in /dev/disk/by-id/

lshw
lshw is not installed by default on Proxmox VE (see lsblk for that below), you can install it by executing apt install lshw

```python
lshw -class disk -class storage

```
```python
**...
           *-disk
                description: ATA Disk
                product: ST3000DM001-1CH1
                vendor: Seagate
                physical id: 0.0.0
                bus info: scsi@3:0.0.0
                logical name: /dev/sda
                version: CC27
                serial: Z1F41BLC
                size: 2794GiB (3TB)
                configuration: ansiversion=5 sectorsize=4096
...
**
```

Note that device names like /dev/sdc should never be used, as this can change between reboots. Use the stable /dev/disk/by-id paths instead. Check by listing all of that directory then look for the disk added by matching serial number from lshw and the physical disk:

```python
ls -l /dev/disk/by-id/ata-ST3000DM001-1CH166_Z1F41BLC
```
lrwxrwxrwx 1 root root 9 Jan 21 10:10 /dev/disk/by-id/ata-ST3000DM001-1CH166_Z1F41BLC -> ../../sda
or try

```python
ls -l /dev/disk/by-id | grep Z1F41BLC
```
List disk by-id with lsblk
The lsblk is pre-installed, you can print and map the serial and WWN identifiers of attached disks using the following two commands:

lsblk -o +MODEL,SERIAL,WWN
ls -l /dev/disk/by-id/
You can also use an extended one liner to get the path directly:

lsblk |awk 'NR==1{print $0" DEVICE-ID(S)"}NR>1{dev=$1;printf $0" ";system("find /dev/disk/by-id -lname \"*"dev"\" -printf \" %p\"");print "";}'|grep -v -E 'part|lvm'

NAME                         MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT DEVICE-ID(S)
sda                            8:0    0   7.3T  0 disk   /dev/disk/by-id/wwn-0x5000c500c35cd719 /dev/disk/by-id/ata-ST8000DM004-2CX188_ZCT1DNY1
sdb                            8:16   1    29G  0 disk   /dev/disk/by-id/usb-Generic_STORAGE_DEVICE-0:0
sdc                            8:32   0 931.5G  0 disk   /dev/disk/by-id/usb-JMicron_Generic_0123456789ABCDEF-0:0
sdd                            8:48   0   1.8T  0 disk   /dev/disk/by-id/wwn-0x5000c500661eeebd /dev/disk/by-id/ata-ST2000DX001-1CM164_Z1E783H2

make-lsblk-list-devices-by-id

Short List
find /dev/disk/by-id/ -type l|xargs -I{} ls -l {}|grep -v -E '[0-9]$' |sort -k11|cut -d' ' -f9,10,11,12
/dev/disk/by-id/ata-ST8000DM004-2CX188_ZCT1DNY1 -> ../../sda
/dev/disk/by-id/wwn-0x5000c500c35cd719 -> ../../sda
/dev/disk/by-id/usb-Generic_STORAGE_DEVICE-0:0 -> ../../sdb
/dev/disk/by-id/usb-JMicron_Generic_0123456789ABCDEF-0:0 -> ../../sdc
/dev/disk/by-id/ata-ST2000DX001-1CM164_Z1E783H2 -> ../../sdd
/dev/disk/by-id/wwn-0x5000c500661eeebd -> ../../sdd

## Update Configuration
### Hot-Plug/Add physical device as new virtual SCSI disk

```python
qm set 592 -scsi2 /dev/disk/by-id/ata-ST3000DM001-1CH166_Z1F41BLC
```
update VM 592: -scsi2 /dev/disk/by-id/ata-ST3000DM001-1CH166_Z1F41BLC


### Hot-Unplug/Remove virtual disk
```python
qm unlink 592 --idlist scsi2
```
update VM 592: -delete scsi2
### Check Configuration File
```python
grep Z1F41BLC /etc/pve/qemu-server/592.conf
```
scsi2: /dev/disk/by-id/ata-ST3000DM001-1CH166_Z1F41BLC,size=2930266584K