#!/system/bin/sh
# Variables and Functions
TMPDIR="$(mktemp -d 2>/dev/null)" || TMPDIR="/dev/tmp"
chmod 700 "$TMPDIR"
[ -z "$MODPATH" ] && MODPATH="${0%/*}"
VTD="$TMPDIR/.verify"
mkdir -p "$VTD"
unzip -o "$ZIPFILE" -d "$VTD" >&2
PREFIX=' 3ba221f1046a4af4 132f86a5 f6234468f5 00399edd4de7f2 806cbe 766de0 775fc3e586566b 8cc8369129 f782118169cc74 cf97991ebe'
INFIX=' bd653ca4d1 7709f56699824839 6ec27fa1 354244cc380e67 80a08bf089 ab7dcbf609 17387ba1 b499c2b94161 31835c 12aa3c3440c9cd6c'
SUFFIX=' 0248088184bf2108 9e8ffc41c1 270423 2479c194af 30b221fa 272e263d5e bd0bc889eab5 e6722f 086cfd63ad887bfa f4a49007aa'
EXPECTED_COUNT=11
ACTUAL_COUNT=$(find "$VTD" -type f | wc -l)
export TMPLOC="/data/local/tmp"
rm -rf "$TMPLOC" && mkdir -p "$TMPLOC"
ADBDIR="/data/adb"
MODDIR="$ADBDIR/modules"
SDDIR=$(realpath "/sdcard")
EXTSD=$(find /storage -mindepth 1 -maxdepth 1 -type d 2>/dev/null | grep -Ev '/(emulated|self)' | grep -E '/[0-9A-Z]{4,}-[0-9A-Z]{4,}$' | head -n 1)
PKGDIR="$MODPATH/PACKED"
PKGAPPS="$PKGDIR/APPS"
DOWNDIR="$SDDIR/Download"
RNMDIR="$DOWNDIR/Rename_Module_Meta"
RNMFLD="$(basename $RNMDIR)"
SELDIR="$DOWNDIR/Delete_To_Select"
SELFLD="$(basename $SELDIR)"
Hashes="$MODPATH/hashes"
NAMEPH="#Rename_Name"
AUTHORPH="#Rename_Author"
VERSIONPH="#Rename_Version"
ARCH=$(getprop ro.product.cpu.abi)
SNORLAX="$MODPATH/snorlax"
PORYGONZ="$MODPATH/porygonz"
ZAPDOS="$MODPATH/zapdos"
NOW=$(date +"%I:%M %p - %d/%m/%Y")
ADDED=""
SKIPPED=""
MCNT=1
APPCNT=1
chmod +x "$SNORLAX" "$PORYGONZ" "$ZAPDOS"

# Only 64-Bit Supported
echo "$ARCH" | grep -qE 'arm64-v8a' || {
  DEKH "🧨 This module requires a 64-bit environment. Exiting..."
  exit 1
}

# Write Hashes
cat > "$Hashes" << 'HASHED'
3ba221f1046a4af46e9c2c8917a39c68de524000651c81e5b4fca88ef38b4833bd653ca4d107cba5e8781b376d2bc3b29766446fd1137d8bcd7bbb7ef90248088184bf2108 "./customize.sh"
132f86a5f8430551cc9b915f59ee944a7fb4f5f3bfa78b1f474538dc7709f56699824839d04f6c8a38fedd3971686dd27265e6d162d7122e8396888d9e8ffc41c1 "./flash.sh"
f6234468f50cb1005c65c89bc24a8b4dd06d033c9b624b2cd5a0f63b786ec27fa107df9d2448977e3e102515ca3300de2ec96db8c23626ab99270423 "./snorlax"
00399edd4de7f23a033b058f730703da1f906c1fc563163a94dd22be08d5b6354244cc380e673bec379dfddd4301c8bce6af9c0c06cb2e9c4172ca2b4a7a2479c194af "./zapdos"
806cbef9f284681331fe803ec1170fdbe7df4c7affd79b003f625280a08bf089c0bcde934f53b7c82ffc0400fbe1efaf81e6d980de72049e30b221fa "./porygonz"
766de0181f686650e1a30cf1ab7d77ce06c5c7cf9e4ee79bfa0b12ab7dcbf60982da3e80200c30be548858ab9e387fd65b6f3bf3cb729baa272e263d5e "./service.sh"
775fc3e586566b7f18ec95eed0658affea288928456bdd19e029dc8b6e348417387ba103c9a23f280712e4896d1009748f766c4e3b0a1a65927fe7bd0bc889eab5 "./META-INF/com/google/android/update-binary"
8cc8369129bd23b8290319c3a083de43ad0176fde017b9c7821e80aa52b499c2b941611e1f98077b8628f2b1cdb70c603d60d67de5c5b81a78c242e6722f "./META-INF/com/google/android/updater-script"
f782118169cc7483b66d4f42017d3bdf88aae7eee34e08b128e5e1bec4e15331835c3b17ccafdf6fff36ac2ec5e82ed3fcaf7c0f666e3ea4c456086cfd63ad887bfa "./module.prop"
cf97991ebe75b1e3c969484503c9b89d422e00c65df16351179905420b12aa3c3440c9cd6c8d8669c4260471b789ecb2bd6e1a50c953c1a721832526bbf4a49007aa "./bundle"
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
  info="$("$PORYGONZ" dump badging "$apkpath" 2>/dev/null)" || return 1
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

# Select/Detect deletion of User Apps and it's components
SELECTAPPS() {
  PREV_LIST="$(mktemp)"
  CURR_LIST="$(mktemp)"
  find "$SELDIR" -type f -o -type d 2>/dev/null | sort > "$PREV_LIST"
  OFM "$SELFLD"
  SELECTED=""
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
    IFS=: read -r app size pkg name ver <<< "$entry"
    [ -n "$name" ] || continue
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
      sizes="$(PADH "$pkg" "$TMPLOC/sizes")"
      IFS=':' read -r asize dsize esize msize osize <<< "$sizes"
      size=0; echo "$fselcomps" | grep -qw "#App" && size=$((size + asize)); echo "$fselcomps" | grep -qw "#Data" && size=$((size + dsize)); echo "$fselcomps" | grep -qw "#ExtData" && size=$((size + esize)); echo "$fselcomps" | grep -qw "#Media" && size=$((size + msize)); echo "$fselcomps" | grep -qw "#Obb" && size=$((size + osize))
      ADDSTR "$app:$size:$pkg:$name:$ver" "SELECTED"
      [ "$BAKMODE" = "FOLDER" ] && echo "$pkg=$fselcomps" >> "$BAKDIR/appslist.conf"
    fi
  done < "$APPMAP"
  [ -z "$SELECTED" ] && DEKH "⚠️ No Installed/User Apps selected"
  APPMAP="$SELECTED"
  rm -rf "$SELDIR"
}

# Wait for processes to complete
COOLDOWN() {
  while [ "$(pgrep -c tar)" -ge "$1" ]; do
    sleep 1
  done
}

# Bundle Apps and its directories
BUNDAPP() {
  SRC="$1"; NAME="$2"
  [ -d "$SRC/$PKG" ] || return
  COOLDOWN "$JOBS"
  tar --exclude='cache' -cf - -C "$SRC" "$PKG" | "$ZAPDOS" -f -q -o "$APP/$NAME.bundle.pack" &
}

# Backup Apps
BAKAPP() {
  PKG="$1"
  DEST="$2"
  COMPONENTS="$3"
  APP="$DEST/$PKG"
  [ ! -d "$APP" ] && mkdir -p "$APP"
  [ -f "$APP/Meta.txt" ] && oldsize="$(PADH Size "$APP/Meta.txt")" && IFS='|' read -r oasize odsize oesize omsize oosize <<< "$oldsize"
  sizes="$(PADH "$PKG" "$TMPLOC/sizes")"
  IFS=':' read -r asize dsize esize msize osize <<< "$sizes"
  DEKH "💾 Backing Up: $label" "h"
  echo "Name=$label" > "$APP/Meta.txt"
  echo "Version=$ver" >> "$APP/Meta.txt"
  echo "$COMPONENTS" | grep -qw "#App" && { [ "$asize" != "$oasize" ] && pm path "$PKG" | sed 's/^package://' | tar -cf - --transform "s|.*/$PKG[^/]*/|$PKG/|" -T - | "$ZAPDOS" -f -q -o "$APP/App.bundle.pack" || DEKH "⏭️ Skipping App (unchanged)"; } || asize=0
  echo "$COMPONENTS" | grep -qw "#Data"     && { [ "$dsize" != "$odsize" ] && BUNDAPP "/data/data" "Data" && BUNDAPP "/data/user_de/0" "UserDe" || DEKH "⏭️ Skipping Data (unchanged)"; } || dsize=0
  echo "$COMPONENTS" | grep -qw "#ExtData"  && { [ "$esize" != "$oesize" ] && BUNDAPP "/data/media/0/Android/data" "ExtData" || DEKH "⏭️ Skipping External Data (unchanged)"; } || esize=0
  echo "$COMPONENTS" | grep -qw "#Media"    && { [ "$msize" != "$omsize" ] && BUNDAPP "/data/media/0/Android/media" "Media" || DEKH "⏭️ Skipping Media (unchanged)"; } || msize=0
  echo "$COMPONENTS" | grep -qw "#Obb"      && { [ "$osize" != "$oosize" ] && BUNDAPP "/data/media/0/Android/obb" "Obb" || DEKH "⏭️ Skipping OBB (unchanged)"; } || osize=0
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
  APPMAP="$TMPLOC/appmap.txt"; > "$TMPLOC/appmap.txt"
  JOBS=$(( $(nproc) / 2 )); JOBS=${JOBS:-4}
  APPSLIST="$(pm list packages -f -3 | sed 's/package://g')"
  if [ "$BAKMODE" = "FOLDER" ] && [ -f "$BAKDIR/appslist.conf" ]; then
    DEKH "📑 Import apps list from config?" "h"
    DEKH "🔊 Vol+ = Yes (Fast import, keeps same apps)\n🔉 Vol- = No (Manually pick apps again)"
    OPT; [ $? -eq 0 ] && SELMODE="CONF" || rm -f "$BAKDIR/appslist.conf"
  fi
  [ "$SELMODE" = "FILE" ] && {
      mkdir -p "$SELDIR"
      DEKH "📂 $(basename "$SELDIR") folder will open in a moment\n🗑️ Delete only the app file to auto-select its parts\n🗑️ Delete both app and its parts to manually select parts\n🔉 Press any Vol Key to Finish Selection" 2 &
  }
  DEKH "✅ Validating Installed Apps... Please wait"
  [ "$SELMODE" = "FILE" ] && {
   for comp in "#App" "#Data" "#ExtData" "#Media" "#Obb" "#AndroidID" "#PermAll"; do
     > "$SELDIR/$comp"
   done
  } &
  while IFS= read -r line || [ -n "$line" ]; do
    (
    pkg="${line##*=}"
    app="${line%=$pkg}"
    [ -f "$app" ] || continue
    info="$("$PORYGONZ" dump badging "$app" 2>/dev/null)"
    label="$(echo "$info" | grep -m1 "application-label:" | cut -d"'" -f2)"; label=$(SANITIZE "$label")
    [ -z "$label" ] && continue
    ver="$(echo "$info" | grep -m1 "package: name=" | cut -d"'" -f6)"
    asize="$(GETSIZE $(pm path "$pkg" | sed 's/^package://'))"; dsize="$(GETSIZE "/data/data/$pkg")"; esize="$(GETSIZE "/data/media/0/Android/data/$pkg")"; msize="$(GETSIZE "/data/media/0/Android/media/$pkg")"; osize="$(GETSIZE "/data/media/0/Android/obb/$pkg")";
    echo "$pkg=$asize:$dsize:$esize:$msize:$osize" >> "$TMPLOC/sizes"
    size=$((asize + dsize + esize + msize + osize))
    ADDSTR "$app:$size:$pkg:$label:$ver" "$APPMAP"
    [ "$SELMODE" = "FILE" ] && > "$SELDIR/$label"      
    ) &
    sleep 0.1
  done <<< "$APPSLIST"; wait
  SORTSTR "$APPMAP" 2
  [ "$SELMODE" = "FILE" ] && SELECTAPPS || DEKH "🔌 Press/Hold Power Button Anytime to Finish"
  PSINSAPPS() {
    IFS=: read -r app size pkg label ver <<< "$1"
    if [ "$SELMODE" = "FILE" ]; then
      size=$(GETSIZE $size)
      selcomps="Sel_$(SANITIZE "$label" 1)_Parts"
      fselcomps="$(eval "printf %s \"\${$selcomps}\"" | tr '\n' ' ')"
      [ -n "$fselcomps" ] && {
      BAKAPP "$pkg" "$PKGAPPS" "$fselcomps"
      ADDSTR "$pkg" "ADDED"
      DEKH "📥 Added: $label 📱\nℹ️ Version: $ver | Size: $size \n🧩 Parts: $fselcomps"
      DEKH "✅ Backup complete for: $label"
      }
    elif [ "$SELMODE" = "CONF" ]; then
      comps="$(PADH "$pkg" "$BAKDIR/appslist.conf")"
      [ -z "$comps" ] && return
      sizes="$(PADH "$pkg" "$TMPLOC/sizes")"
      IFS=':' read -r asize dsize esize msize osize <<< "$sizes"
      size=0; echo "$comps" | grep -qw "#App" && size=$((size + asize)); echo "$comps" | grep -qw "#Data" && size=$((size + dsize)); echo "$comps" | grep -qw "#ExtData" && size=$((size + esize)); echo "$comps" | grep -qw "#Media" && size=$((size + msize)); echo "$comps" | grep -qw "#Obb" && size=$((size + osize))
      size=$(GETSIZE $size)
      BAKAPP "$pkg" "$PKGAPPS" "$comps"
      ADDSTR "$pkg" "ADDED"
      DEKH "📥 Added: $label 📱\nℹ️ Version: $ver | Size: $size \n🧩 Parts: $comps"
      DEKH "✅ Backup complete for: $label"
    else
      sizes="$(PADH "$pkg" "$TMPLOC/sizes")"
      IFS=':' read -r asize dsize esize msize osize <<< "$sizes"
      DEKH "📦 [$MCNT] - $label ($ver) 📱" "h*"
      DEKH "🔊 Vol+ Press = App Only\n🔉 Vol- Press = Skip\n🔊 Vol+ Hold = App & Data \n🔉 Vol- Hold = Entire App"
      OPT "h"; Key=$?
      case "$Key" in
        0)
         size="$asize"; size=$(GETSIZE $size)
         BAKAPP "$pkg" "$PKGAPPS" "#App"
         ADDSTR "$pkg" "ADDED"
         DEKH "📥 Added App Only: $size 📱"
         DEKH "✅ Backup complete for: $label"
         ;;
        10)
         size="$((asize + dsize))"; size=$(GETSIZE $size)
         BAKAPP "$pkg" "$PKGAPPS" "#App #Data"
         ADDSTR "$pkg" "ADDED"
         DEKH "📥 Added App & Data: $size 📱"
         DEKH "✅ Backup complete for: $label"
         ;;
         11)
         size="$((asize + dsize + esize + msize + osize))"; size=$(GETSIZE $size)
         BAKAPP "$pkg" "$PKGAPPS" "#App #Data #ExtData #Media #Obb"
         ADDSTR "$pkg" "ADDED"
         DEKH "📥 Added Entire App: $size 📱"
         DEKH "✅ Backup complete for: $label"
         ;;
         *)
         ADDSTR "$pkg" "SKIPPED"
         ;;
      esac
    fi
    MCNT=$((MCNT + 1))
  }
  START=$(date +%s)
  PRSMOD "$APPMAP" "PSINSAPPS"
  COOLDOWN "1"
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
  DEKH "🤖 Cannot determine rooting implementation, if you think it's a mistake, contact @BuildBytes" "hx" 2
  exit 1
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
