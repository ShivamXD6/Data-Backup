#!/system/bin/sh
# Setup Environment (Variables & Functions)
TMPDIR="$(mktemp -d 2>/dev/null)" || TMPDIR="/dev/tmp"
chmod 700 "$TMPDIR"
[ -z "$MODPATH" ] && MODPATH="${0%/*}"
ADBDIR="/data/adb"
export TMPLOC="/data/local/tmp"
rm -rf "$TMPLOC" && mkdir -p "$TMPLOC"
SDDIR=$(realpath "/sdcard")
EXTSD=$(find /storage -mindepth 1 -maxdepth 1 -type d 2>/dev/null | grep -Ev '/(emulated|self)' | grep -E '/[0-9A-Z]{4,}-[0-9A-Z]{4,}$' | head -n 1)
MODDIR="$ADBDIR/modules"
ARCH=$(getprop ro.product.cpu.abi)
PORYGONZ="$MODPATH/porygonz"
ZAPDOS="$MODPATH/zapdos"
chmod +x "$PORYGONZ" "$ZAPDOS"

# Only 64-Bit Supported
echo "$ARCH" | grep -qE 'arm64-v8a' || {
  DEKH "🧨 This module requires a 64-bit environment. Exiting..."
  exit 1
}

# Display UI
DEKH() {
  orgsandesh="$1"; samay="${2}"; prakar="${3}"
  [[ "$2" == h* ]] && prakar="${2}" && samay="${3}"
  [[ "$prakar" == h* ]] && {
    echo "$orgsandesh" | grep -q '[^ -~]' && sandesh=" $orgsandesh" || sandesh=" $orgsandesh "
  rekha=$(printf "%s\n" "$sandesh" | awk '{ print length }' | sort -nr | head -n1)
  [ "$rekha" -gt 50 ] && rekha=50
  akshar=(= - ~ '*' + '<' '>')
    shabd="${prakar#h}"; [ -z "$shabd" ] && shabd="${akshar[RANDOM % ${#akshar[@]}]}"
    echo; printf '%*s\n' "$rekha" '' | tr ' ' "$shabd"
    echo -e "$sandesh"
    printf '%*s\n' "$rekha" '' | tr ' ' "$shabd"
  } || echo -e "$orgsandesh"
  [ -n "$samay" ] && sleep "$samay"
  return 0
}

# Read Files
PADH() {
  value=$(grep -m 1 "^$1=" "$2" | sed 's/^.*=//')
  echo "${value//[[:space:]]/ }"
}

# Check for volume key
CHECK_KEY() {
  while true; do
    down_event=$(getevent -qlc 1 | grep "DOWN" | grep "KEY_" | awk '{print $3}')
    case "$down_event" in
      KEY_*) ;;
      *) continue ;;
    esac
    [ -n "$down_event" ] || continue
    t1=$(date +%s%3N)
    while true; do
      up_event=$(getevent -qlc 1 | grep "UP" | grep "KEY_" | awk '{print $3}')
      [ "$up_event" = "$down_event" ] && break
      sleep 0.1
    done
    t2=$(date +%s%3N)
    duration=$((t2 - t1))
    echo "$down_event:$duration"
    break
  done
}

# Handle Options Based on Key Pressed/Hold
OPT() {
  mode="$1"
  while true; do
    keyinfo=$(CHECK_KEY)
    key="${keyinfo%%:*}"; [ -z "$key" ] && continue
    dur="${keyinfo##*:}"
    case $key in
      KEY_VOLUMEUP) [ "$mode" = "h" ] && [ "$dur" -ge 750 ] && return 10 || return 0 ;;
      KEY_VOLUMEDOWN) [ "$mode" = "h" ] && [ "$dur" -ge 750 ] && return 11 || return 1 ;;
      KEY_POWER) [ "$mode" = "h" ] && [ "$dur" -ge 750 ] && return 12 || input keyevent KEYCODE_WAKEUP && return 2;;
      *) DEKH "❌ Invalid Input! Key: $key ($dur ms)" "hx" ;;
    esac
    break
  done
}

# Add Strings in Registry
ADDSTR() {
  [ -f "$2" ] && { echo "$1" >> "$2"; sort -u "$2" -o "$2"; } ||
  eval "$2=\${$2:+\${$2}\$'\n'}\$1"
}

# Replace Symbols with Spaces or Spaces with Underspace
SANITIZE() {
  local str="$1"; shift
  if [ "$1" = "1" ]; then
    echo "$str" | sed 's/[^a-zA-Z0-9]/_/g'
  else
    echo "$str" | sed 's/[[:punct:]]/ /g'
  fi
}

# Get Sizes
GETSIZE() {
  case "$1" in
    *[!0-9]*) du -sk "$@" 2>/dev/null | awk '{s+=$1} END{print s}' ;;
    *) n="$1"
      awk -v n="$n" 'BEGIN{
        if(n>=1024*1024) printf "%.2f GB\n", n/1024/1024;
        else if(n>=1024) printf "%.2f MB\n", n/1024;
        else printf "%.2f KB\n", n;
      }' ;;
  esac
}

# Check for file is an app
IS_PKG() {
  case "$1" in
    *.*) return 0 ;;
    *) return 1 ;;
  esac
}

# Check if an app is installed or not
PKG_INSTALLED() {
  IS_PKG "$1" || return 1
  pm list packages | grep -q "^package:$1$" || return 1
  [ -z "$2" ] && return 0
  apkpath="$(pm path "$1" | sed -n 's/^package://p' | head -1)"
  [ -z "$apkpath" ] && return 1
  info="$("$PORYGONZ" dump badging "$apkpath" 2>/dev/null)" || return 1
  ver="$(echo "$info" | grep -m1 "package: name=" | cut -d"'" -f6)"
  [ "$ver" = "$2" ] || return 1
}

# Change Android ID
CHANID() {
  sed -i "/package=\"$1\"/s/\(value=\"\)[^\"]*\(.*defaultValue=\"\)[^\"]*/\1$2\2$2/" "/data/system/users/0/settings_ssaid.xml"
}

# Set Permissions for an app
SETPERM() {
  PKG="$1"
  FILE="$2"
  while IFS= read -r perm; do
    case "$perm" in
      appops:*)
        op="${perm#appops:}"
        appops set "$PKG" "$op" allow 2>/dev/null &
        ;;
      android.permission.*)
        pm grant "$PKG" "$perm" 2>/dev/null &
        ;;
    esac
  done < "$FILE"
}

# Process strings or files list safely with spaces
PRSMOD() {
  in="$1"; fn="$2"; TMPFILE="$TMPLOC/tmp_list.txt"
  [ -f "$in" ] && [ "${in##*.}" = "txt" ] && cp -f "$in" "$TMPFILE" || printf "%s\n" "$in" > "$TMPFILE"
  while IFS= read -r l || [ -n "$l" ]; do
    [ -z "$l" ] || "$fn" "$l"
    [ "$Key" = 2 ] || [ "$Key" = 12 ] && break
  done < "$TMPFILE"
}

# Wait for processes to complete
COOLDOWN() {
  while [ "$(pgrep -c tar)" -ge "$1" ]; do
    sleep 1
  done
}

# Unbundle Apps and It's directories
UNBUNDAPP() {
  FILE="$1"; DEST="$2"
  [ -f "$FILE" ] || return
  COOLDOWN "$JOBS"
  "$ZAPDOS" -d -q -c "$FILE" | tar -xf - -C "$DEST" &
}

# Fixes Per PKG Ownerships
FIXOWN() {
  ADGID=$(stat -c '%g' "/data/media/0/Android/data")
  AMGID=$(stat -c '%g' "/data/media/0/Android/media")
  AOGID=$(stat -c '%g' "/data/media/0/Android/obb")
  while IFS='|' read -r PKG UID CUID; do
    [ -d "/data/data/$PKG" ] && chown -R "$UID:$UID" "/data/data/$PKG"
    [ -d "/data/user_de/0/$PKG" ] && chown -R "$UID:$UID" "/data/user_de/0/$PKG"
    [ -d "/data/media/0/Android/data/$PKG" ] && chown -R "$UID:$ADGID" "/data/media/0/Android/data/$PKG"
    [ -d "/data/media/0/Android/media/$PKG" ] && chown -R "$UID:$AMGID" "/data/media/0/Android/media/$PKG"
    [ -d "/data/media/0/Android/obb/$PKG" ] && chown -R "$UID:$AOGID" "/data/media/0/Android/obb/$PKG"
    pm enable "$PKG" > /dev/null 2>&1
  done < "$TMPLOC/.ownerships"
  rm -f "$TMPLOC/.ownerships"
}

# Restore Apps
RSTAPP() {
  PKG="$1"
  APP="$2"
  DEKH "🔁 Restoring: $label" 0.2 "'h"
  "$ZAPDOS" -d -q -c "$APP/APP.bundle.pack" | tar -xf - -C "$TMPLOC"
  andid="$(PADH SSAID "$APP/Meta.txt")"
  oldsize="$(PADH Size "$APP/Meta.txt")"
  if ! PKG_INSTALLED "$PKG" "$ver"; then
    apks=$(find "$TMPLOC/$PKG" -name "*.apk" | sort)
    [ ! -f "$APP/Permissions.txt" ] && all="-g"
    pm install $all --dexopt-compiler-filter skip $apks > /dev/null 2>&1 || return 1
    pm disable "$PKG" > /dev/null 2>&1 || return 1
    pm compile "$PKG" > /dev/null 2>&1 &
  else
    DEKH "⏭️ Skipping App (unchanged)"
  fi
   IFS='|' read -r oasize odsize oesize omsize oosize <<< "$oldsize"
   dsize="$(GETSIZE "/data/data/$pkg")"; esize="$(GETSIZE "/data/media/0/Android/data/$pkg")"; msize="$(GETSIZE "/data/media/0/Android/media/$pkg")"; osize="$(GETSIZE "/data/media/0/Android/obb/$pkg")"
  UID=$(stat -c '%u' "/data/data/$PKG")
  [ -f "$APP/Data.bundle.pack" ] && { [ "$dsize" != "$odsize" ] && UNBUNDAPP "$APP/Data.bundle.pack" "/data/data" && UNBUNDAPP "$APP/UserDe.bundle.pack" "/data/user_de/0" || DEKH "⏭️ Skipping Data (unchanged)"; }
  [ -f "$APP/ExtData.bundle.pack" ] && { [ "$esize" != "$oesize" ] && UNBUNDAPP "$APP/ExtData.bundle.pack" "/data/media/0/Android/data" || DEKH "⏭️ Skipping External Data (unchanged)"; }
  [ -f "$APP/Media.bundle.pack" ] && { [ "$msize" != "$omsize" ] && UNBUNDAPP "$APP/Media.bundle.pack" "/data/media/0/Android/media" || DEKH "⏭️ Skipping Media (unchanged)"; }
  [ -f "$APP/Obb.bundle.pack" ] && { [ "$osize" != "$oosize" ] && UNBUNDAPP "$APP/Obb.bundle.pack" "/data/media/0/Android/obb" || DEKH "⏭️ Skipping OBB (unchanged)"; }
   cp -af "$APP/Meta.txt" "$APP/Permissions.txt" "$TMPLOC/$PKG"
  [ -n "$andid" ] && CHANID "$PKG" "$andid"
  [ -f "$APP/Permissions.txt" ] && SETPERM "$PKG" "$TMPLOC/$PKG/Permissions.txt"
  echo "$PKG|$UID" >> "$TMPLOC/.ownerships"
  DEKH "✅ Restore complete for: $label"
}

# Fetch and Display All Apps
FETCHAPPS() {
  mcnt=1
  UAPPSLIST="$(find "$PKGAPPS" -type d -mindepth 1 -maxdepth 1)"
  [ -z "$UAPPSLIST" ] && DEKH "⚠️ No User Apps found to install" && return 0
  FUAPPSLIST=""
  PSSHOWUAPPS() {
    pkg="$(basename "$1")"
    label="$(PADH Name "$1/Meta.txt")"; label=$(SANITIZE "$label")
    ver="$(PADH Version "$1/Meta.txt")"
    sizes="$(PADH Size "$1/Meta.txt")"
    IFS='|' read -r asize dsize esize msize osize <<< "$sizes"
    size=$((asize + dsize + esize + msize + osize))
    ADDSTR "$1:$size:$pkg:$label:$ver" "FUAPPSLIST"
    mcnt=$((mcnt + 1))
  }
  [ -n "$UAPPSLIST" ] && PRSMOD "$UAPPSLIST" "PSSHOWUAPPS"
}

# Install Modules or Apps
INSTALL() {
  mcnt=0
  cd "$TMPLOC"
  PSUAPPS() {
    mcnt=$((mcnt + 1))
    path=$(echo "$1" | cut -d: -f1)
    size=$(echo "$1" | cut -d: -f2)
    pkg=$(echo "$1" | cut -d: -f3)
    label=$(echo "$1" | cut -d: -f4)
    ver=$(echo "$1" | cut -d: -f5-)
    size=$(GETSIZE $size)
    DEKH "📦 [$mcnt] $label📱" "h*"
    DEKH "ℹ️ Version: $ver | Size: $size"
    [ "$INSTYP" = "SELECT" ] && {
      DEKH "🔊 Vol+ = Install App\n🔉 Vol- = Skip App"
      OPT "h"; Key=$?; [ "$Key" -eq 1 ] && return
    }
    RSTAPP "$pkg" "$path" || DEKH "❌ Failed to install $label (v$ver)" "hx" 1
  }
  START=$(date +%s)
  [ -n "$FUAPPSLIST" ] && {
   JOBS=$(( $(nproc) / 2 )); JOBS=${JOBS:-4}
   FUAPPSLIST=$(echo "$FUAPPSLIST" | sort -t: -k2,2nr)
   PRSMOD "$FUAPPSLIST" "PSUAPPS"
  }
  COOLDOWN "1"
  END=$(date +%s)
  DURATION=$((END - START))
  MIN=$((DURATION / 60))
  SEC=$((DURATION % 60))
  DEKH "✅ Installation Complete, Everything is Installed" "h"
  if [ "$MIN" -gt 0 ]; then
    DEKH "⏱️ Took: ${MIN}m ${SEC}s"
  else
    DEKH "⏱️ Took: ${SEC}s"
  fi
  [ -n "$FUAPPSLIST" ] && FIXOWN
}

# Check which Rooting Implementation is running
if [ -d "$ADBDIR/magisk" ] && magisk -V >/dev/null 2>&1 || magisk -v >/dev/null 2>&1; then
  ROOT="Magisk"
  CMD="magisk --install-module"
  if echo "$(magisk magiskhide sulist 2>&1)" | grep -iq "SuList"; then
  ROOT="Kitsune"
  fi
elif [ -d "$ADBDIR/ksu" ] && ksud -V >/dev/null 2>&1 || ksud -v >/dev/null 2>&1; then
  ROOT="KernelSU"
  CMD="ksud module install"
elif [ -d "$ADBDIR/ap" ] && apd -V >/dev/null 2>&1 || apd -v >/dev/null 2>&1; then
  ROOT="APatch"
  CMD="apd module install"
else
  DEKH "🤖?? Cannot determine rooting implementation, if you think it's a mistake, contact @ShastikXD" "hx"
  exit 1
fi

# Start Flashing Module
source "$MODPATH/flash.sh"