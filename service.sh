#!/system/bin/sh
[ -z "$MODPATH" ] && MODPATH="${0%/*}"
MODDIR="/data/adb/modules"

# Remove Bundle-Mods
(
sleep 0.2
rm -rf "$MODPATH" "$MODDIR/bundle-mods"
)&
