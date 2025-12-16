#!/system/bin/sh

# Module Info UI
DEKH "$(PADH "name" "$MODPATH/module.prop")" "h#"
DEKH "🌟 Made By $(PADH "author" "$MODPATH/module.prop")"
DEKH "⚡ Version - $(PADH "version" "$MODPATH/module.prop")"
DEKH "🎲 Rooting Implementation - $ROOT"
DEKH "📝 $(PADH "description" "$MODPATH/module.prop")" 1

# Check for any external media
if [ -n "$EXTSD" ]; then
  DEKH "💾 External Storage Found, What to do?" "h"
  DEKH "🔊 Vol+ = Backup in Internal Storage (fast)\n🔉 Vol- = Backup in $EXTSD (slow)"
  OPT; [ $? -eq 1 ] && SDDIR="$EXTSD"
fi

# Backup Storing Method
BAKMODE="FOLDER"
BAKDIR="$SDDIR/#Backup"
[ ! -d "$BAKDIR" ] && BAKDIR="$(dirname "$(find "$SDDIR" -maxdepth 2 -type f -name '.bundle-mods' | head -n 1)")"; [ "$BAKDIR" = "." ] && BAKDIR="$SDDIR/#Backup" && mkdir -p "$BAKDIR"
PKGAPPS="$BAKDIR/APPS"
> "$BAKDIR/.bundle-mods"
[ ! -f "$ADBDIR/.bundle-ex" ] && NEWUSER=1

# Create Base of Module Pack
[ "$NEWUSER" -eq 1 ] && DEKH "⚒️ Building Module Package" "h"
mkdir -p "$PKGDIR"
touch "$PKGDIR/flash.sh"
cp -af "$VTD/META-INF" "$PKGDIR/META-INF"
cp -af "$VTD/customize.sh" "$PKGDIR/customize.sh"
cp -af "$VTD/bundle.sh" "$PKGDIR/load.sh"
cp -af "$VTD/porygonz" "$PKGDIR/porygonz"
cp -af "$VTD/snorlax" "$PKGDIR/snorlax"
cp -af "$VTD/zapdos" "$PKGDIR/zapdos"
cp -af "$VTD/module.prop" "$PKGDIR/module.prop"
cp -af "$VTD/service.sh" "$PKGDIR/service.sh"

cat > "$PKGDIR/flash.sh" << 'FINISH'
#!/system/bin/sh
# Module Info UI
DEKH "$(PADH "name" "$MODPATH/module.prop")" "h#"
DEKH "🌟 Packed By $(PADH "author" "$MODPATH/module.prop")"
DEKH "⚡ Version - $(PADH "version" "$MODPATH/module.prop")"
DEKH "🎲 Rooting Implementation - $ROOT" 1

# Check for Backups
DEKH "🔎 Looking for Backups" "h"
BAKDIR="$SDDIR/#Backup"
[ ! -d "$BAKDIR" ] && BAKDIR="$(dirname "$(find "$SDDIR" -maxdepth 2 -type f -name '.bundle-mods' | head -n 1)")"; [ "$BAKDIR" = "." ] && BAKDIR="$SDDIR/#Backup"
[ -n "$EXTSD" ] && {
  BAKEXT="$EXTSD/#Backup"
  [ ! -d "$BAKEXT" ] && BAKEXT="$(dirname "$(find "$EXTSD" -maxdepth 2 -type f -name '.bundle-mods' | head -n 1)")"; [ "$BAKEXT" = "." ] && BAKEXT="$EXTSD/#Backup"
  [ ! -d "$BAKDIR" ] && [ -d "$BAKEXT" ] && BAKDIR="$BAKEXT"
}
  
[ ! -d "$BAKDIR" ] && [ ! -d "$BAKEXT" ] && DEKH "❌ Can't find anything to install" "hx" && exit 1

# Check if backup exists in both storage
[ -d "$BAKDIR" ] && [ -d "$BAKEXT" ] && {
  DEKH "💾 Select a Backup Location to Restore from?" "h"
  DEKH "🔊 Vol+ = Restore from Internal Storage (fast)\n🔉 Vol- = Restore from $EXTSD (slow)"
  OPT; [ $? -eq 1 ] && {
    BAKDIR="$BAKEXT"
  }
}
[ ! -f "$ADBDIR/.bundle-ex" ] && NEWUSER=1

# Update Vars for Backup Mode Folder
PKGAPPS="$BAKDIR/APPS"

# Installation Type Quick or Selective
DEKH "⏬ Select Installation Type?" "h"
DEKH "🔊 Vol+ = Quick Install (install all)\n🔉 Vol- = Selective Install (select & install)"
OPT; [ $? -eq 1 ] && {
  INSTYP="SELECT"
}

DEKH "✅ Validating your Apps..." "h"
FETCHAPPS

# Install Apps
DEKH "⏬ Installing Apps" "h"
INSTALL

[ "$NEWUSER" -eq 1 ] && {
# Prompt to join Channel
DEKH "🔗 @BuildBytes is quietly building things worth exploring. Want to be there early?" "h#"
DEKH "🔊 Vol+ = Yes, I’m in. early, curious, and ahead\n🔉 Vol- = No, I’ll scroll past and miss it\n"
OPT
if [ $? -ne 1 ]; then
  am start -a android.intent.action.VIEW -d https://telegram.me/BuildBytes >/dev/null 2>&1
else
  DEKH "🫥 You passed.\nNo noise, no regret, just a silent skip over something built with intent.\nI’ll stay here, quietly excellent, waiting for those who notice before it’s popular."
fi
}
wait
DEKH "📦 Everything from Pack Installed Successfully" "h" 1

# Remove Bundle-Mods
(
sleep 0.2
touch "$ADBDIR/.bundle-ex"
rm -rf "$MODPATH" "$MODDIR/bundle-mods" 
)&
FINISH

# Selection Method
SELMODE="FILE"

# Add Installed / User Apps
mkdir -p "$PKGAPPS"
DEKH "👀 Looking for Installed Apps 📱" "h"
INSAPPS

# Check if the user is Chhota Bheem
ADDCNT=$(CNTSTR "ADDED")

# Example 1:
[ "$ADDCNT" -eq 0 ] && DEKH "🤡 This bundle pack is as empty as your love life." "hx" && exit 10

# Example 2:
[ "$ADDCNT" -le 2 ] && DEKH "🫥 Your bundle/pack has less content than your last relationship." "h"

# Customize Module Name and Author
DEKH "🎨 Do you want to change the bundle/pack name and author?" "h"
DEKH "🔊 Vol+ = Yes\n🔉 Vol- = No"
OPT
if [ $? -eq 0 ]; then
  DEKH "\nℹ️ Follow Instructions :-\n- Rename below files:\n- '$NAMEPH'\n- '$AUTHORPH'\n- '$VERSIONPH'\n📂 in $RNMDIR\n" 3
  mkdir -p "$RNMDIR"; OFM "$RNMFLD"
  touch "$RNMDIR/$NAMEPH"
  CUSNAME="$(CRENAME "$RNMDIR" "$NAMEPH")" || CUSNAME="🧰 Apps Package - $(getprop ro.product.model)"
  DEKH "✅ Pack Name set to: $CUSNAME"
  touch "$RNMDIR/$AUTHORPH"
  CUSAUTHOR="$(CRENAME "$RNMDIR" "$AUTHORPH")" || CUSAUTHOR="Unknown"
  DEKH "✅ Pack Author set to: $CUSAUTHOR"
  touch "$RNMDIR/$VERSIONPH"
  CUSVERSION="$(CRENAME "$RNMDIR" "$VERSIONPH")" || CUSVERSION="v2 ($NOW)"
  DEKH "✅ Pack Version set to: $CUSVERSION"
  CFM; rm -rf "$RNMDIR"; sleep 1
else
  CUSNAME="🧰 Apps Package - $(getprop ro.product.model)"
  CUSAUTHOR="Unknown"
  CUSVERSION="v2 ($NOW)"
  DEKH "✅ Using Default Values: \n$CUSNAME [$CUSVERSION] by $CUSAUTHOR"
fi

# Modify Module Prop
SET name "$CUSNAME" "$PKGDIR/module.prop"
SET author "$CUSAUTHOR" "$PKGDIR/module.prop"
SET description "Packed $ADDCNT Apps in $(getprop ro.product.model), (A$(getprop ro.build.version.release))" "$PKGDIR/module.prop"
SET version "$CUSVERSION" "$PKGDIR/module.prop"

# Data Backup Package
rm -f "$BAKDIR/"*.zip
PACKFILE="$BAKDIR/$CUSNAME.zip"
cd "$PKGDIR"
$SNORLAX -qr "$PACKFILE" .

[ "$NEWUSER" -eq 1 ] && {
DEKH "🔗 @BuildBytes is quietly building things worth exploring. Want to be there early?" "h#"
DEKH "🔊 Vol+ = Yes, I’m in. early, curious, and ahead\n🔉 Vol- = No, I’ll scroll past and miss it\n"
OPT
if [ $? -ne 1 ]; then
  am start -a android.intent.action.VIEW -d https://telegram.me/BuildBytes >/dev/null 2>&1
else
  DEKH "🫥 You passed.\nNo noise, no regret, just a silent skip over something built with intent.\nI’ll stay here, quietly excellent, waiting for those who notice before it’s popular."
fi
}

# Finalised and Cleanup
DEKH "📦 Your Data Backup is Ready" "h"
DEKH "✅ Apps Added: $ADDCNT"
DEKH "👇 FLASH BELOW ZIP TO RESTORE 👇" "h#"
DEKH "📁 - $PACKFILE\n" 1

# Remove Bundle-Mods
(
sleep 0.2
rm -rf "$MODPATH" "$MODDIR/bundle-mods" "$VTD"
)&
