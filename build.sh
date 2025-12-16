#!/bin/bash
cd "/sdcard/#Data-Backup" || exit 1
modzip="#Data-Backup.zip"
target="load.sh"
ignorezip="-name build.sh"
temp_hashes=$(mktemp)
temp_output=$(mktemp)

# Clean previous zip
[ -f "$modzip" ] && rm -f "$modzip"

# Random 6-16 digits strings
RAND() {
  len=$((RANDOM % 6 + 3)) 
  head -c "$len" /dev/urandom | xxd -p
}

# Hash parts
PREFIX=""
INFIX=""
SUFFIX=""

# Set variable in file
SET() {
  key="$1"
  val="$2"
  file="$3"
  if [[ -f "$file" ]]; then
    sed -i "0,/^$key=/s|^$key=.*|$key=$val|" "$file"
  fi
  echo "✍️ Set $1=$2 in $3"
}

# Hash creation and combination
while IFS= read -r -d '' file; do
  sha256=$(sha256sum "$file" | awk '{print $1}')
  md5=$(md5sum "$file" | awk '{print $1}')
  pfx=$(RAND)
  ifx=$(RAND)
  sfx=$(RAND)

  PREFIX="$PREFIX $pfx"
  INFIX="$INFIX $ifx"
  SUFFIX="$SUFFIX $sfx"

  combined_hash=$(awk -v md5="$md5" -v sha256="$sha256" -v prefix="$pfx" -v infix="$ifx" -v suffix="$sfx" '
    function scramble(md5, sha256) {
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
      return prefix substr(combined, 1, mid) infix substr(combined, mid+1) suffix
    }
    BEGIN { print scramble(md5, sha256) }
  ')

  echo "$combined_hash \"$file\"" >> "$temp_hashes"
done < <(find . -type f ! -name 'build.sh' ! -name 'load.sh' ! -name 'load' ! -name 'hashes' ! -name 'bundle.sh' -print0)

# Inject hashes into load.sh
awk '
  BEGIN { in_block = 0 }
  /<<[[:space:]]*'\''HASHED'\''/ {
    print
    while ((getline line < "'"$temp_hashes"'") > 0) print line
    in_block = 1
    next
  }
  in_block && /^HASHED$/ { in_block = 0; print; next }
  !in_block { print }
' "$target" > "$temp_output" && mv "$temp_output" "$target"

rm -f "$temp_hashes"
echo "✅ Hashes injected into $target"

# Set parts in load.sh
FILES=$(find . -mindepth 1 -maxdepth 1 \( -type f -o -type d \) ! \( $ignorezip \))
SET "PREFIX" "'$PREFIX'" "$target"
SET "INFIX" "'$INFIX'" "$target"
SET "SUFFIX" "'$SUFFIX'" "$target"
SET "EXPECTED_COUNT" "$(( $(echo "$FILES" | wc -l) + 1 ))" "$target"

# Zip files
FILES=$(find . -mindepth 1 -maxdepth 1 \( -type f -o -type d \) ! \( $ignorezip \))
if [ -n "$FILES" ]; then
zip -qr "$modzip" $(basename -a $FILES)
  echo "✅ Packed $(( $(echo "$FILES" | wc -l) + 1 )) files into $modzip"
else
  echo " No files to zip after exclusions."
fi

# Cleanup binaries
[ -f bundle ] && rm -f bundle
[ -f load ] && rm -f load
