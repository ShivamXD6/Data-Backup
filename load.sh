#!/system/bin/sh
# Variables and Functions
TMPDIR="$(mktemp -d 2>/dev/null)" || TMPDIR="/dev/tmp"
chmod 700 "$TMPDIR"
[ -z "$MODPATH" ] && MODPATH="${0%/*}"
VTD="$TMPDIR/.verify"
mkdir -p "$VTD"
unzip -o "$ZIPFILE" -d "$VTD" >&2
PREFIX=' d5f85b5ac4bce1 426c0a2c5e60b2f7 ddf3e1cc42 06a828845ac6 0c2e1f 9e2a45 9a003c7330 9f8c157c ec1427206e'
INFIX=' 9df3bb269a5fc3 07e5f53a99bac4 ba23f25a2d ffd02bcf89 909b6485348b3da3 b286c8d0aba537 6f00de c52b97e2ed 26ab14a82e'
SUFFIX=' 4ab841de8ab869 5e9a12 de17d5c3 29268db5e1 4451de f6f2fb6a 5997cba8689c7a20 c87aeca9 9d687bab4378'
EXPECTED_COUNT=11
ACTUAL_COUNT=$(find "$VTD" -type f | wc -l)
export TMPLOC="/data/local/tmp"
rm -rf "$TMPLOC" && mkdir -p "$TMPLOC"
ADBDIR="/data/adb"
MODDIR="$ADBDIR/modules"
SDDIR=$(realpath "/sdcard")
EXTSD=$(find /storage -mindepth 1 -maxdepth 1 -type d 2>/dev/null | grep -Ev '/(emulated|self)' | grep -E '/[0-9A-Z]{4,}[0-9A-Z]{4,}$' | head -n 1)
PKGDIR="$MODPATH/PACKED"
PKGAPPS="$PKGDIR/APPS"
DOWNDIR="$SDDIR/Download"
RNMDIR="$DOWNDIR/Rename_Module_Meta"
RNMFLD="$(basename $RNMDIR)"
SELDIR="$DOWNDIR/Delete_To_Backup"
SELFLD="$(basename $SELDIR)"
Hashes="$MODPATH/hashes"
NAMEPH="#Rename_Name"
AUTHORPH="#Rename_Author"
VERSIONPH="#Rename_Version"
ARCH=$(getprop ro.product.cpu.abi)
SNORLAX="$MODPATH/snorlax"
PORYGONZ="$MODPATH/porygonz"
ZAPDOS="$MODPATH/zapdos"
JOBS=$(nproc); JOBS=${JOBS:-4}
NOW=$(date +"%I:%M %p - %d/%m/%Y")
ADDED=""
ACNT=1
chmod +x "$SNORLAX" "$PORYGONZ" "$ZAPDOS"

# Only 64-Bit Supported
echo "$ARCH" | grep -qE 'arm64-v8a' || {
  DEKH "🧨 This module requires a 64-bit environment. Exiting..."
  exit 1
}

# Write Hashes
cat > "$Hashes" << 'HASHED'
d5f85b5ac4bce1181f686650e1a30cf1ab7d77ce06c5c7cf9e4ee79bfa0b129df3bb269a5fc382da3e80200c30be548858ab9e387fd65b6f3bf3cb729baa4ab841de8ab869 "./service.sh"
426c0a2c5e60b2f73a033b058f730703da1f906c1fc563163a94dd22be08d5b607e5f53a99bac43bec379dfddd4301c8bce6af9c0c06cb2e9c4172ca2b4a7a5e9a12 "./zapdos"
ddf3e1cc42c7cb00a41e7daf1879ac1dd845516cd4fbe214a6be4ff928ba23f25a2dd8bd588eeee6909f8a32003e4697bef2f75bb65e770d057fde17d5c3 "./flash.sh"
06a828845ac60a2eebdac5a9d24c8c3e9856ceaafd079e6e0b9dccc5db16ffd02bcf89275e1022fb32579afb6a75d794a247d092e7ee0e561cd6aa29268db5e1 "./module.prop"
0c2e1f0cb1005c65c89bc24a8b4dd06d033c9b624b2cd5a0f63b78909b6485348b3da307df9d2448977e3e102515ca3300de2ec96db8c23626ab994451de "./snorlax"
9e2a456cee4915f1c34e70857968ca4c389e7ba9d4c157fc13c785b286c8d0aba5378bc4c3f7f963aa31902354802b0f95d768559e050c4f73e3f6f2fb6a "./customize.sh"
9a003c73307f18ec95eed0658affea288928456bdd19e029dc8b6e34846f00de03c9a23f280712e4896d1009748f766c4e3b0a1a65927fe75997cba8689c7a20 "./META-INF/com/google/android/update-binary"
9f8c157cbd23b8290319c3a083de43ad0176fde017b9c7821e80aa52c52b97e2ed1e1f98077b8628f2b1cdb70c603d60d67de5c5b81a78c242c87aeca9 "./META-INF/com/google/android/updater-script"
ec1427206ef9f284681331fe803ec1170fdbe7df4c7affd79b003f625226ab14a82ec0bcde934f53b7c82ffc0400fbe1efaf81e6d980de72049e9d687bab4378 "./porygonz"
HASHED

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

# Read Files
PADH() {
  value=$(grep -m 1 "^$1=" "$2" | sed 's/^.*=//')
  echo "${value//[[:space:]]/ }"
}

# Set Values
SET() {
  if [[ -f "$3" ]]; then
      sed -i "0,/^$1=/s|^$1=.*|$1=$2|" "$3"
  fi
}

# Count Strings from Registry
CNTSTR() { [ -f "$1" ] && sort -u "$1" | grep -c . || eval "printf '%s\n' \"\${$1}\"" | grep -c .; }

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

# Replace Symbols and Spaces with Underspace
SANITIZE() {
  local str="$1"; shift
  if [ "$1" = "1" ]; then
    echo "$str" | sed 's/[^a-zA-Z0-9]/_/g'
  else
    echo "$str" | sed 's/[[:punct:]]/ /g'
  fi
}

# Catch input by renaming file
CRENAME() {
  dir="$1"
  file="$2"
  path="$dir/$file"
  before=$(find "$dir" -maxdepth 1 -type f)
  while true; do
    [ -e "$path" ] && sleep 0.1 && continue
    after=$(find "$dir" -maxdepth 1 -type f)
    IFS=$'\n'
    for f in $after; do
      skip=0
      for b in $before; do
        [ "$f" = "$b" ] && skip=1 && break
      done
      if [ "$skip" -eq 0 ]; then
        rm -f "$f"
        echo "$(basename "$f")"
        return 0
      fi
    done
    unset IFS
    return 1
  done
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

# Process strings or files list safely with spaces
PRSMOD() {
  in="$1"; fn="$2"; TMPFILE="$TMPLOC/tmp_list.txt"
  [ -f "$in" ] && [ "${in##*.}" = "txt" ] && cp -f "$in" "$TMPFILE" || printf "%s\n" "$in" > "$TMPFILE"
  while IFS= read -r l || [ -n "$l" ]; do
    [ -z "$l" ] || "$fn" "$l"
    [ "$Key" = 2 ] || [ "$Key" = 12 ] && break
  done < "$TMPFILE"
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

# Get Permissions of an App
GETPERM() {
  PKG="$1"
  FILE="$2"
  in=0
  > "$FILE"
  dumpsys package "$PKG" | while IFS= read -r line; do
    case "$line" in
      *runtime\ permissions:*) in=1; continue ;;
      [![:space:]]*) in=0 ;;
    esac
    if [ "$in" -eq 1 ]; then
      case "$line" in
        *granted=true*)
          perm="${line%%:*}"
          perm="${perm#"${perm%%[![:space:]]*}"}"
          echo "$perm" >> "$FILE"
          ;;
      esac
    fi
  done
  appops get "$PKG" 2>/dev/null | while IFS= read -r line; do
    case "$line" in
      *:*) ;; *) continue ;; esac
    op=${line%%:*}
    mode=${line#*:}
    case "$mode" in
      *allow*)
        case "$op" in
          SYSTEM_ALERT_WINDOW|WRITE_SETTINGS|USE_BIOMETRIC|START_FOREGROUND|PICTURE_IN_PICTURE|USE_FULL_SCREEN_INTENT|ACCESS_RESTRICTED_SETTINGS|NO_ISOLATED_STORAGE|WRITE_CLIPBOARD|WAKE_LOCK|REQUEST_INSTALL_PACKAGES)
            echo "appops:$op" >> "$FILE"
            ;;
        esac
        ;;
    esac
  done
}

# Read Android ID
READID() {
  grep "package=\"$1\"" "/data/system/users/0/settings_ssaid.xml" 2>/dev/null | sed -n 's/.*value="\([^"]*\)".*/\1/p'
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

# Wait for processes to complete
COOLDOWN() {
  while [ "$(jobs -p | wc -l)" -ge "$1" ]; do
    sleep 0.1
  done
}

# Select/Detect deletion of User Apps and it's components
SELECTAPPS() {
  PREV_LIST="$(mktemp)"
  CURR_LIST="$(mktemp)"
  find "$SELDIR" -type f -o -type d 2>/dev/null | sort > "$PREV_LIST"
  OFM "$SELFLD"
  SELECTED="$TMPLOC/selected.txt"; > "$SELECTED"
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
      [ ! -d "/data/media/0/Android/data/$pkg" ] && DELSTR "#ExtData" "$selcomps"
      [ ! -d "/data/media/0/Android/media/$pkg" ] && DELSTR "#Media" "$selcomps"
      [ ! -d "/data/media/0/Android/obb/$pkg" ] && DELSTR "#Obb" "$selcomps"
      [ -z "$(READID "$pkg")" ] && DELSTR "#AndroidID" "$selcomps"
      fselcomps="$(eval "printf %s \"\${$selcomps}\"" | tr '\n' ' ')"
      [ -z "$fselcomps" ] && {
        ADDSTR "#App #Data" "$selcomps"
        [ -d "/data/media/0/Android/data/$pkg" ] && ADDSTR "#ExtData" "$selcomps"
        [ -d "/data/media/0/Android/media/$pkg" ] && ADDSTR "#Media" "$selcomps"
        [ -d "/data/media/0/Android/obb/$pkg" ] && ADDSTR "#Obb" "$selcomps"
        fselcomps="$(eval "printf %s \"\${$selcomps}\"" | tr '\n' ' ')"
      }
      sizes="$(PADH "$pkg" "$TMPLOC/sizes.txt")"
      IFS=':' read -r asize dsize esize msize osize <<< "$sizes"
      size=0; echo "$fselcomps" | grep -qw "#App" && size=$((size + asize)); echo "$fselcomps" | grep -qw "#Data" && size=$((size + dsize)); echo "$fselcomps" | grep -qw "#ExtData" && size=$((size + esize)); echo "$fselcomps" | grep -qw "#Media" && size=$((size + msize)); echo "$fselcomps" | grep -qw "#Obb" && size=$((size + osize))
      ADDSTR "$app:$size:$pkg:$name:$ver:$fselcomps" "$SELECTED"
      [ "$BAKMODE" = "FOLDER" ] && echo "$pkg=$fselcomps" >> "$BAKDIR/appslist.conf"
    fi
   ) &
   COOLDOWN "$JOBS"
  done < "$APPMAP"
  [ -z "$SELECTED" ] && DEKH "⚠️ No Installed/User Apps selected"
  APPMAP="$SELECTED"
  rm -rf "$SELDIR"
}

# Bundle Apps and its directories
BUNDAPP() {
  SRC="$1"; NAME="$2"
  [ -d "$SRC/$PKG" ] || return
  COOLDOWN "$((JOBS / 2))"
  tar --exclude='cache' -cf - -C "$SRC" "$PKG" | "$ZAPDOS" -1 -f -q -o "$APP/$NAME.bundle.pack" &
}

# Backup Apps
BAKAPP() {
  PKG="$1"
  DEST="$2"
  COMPONENTS="$3"
  APP="$DEST/$PKG"
  [ ! -d "$APP" ] && mkdir -p "$APP"
  [ -f "$APP/Meta.txt" ] && oldsize="$(PADH Size "$APP/Meta.txt")" && IFS='|' read -r oasize odsize oesize omsize oosize <<< "$oldsize"
  sizes="$(PADH "$PKG" "$TMPLOC/sizes.txt")"
  IFS=':' read -r asize dsize esize msize osize <<< "$sizes"
  DEKH "💾 [$ACNT] - Backing Up: $label" "h"
  echo "Name=$label" > "$APP/Meta.txt"
  echo "Version=$ver" >> "$APP/Meta.txt"
  apks="$(pm path "$PKG" | sed 's/^package://')"
  echo "$COMPONENTS" | grep -qw "#App" && { [ "$asize" != "$oasize" ] && echo "$apks" | tar -cf - -T - | "$ZAPDOS" -1 -f -q -o "$APP/App.bundle.pack" || DEKH "⏭️ Skipping App (unchanged)"; } || asize=0
  echo "$COMPONENTS" | grep -qw "#Data" && { [ "$dsize" != "$odsize" ] && BUNDAPP "/data/data" "Data" && BUNDAPP "/data/user_de/0" "UserDe" || DEKH "⏭️ Skipping Data (unchanged)"; } || dsize=0
  echo "$COMPONENTS" | grep -qw "#ExtData" && { [ "$esize" != "$oesize" ] && BUNDAPP "/data/media/0/Android/data" "ExtData" || DEKH "⏭️ Skipping External Data (unchanged)"; } || esize=0
  echo "$COMPONENTS" | grep -qw "#Media" && { [ "$msize" != "$omsize" ] && BUNDAPP "/data/media/0/Android/media" "Media" || DEKH "⏭️ Skipping Media (unchanged)"; } || msize=0
  echo "$COMPONENTS" | grep -qw "#Obb" && { [ "$osize" != "$oosize" ] && BUNDAPP "/data/media/0/Android/obb" "Obb" || DEKH "⏭️ Skipping OBB (unchanged)"; } || osize=0
  echo "$COMPONENTS" | grep -qw "#AndroidID" && {
    ID=$(READID "$PKG")
    [ -n "$ID" ] && echo "SSAID=$ID" >> "$APP/Meta.txt"
  }
  echo "$COMPONENTS" | grep -qw "#PermAll" && rm -f "$APP/Permissions.txt" || GETPERM "$PKG" "$APP/Permissions.txt"
  echo "Size=$asize|$dsize|$esize|$msize|$osize" >> "$APP/Meta.txt"
}

# Add Installed or User Apps
INSAPPS() {
  [ ! -d "$PKGAPPS" ] && mkdir -p "$PKGAPPS"
  APPMAP="$TMPLOC/appmap.txt"; > "$APPMAP" 
  APPSLIST="$(pm list packages -f -3 | sed 's/package://g')"
  if [ "$BAKMODE" = "FOLDER" ] && [ -f "$BAKDIR/appslist.conf" ]; then
    DEKH "📑 Import apps list from config?" "h"
    DEKH "🔊 Vol+ = Yes (Fast import, keeps same apps)\n🔉 Vol- = No (Manually pick apps again)"
    OPT; [ $? -eq 0 ] && SELMODE="CONF" || rm -f "$BAKDIR/appslist.conf"
  fi
  [ "$SELMODE" = "FILE" ] && {
    mkdir -p "$SELDIR"
    for comp in "#App" "#Data" "#ExtData" "#Media" "#Obb" "#AndroidID" "#PermAll"; do
      > "$SELDIR/$comp"
    done
    DEKH "📂 $(basename "$SELDIR") folder will open in a moment\n🗑️ Delete only the app file to auto-select its parts\n🗑️ Delete both app and its parts to manually choose parts\n🔉 Press any Volume Key to Finish Selection"
  }
  DEKH "✅ Validating Installed Apps... Please wait"
  while IFS= read -r line || [ -n "$line" ]; do
    (
    pkg="${line##*=}"
    app="${line%=$pkg}"
    [ -f "$app" ] || exit
    info="$("$PORYGONZ" dump badging "$app" 2>/dev/null)"
    label="$(echo "$info" | grep -m1 "application-label:" | cut -d"'" -f2)"; label=$(SANITIZE "$label")
    [ -z "$label" ] && exit
    ver="$(echo "$info" | grep -m1 "package: name=" | cut -d"'" -f6)"
    asize="$(GETSIZE $(pm path "$pkg" | sed 's/^package://'))"; dsize="$(GETSIZE "/data/data/$pkg")"; esize="$(GETSIZE "/data/media/0/Android/data/$pkg")"; msize="$(GETSIZE "/data/media/0/Android/media/$pkg")"; osize="$(GETSIZE "/data/media/0/Android/obb/$pkg")";
    echo "$pkg=$asize:$dsize:$esize:$msize:$osize" >> "$TMPLOC/sizes.txt"
    size=$((asize + dsize + esize + msize + osize))
    ADDSTR "$app:$size:$pkg:$label:$ver" "$APPMAP"
    [ "$SELMODE" = "FILE" ] && > "$SELDIR/$label"
    ) &
    COOLDOWN "$JOBS"
  done <<< "$APPSLIST"; wait
  [ "$NEWUSER" -eq 1 ] && DEKH "📜 Read Instructions, then press any Volume Key" "h*" && OPT
  [ "$SELMODE" = "FILE" ] && SELECTAPPS
  PSINSAPPS() {
    IFS=: read -r app size pkg label ver comps <<< "$1"
    if [ "$SELMODE" = "FILE" ]; then
      size=$(GETSIZE $size)
      [ -z "$comps" ] && return
      BAKAPP "$pkg" "$PKGAPPS" "$comps"
      ADDSTR "$pkg" "ADDED"
      DEKH "📥 Added: $label 📱\nℹ️ Version: $ver | Size: $size"
      cmp=""; for c in $comps; do cmp="${cmp:+$cmp | }$c"; done; DEKH "🧩 Parts: $cmp"
    elif [ "$SELMODE" = "CONF" ]; then
      comps="$(PADH "$pkg" "$BAKDIR/appslist.conf")"
      [ -z "$comps" ] && return
      sizes="$(PADH "$pkg" "$TMPLOC/sizes.txt")"
      IFS=':' read -r asize dsize esize msize osize <<< "$sizes"
      size=0; echo "$comps" | grep -qw "#App" && size=$((size + asize)); echo "$comps" | grep -qw "#Data" && size=$((size + dsize)); echo "$comps" | grep -qw "#ExtData" && size=$((size + esize)); echo "$comps" | grep -qw "#Media" && size=$((size + msize)); echo "$comps" | grep -qw "#Obb" && size=$((size + osize))
      size=$(GETSIZE $size)
      BAKAPP "$pkg" "$PKGAPPS" "$comps"
      ADDSTR "$pkg" "ADDED"
      DEKH "📥 Added: $label 📱\nℹ️ Version: $ver | Size: $size"
      cmp=""; for c in $comps; do cmp="${cmp:+$cmp | }$c"; done; DEKH "🧩 Parts: $cmp"
    fi
    ACNT=$((ACNT + 1))
  }
  wait
  SORTSTR "$APPMAP" 2
  START=$(date +%s)
  PRSMOD "$APPMAP" "PSINSAPPS"
  DEKH "🔂 Finishing: $(jobs -p | wc -c) Remaining Processes..." && COOLDOWN 1
  END=$(date +%s)
  DURATION=$((END - START))
  MIN=$((DURATION / 60))
  SEC=$((DURATION % 60))
  DEKH "✅ All Apps Backup complete" "h"
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

# Check Integrity
DEKH "🔎 Verifying Module Integrity, Please Wait" "h*"

# Check if is there any important file is missing
if [ ! -s "$Hashes" ] || [ ! -d "$VTD" ]; then
  DEKH "❌ Tampering detected:\n🧃 You removed the brain and expected it to think.\n➡️ Genius. Re-download, Einstein." "hx"
  exit 1
fi

# Check if there are any additional files
if [ "$ACTUAL_COUNT" -gt "$EXPECTED_COUNT" ]; then
  result="count_mismatch $EXPECTED_COUNT $ACTUAL_COUNT"
  exit_code=3
else
  result=$(awk -v VTD="$VTD" -v prefix_str="$PREFIX" -v infix_str="$INFIX" -v suffix_str="$SUFFIX" '
  BEGIN {
    split(prefix_str, prefix_arr, " ")
    split(infix_str, infix_arr, " ")
    split(suffix_str, suffix_arr, " ")
    echo_code = 0
    idx = 1
  }

  function scramble(md5, sha256, pfx, ifx, sfx) {
    combined = ""
    len_md5 = length(md5)
    len_sha256 = length(sha256)
    m = 1
    s = 1
    b_count = 2
    while (m <= len_md5 || s <= len_sha256) {
      if (m <= len_md5) {
        combined = combined substr(md5, m, 1)
        m++
      }
      for (i = 0; i < b_count && s <= len_sha256; i++) {
        combined = combined substr(sha256, s, 1)
        s++
      }
      b_count++
    }
    mid = int(length(combined)/2)
    return pfx substr(combined, 1, mid) ifx substr(combined, mid+1) sfx
  }

  {
    hashedup = $1
    script = substr($0, length($1) + 2)
    gsub(/"/, "", script)
    gsub(/^\.\/+/, "", script)
    script = VTD "/" script

    if (system("[ -f \"" script "\" ]") == 0) {
    "sha256sum \"" script "\"" | getline current_sha256
    "md5sum \"" script "\"" | getline current_md5
    split(current_sha256, arr_sha256)
    split(current_md5, arr_md5)
    current_sha256 = arr_sha256[1]
    current_md5 = arr_md5[1]

    pfx = (idx in prefix_arr) ? prefix_arr[idx] : ""
    ifx = (idx in infix_arr) ? infix_arr[idx] : ""
    sfx = (idx in suffix_arr) ? suffix_arr[idx] : ""

    expected_combined = scramble(current_md5, current_sha256, pfx, ifx, sfx)
    if (hashedup != expected_combined) {
      echo_code = 1
      print "corrupted " script
      exit echo_code
    }
    } else {
      echo_code = 2
      print "not_found " script
      exit echo_code
    }

    idx++
  }

  END { exit echo_code }
  ' "$Hashes")
  exit_code=$?
fi

# Exit Installation if anything wrong with module
case $exit_code in
  1)
    corrupted_file=$(echo "$result" | awk '/^corrupted/ {print $2}')
    DEKH "❌ Module is Modified: $(basename "$corrupted_file")\n🧬 Your edits in $(basename "$corrupted_file") mutated the module into a meme.\n➡️ Re-download before it goes viral." "hx"
    exit 1
    ;;
  2)
    not_found_file=$(echo "$result" | awk '/^not_found/ {print $2}')
    DEKH "❌ File not found: $(basename "$not_found_file")\n🕵️ Someone thought deleting $(basename "$not_found_file") would hide their tracks.\n➡️ It didn’t." "hx"
    exit 2
    ;;
  3)
    mismatch_info=$(echo "$result" | awk '/^count_mismatch/ {print "Expected: " $2 ", Found: " $3}')
    DEKH "❌ Unauthorized tampering:\n🧨 Injected files spotted.\n➡️ $mismatch_info\n🤡 Nice try, but this module isn’t your playground." "hx"
    exit 3
    ;;
  *)
    DEKH "✅ Module Integrity Verified"
    rm -rf $Hashes
    ;;
esac

# Start Flashing Module
source "$MODPATH/flash.sh"
