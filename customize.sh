#!/system/bin/sh
# Abort in Recovery 
if ! $BOOTMODE; then
  ui_print " ! You cannot install/bundle modules in Recovery Mode"
  touch $MODPATH/remove
  recovery_cleanup
  rm -rf $NVBASE/modules_update/$MODID $TMPDIR 2>/dev/null
  exit 0
fi

# Initialize Environment
[ -z "$MODPATH" ] && MODPATH="${0%/*}"
chmod +x "$MODPATH/load"
export ZIPFILE
"$MODPATH/load" || exit 1