#!/system/bin/sh
# Setup Environment (Variables & Functions)
TMPDIR="$(mktemp -d 2>/dev/null)" || TMPDIR="/dev/tmp"
chmod 700 "$TMPDIR"
[ -z "$MODPATH" ] && MODPATH="${0%/*}"
ADBDIR="/data/adb"
export TMPLOC="/data/local/tmp"
rm -rf "$TMPLOC" && mkdir -p "$TMPLOC"
SDDIR=$(realpath "/sdcard")
EXTSD=$(find /storage -mindepth 1 -maxdepth 1 -type d 2>/dev/null | grep -Ev '/(emulated|self)' | grep -E '/[0-9A-Z]{4,}[0-9A-Z]{4,}$' | head -n 1)
MODDIR="$ADBDIR/modules"
DOWNDIR="$SDDIR/Download"
SELDIR="$DOWNDIR/Delete_To_Backup"
SELFLD="$(basename $SELDIR)"
ARCH=$(getprop ro.product.cpu.abi)
JOBS=$(nproc); JOBS=${JOBS:-4}
PORYGONZ="$MODPATH/porygonz"
ZAPDOS="$MODPATH/zapdos"
ACNT=0
OLDIFS=$IFS
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

# Remove Strings from Registry
DELSTR() {
  [ -f "$2" ] && awk -v str="$1" '$0 != str' "$2" > "$2.tmp" && mv "$2.tmp" "$2" ||
  eval "$2=\$(printf '%s\n' \"\${$2}\" | grep -Fxv -- \"\$1\")"
}

# Sort Strings from Registry
SORTSTR() {
  [ -f "$1" ] && sort -t: -k"${2:-1}" -n -r "$1" -o "$1"
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
  info="$("$PORYGONZ" dump badging "$apkpath" 2>/dev/null)"
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
  while [ "$(jobs -p | wc -l)" -ge "$1" ]; do
    sleep 0.1
  done
}

# Open File Manager
OFM () {
  am start -a android.intent.action.VIEW -d content://com.android.externalstorage.documents/document/primary:Download%2F$1 >/dev/null 2>&1
}

# Close File Manager
CFM () {
  am force-stop com.android.documentsui >/dev/null 2>&1
  am force-stop com.google.android.documentsui >/dev/null 2>&1
}

# Select/Detect deletion of User Apps and it's components
SELECTAPPS() {
  PREV_LIST="$(mktemp)"
  CURR_LIST="$(mktemp)"
  find "$SELDIR" -type f -o -type d 2>/dev/null | sort > "$PREV_LIST"
  OFM "$SELFLD"
  SELECTED="$TMPLOC/selected.txt"; > "$TMPLOC/selected.txt"
  reset=""
  (OPT; > "$SELDIR/SELDONE") &
  while [ ! -f "$SELDIR/SELDONE" ]; do
    sleep 1
    find "$SELDIR" -type f -o -type d 2>/dev/null | sort > "$CURR_LIST"
    IFS=$'\n'
    for deleted in $(comm -23 "$PREV_LIST" "$CURR_LIST"); do
      basename="$(basename "$deleted")"
      case "$basename" in \#*) continue ;; esac
      selcomps="Sel_$(SANITIZE "$basename" 1)_Parts"
      eval "$selcomps=''"
      for comp in "#App" "#Data" "#ExtData" "#Media" "#Obb" "#AndroidID" "#PermAll"; do
        if [ ! -e "$SELDIR/$comp" ]; then
          ADDSTR "$comp" "$selcomps"
          case "$reset" in
            *"$comp"*) ;;
            *) ADDSTR "$comp" "reset" ;;
          esac
        fi
      done
   done
   unset IFS
   for comp in $reset; do
     > "$SELDIR/$comp"
   done
   reset=""
   mv "$CURR_LIST" "$PREV_LIST"
  done
  DEKH "✔️ Processing your selections..."
  CFM
  while IFS= read -r entry || [ -n "$entry" ]; do
   (
    IFS=: read -r app size pkg name ver <<< "$entry"
    [ -n "$name" ] || exit
    if [ ! -e "$SELDIR/$name" ]; then
      selcomps="Sel_$(SANITIZE "$name" 1)_Parts"
      for f in App Data ExtData Media Obb; do
        [ ! -f "$app/$f.bundle.pack" ] && DELSTR "#$f" "$selcomps"
      done
      [ -z "$(PADH SSAID "$app/Meta.txt")" ] && DELSTR "#AndroidID" "$selcomps"
      fselcomps="$(eval "printf %s \"\${$selcomps}\"" | tr '\n' ' ')"
      [ -z "$fselcomps" ] && {
        andid="$(PADH SSAID "$app/Meta.txt")"
        for f in App Data ExtData Media Obb; do
          [ -f "$app/$f.bundle.pack" ] && ADDSTR "#$f" "$selcomps"
        done
        [ -n "$andid" ] && ADDSTR "#AndroidID" "$selcomps"
        [ ! -f "$app/Permissions.txt" ] && ADDSTR "#PermAll" "$selcomps"
        fselcomps="$(eval "printf %s \"\${$selcomps}\"" | tr '\n' ' ')"
      }
      size=0; sizes="$(PADH Size "$app/Meta.txt")"
      IFS='|' read -r asize dsize esize msize osize <<< "$sizes"
      for f in App Data ExtData Media Obb; do
        case "$f" in
          App) s=$asize ;;
          Data) s=$dsize ;;
          ExtData) s=$esize ;;
          Media) s=$msize ;;
          Obb) s=$osize ;;
        esac
        grep -qw "#$f" <<< "$fselcomps" && size=$((size + s))
      done
      ADDSTR "$app:$size:$pkg:$name:$ver:$fselcomps" "$SELECTED"
    fi
   ) &
   COOLDOWN "$JOBS"
  done < "$FUAPPSLIST"
  [ -z "$SELECTED" ] && DEKH "⚠️ No Installed/User Apps selected"
  FUAPPSLIST="$SELECTED"
  rm -rf "$SELDIR"
}

# Unbundle Apps and It's directories
UNBUNDAPP() {
  FILE="$1"; DEST="$2"
  [ -f "$FILE" ] || return
  COOLDOWN "$((JOBS - 2))"
  "$ZAPDOS" -d -q -c "$FILE" | tar -xf - -C "$DEST" &
}

# Delete GMS Files
DELGMS() {
  pkg="$1"
  appdir="/data/data/$pkg"
  files="
databases/com.google.android.datatransport.events
databases/com.google.android.datatransport.events-journal
no_backup/com.google.android.gms.appid-no-backup
shared_prefs/com.google.android.gms.appid.xml
shared_prefs/com.google.android.gms.measurement.prefs.xml
"
  printf '%s\n' "$files" | while IFS= read -r f; do
    [ -f "$appdir/$f" ] && rm -f "$appdir/$f"
  done
}

# Fix Per PKG Ownerships and Notification Delay
FIXOWN() {
  ADGID=$(stat -c '%g' "/data/media/0/Android/data")
  AMGID=$(stat -c '%g' "/data/media/0/Android/media")
  AOGID=$(stat -c '%g' "/data/media/0/Android/obb")
  while IFS='|' read -r PKG UID CUID; do
   (
    [ -d "/data/data/$PKG" ] && chown -R "$UID:$UID" "/data/data/$PKG"
    [ -d "/data/user_de/0/$PKG" ] && chown -R "$UID:$UID" "/data/user_de/0/$PKG"
    [ -d "/data/media/0/Android/data/$PKG" ] && chown -R "$UID:$ADGID" "/data/media/0/Android/data/$PKG"
    [ -d "/data/media/0/Android/media/$PKG" ] && chown -R "$UID:$AMGID" "/data/media/0/Android/media/$PKG"
    [ -d "/data/media/0/Android/obb/$PKG" ] && chown -R "$UID:$AOGID" "/data/media/0/Android/obb/$PKG"
    DELGMS "$PKG"
    pm enable "$PKG" > /dev/null 2>&1
   ) &
    COOLDOWN "$JOBS"
  done < "$TMPLOC/.ownerships"
  rm -f "$TMPLOC/.ownerships"
  settings put global verifier_verify_adb_installs 1
}

# Restore Apps
RSTAPP() {
  PKG="$1"
  APP="$2"
  COMPONENTS="$3"
  mkdir -p "$TMPLOC/$PKG"
  "$ZAPDOS" -d -q -c "$APP/App.bundle.pack" | tar -xf - -C "$TMPLOC/$PKG"
  andid="$(PADH SSAID "$APP/Meta.txt")"
  oldsize="$(PADH Size "$APP/Meta.txt")"
  echo "$COMPONENTS" | grep -qw "#App" && {
  if ! PKG_INSTALLED "$PKG" "$ver"; then
    apks=$(find $TMPLOC/$PKG/data/app/*/*/*.apk | sort)
    echo "$COMPONENTS" | grep -qw "#PermAll" && all="-g"
    if pm install $all --dexopt-compiler-filter skip $apks > /dev/null 2>&1; then
      pm compile "$PKG" > /dev/null 2>&1 &
    else
      pm install $all $apks > /dev/null 2>&1 || return 1
    fi
    pm disable "$PKG" > /dev/null 2>&1
    dsize=0; esize=0; msize=0; osize=0
  else
    DEKH "⏭️ Skipping App (unchanged)"
    dsize="$(GETSIZE "/data/data/$pkg")"; esize="$(GETSIZE "/data/media/0/Android/data/$pkg")"; msize="$(GETSIZE "/data/media/0/Android/media/$pkg")"; osize="$(GETSIZE "/data/media/0/Android/obb/$pkg")"
  fi
  }
  IFS='|'; set -- $oldsize; oasize=${1:-0}; odsize=${2:-0}; oesize=${3:-0}; omsize=${4:-0}; oosize=${5:-0}; IFS=$OLDIFS
  UID=$(stat -c '%u' "/data/data/$PKG")
  echo "$COMPONENTS" | grep -qw "#Data" && { [ -f "$APP/Data.bundle.pack" ] && { [ "$dsize" != "$odsize" ] && UNBUNDAPP "$APP/Data.bundle.pack" "/data/data" && UNBUNDAPP "$APP/UserDe.bundle.pack" "/data/user_de/0" || DEKH "⏭️ Skipping Data (unchanged)"; } }
  echo "$COMPONENTS" | grep -qw "#ExtData" && { [ -f "$APP/ExtData.bundle.pack" ] && { [ "$esize" != "$oesize" ] && UNBUNDAPP "$APP/ExtData.bundle.pack" "/data/media/0/Android/data" || DEKH "⏭️ Skipping External Data (unchanged)"; } }
  echo "$COMPONENTS" | grep -qw "#Media" && { [ -f "$APP/Media.bundle.pack" ] && { [ "$msize" != "$omsize" ] && UNBUNDAPP "$APP/Media.bundle.pack" "/data/media/0/Android/media" || DEKH "⏭️ Skipping Media (unchanged)"; } }
  echo "$COMPONENTS" | grep -qw "#Obb" && { [ -f "$APP/Obb.bundle.pack" ] && { [ "$osize" != "$oosize" ] && UNBUNDAPP "$APP/Obb.bundle.pack" "/data/media/0/Android/obb" || DEKH "⏭️ Skipping OBB (unchanged)"; } }
  cp -af "$APP/Permissions.txt" "$TMPLOC/$PKG"
  echo "$COMPONENTS" | grep -qw "#AndroidID" && CHANID "$PKG" "$andid"
  echo "$COMPONENTS" | grep -qw "#PermAll" || SETPERM "$PKG" "$TMPLOC/$PKG/Permissions.txt"
  echo "$PKG|$UID" >> "$TMPLOC/.ownerships"
  DEKH "✅ Restore complete for: $label"
}

# Fetch and Display All Apps
FETCHAPPS() {
  UAPPSLIST="$(find "$PKGAPPS" -type d -mindepth 1 -maxdepth 1)"
  [ -z "$UAPPSLIST" ] && DEKH "⚠️ No User Apps found to install" && return 0
  FUAPPSLIST="$TMPLOC/appslist.txt"; > "$FUAPPSLIST"
  [ "$INSTYP" = "SELECT" ] && {
    mkdir -p "$SELDIR"
    for comp in "#App" "#Data" "#ExtData" "#Media" "#Obb" "#AndroidID" "#PermAll"; do
      > "$SELDIR/$comp"
    done
    DEKH "📂 $(basename "$SELDIR") folder will open in a moment\n🗑️ Delete only the app file to auto-select its parts\n🗑️ Delete both app and its parts to manually choose parts\n🔉 Press any Volume Key to Finish Selection"
  } &
  PSSHOWUAPPS() {
   (
    pkg="$(basename "$1")"
    label="$(PADH Name "$1/Meta.txt")"; label=$(SANITIZE "$label")
    ver="$(PADH Version "$1/Meta.txt")"
    sizes="$(PADH Size "$1/Meta.txt")"
    IFS='|' read -r asize dsize esize msize osize <<< "$sizes"
    size=$((asize + dsize + esize + msize + osize))
    ADDSTR "$1:$size:$pkg:$label:$ver" "$FUAPPSLIST"
    [ "$INSTYP" = "SELECT" ] && > "$SELDIR/$label"
   ) &
   COOLDOWN "$JOBS"
  }
  [ -n "$UAPPSLIST" ] && PRSMOD "$UAPPSLIST" "PSSHOWUAPPS"
  wait
}

# Install Modules or Apps
INSTALL() {
  cd "$TMPLOC"
  [ "$NEWUSER" -eq 1 ] && DEKH "📜 Read Instructions, then press any Volume Key" "h*" && OPT
  [ "$INSTYP" = "SELECT" ] && SELECTAPPS; wait
  PSUAPPS() {
    ACNT=$((ACNT + 1))
    app=$(echo "$1" | cut -d: -f1)
    size=$(echo "$1" | cut -d: -f2)
    pkg=$(echo "$1" | cut -d: -f3)
    label=$(echo "$1" | cut -d: -f4)
    ver=$(echo "$1" | cut -d: -f5)
    comps=$(echo "$1" | cut -d: -f6-)
    [ -z "$comps" ] && {
    size=0; comps=""
    sizes="$(PADH Size "$app/Meta.txt")"
    IFS='|'; set -- $sizes; asize=${1:-0}; dsize=${2:-0}; esize=${3:-0}; msize=${4:-0}; osize=${5:-0}; IFS=$OLDIFS
    andid="$(PADH SSAID "$app/Meta.txt")"
    for f in App Data ExtData Media Obb; do
    file="$app/$f.bundle.pack"
    [ -f "$file" ] && {
      ADDSTR "#$f" "comps"
        case "$f" in
          App) size=$((size + asize)) ;;
          Data) size=$((size + dsize)) ;;
          ExtData) size=$((size + esize)) ;;
          Media) size=$((size + msize)) ;;
          Obb) size=$((size + osize)) ;;
        esac
    }
    done
    [ -n "$andid" ] && ADDSTR "#AndroidID" "comps"
    [ ! -f "$app/Permissions.txt" ] && ADDSTR "#PermAll" "comps"
    }
    size=$(GETSIZE $size)
    DEKH "📦 [$ACNT] $label📱" "h"
    DEKH "ℹ️ Version: $ver | Size: $size"
    cmp=""; for c in $comps; do cmp="${cmp:+$cmp | }$c"; done; DEKH "🧩 Parts: $cmp"
    RSTAPP "$pkg" "$app" "$comps" || DEKH "❌ Failed to install $label (v$ver)" "hx" 1
  }
  SORTSTR "$FUAPPSLIST" 2
  settings put global verifier_verify_adb_installs 0
  START=$(date +%s)
  PRSMOD "$FUAPPSLIST" "PSUAPPS"
  DEKH "🔂 Finishing: $(jobs -p | wc -c) Remaining Processes..." && COOLDOWN 1
  END=$(date +%s); DURATION=$((END - START)); MIN=$((DURATION / 60)); SEC=$((DURATION % 60))
  [ -n "$UAPPSLIST" ] && FIXOWN
  DEKH "✅ Installation Complete, Everything is Installed" "h"
  if [ "$MIN" -gt 0 ]; then
    DEKH "⏱️ Took: ${MIN}m ${SEC}s"
  else
    DEKH "⏱️ Took: ${SEC}s"
  fi
}

# Check which Rooting Implementation is running
if [ -d "$ADBDIR/magisk" ] && magisk -V >/dev/null 2>&1; then
  ROOT="Magisk"
elif [ -d "$ADBDIR/ksu" ] && ksud -V >/dev/null 2>&1; then
  ROOT="KernelSU"
elif [ -d "$ADBDIR/ap" ] && apd -V >/dev/null 2>&1; then
  ROOT="APatch"
else
  DEKH "🤖?? Cannot determine rooting implementation, if you think it's a mistake, report on @BuildBytes" "hx"
  ROOT="Unknown"
fi

# Start Flashing Module
source "$MODPATH/flash.sh"
