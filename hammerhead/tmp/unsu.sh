#!/sbin/sh

mkdir /tmp/ramdisk

cp /tmp/boot.img-ramdisk.gz /tmp/ramdisk/

cd /tmp/ramdisk/

gunzip -c /tmp/ramdisk/boot.img-ramdisk.gz | cpio -i

# remove_section <file> <begin search string> <end search string>
remove_section() {
  begin=`grep -n "$2" $1 | head -n1 | cut -d: -f1`;
  for end in `grep -n "$3" $1 | cut -d: -f1`; do
    if [ "$begin" -lt "$end" ]; then
      sed -i "/${2//\//\\/}/,/${3//\//\\/}/d" $1;
      break;
    fi;
  done;
}

remove_section init.rc "service daemonsu" "u:r:su:s0";

cp /tmp/ramdisk/init.rc /sdcard/

chmod 777 /sdcard/init.rc

if [ -f /tmp/ramdisk/sbin/su ]; then
	rm /tmp/ramdisk/sbin/su
fi

rm /tmp/ramdisk/boot.img-ramdisk.gz

rm /tmp/boot.img-ramdisk.gz

find . | cpio -o -H newc | gzip > /tmp/boot.img-ramdisk.gz

rm -r /system/app/Superuser

echo \#!/sbin/sh > /tmp/createnewboot.sh
echo /tmp/mkbootimg --kernel /tmp/boot.img-zImage --ramdisk /tmp/boot.img-ramdisk.gz --cmdline \"$(cat /tmp/boot.img-cmdline)\" --base 0x$(cat /tmp/boot.img-base) --pagesize $(cat /tmp/boot.img-pagesize) --ramdisk_offset 0x$(cat /tmp/boot.img-ramdiskoff) --tags_offset 0x$(cat /tmp/boot.img-tagsoff) --output /tmp/newboot.img >> /tmp/createnewboot.sh
chmod 777 /tmp/createnewboot.sh
/tmp/createnewboot.sh
return $?