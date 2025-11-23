# 📀 Data Backup
> A Sub-Module of [🗃️ Bundle Mods](https://github.com/ShivamXD6/Bundle-Mods) to Backup your User Apps with their Data. Much Faster than Swift Backup or other similar Apps*.

[![Downloads](https://img.shields.io/github/downloads/ShivamXD6/Data-Backup/total?color=green&style=for-the-badge)](https://github.com/ShivamXD6/Data-Backup/releases/latest)
[![Release](https://img.shields.io/github/v/release/ShivamXD6/Data-Backup?style=for-the-badge)](https://github.com/ShivamXD6/Data-Backup/releases/latest)
[![Join Build Bytes](https://img.shields.io/badge/Join-Build%20Bytes-2CA5E0?style=for-the-badge&logo=telegram)](https://telegram.me/BuildBytes)
[![Join Chat](https://img.shields.io/badge/Join%20Chat-Build%20Bytes%20Discussion-2CA5E0?style=for-the-badge&logo=telegram)](https://telegram.me/BuildBytesDiscussion)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![Root](https://img.shields.io/badge/Root-ff0000?style=for-the-badge&logo=superuser&logoColor=white)
![Magisk](https://img.shields.io/badge/Magisk-8A2BE2?style=for-the-badge&logo=magisk&logoColor=white)
![KernelSU](https://img.shields.io/badge/KernelSU-000000?style=for-the-badge&logo=linux&logoColor=white)
![APatch](https://img.shields.io/badge/APatch-FF6B00?style=for-the-badge&logo=android&logoColor=white)

## 🚀 **Key Features of the Module**

### 🚀 Faster Backup & Restore  
- Tested to be **~66.7% (≈3×) faster** than Swift Backup.*  
- Real-world results may vary based on conditions.

### 📉 Better Compression  
- Compresses **APK + Splits** also, unlike Swift Backup which skips apk and splits files compression.  
- Noticeable size savings:  
  - **~3% or more smaller** for 1 app  
  - **~15% or more smaller** for 5 or more apps

### 📦 Ultra-Lightweight  
- **~1.3 MB zip size** - extremely small and efficient.

### 🔐 Advanced Permission Handling  
- **Per-app granted or all available permissions** support.  
- **Per-app Android ID** support for accurate restore.

### 🔄 No Installation Required  
- Just **flash and use** - the module **auto-removes itself** after completing backup/restore.

### ⚡ Smart One-Time Selection  
- Select **different parts for different apps** in one go.  
- Unlike Swift Backup, **no repeated selection** required for data/apk-only combos.

### 🧑‍💻 Open-Source  
- Fully open, but **main binaries are pre-compiled** to prevent tampering.

## 📖 Documentation

  ## SD Card Support?
  - Yes, it supports sdcard you will prompt to select for backup or restore, if there's any sdcard exist.

  ## Can I rename #Backup folder to something else?
  - Yes you can, just keep `.bundle-mods` file in it to check later if it's a backup folder or not.
  
  ## Selection Style:
  - Delete temporary Files or placeholders to select modules or apps in `Delete_To_Select` folder.

  ## Do I have to reboot after backup or restore?
  - No, unless you're also restoring the Android ID for the app.
  
  ## User Apps

  ### Selection Method for Components/Parts of Apps
  - If you select app only, and delete it's temporary/placeholder file, it will auto select available parts (except Android ID or All Available Permissions)
  - For selecting specific parts, select parts and apps (which you want to backup for the apps simultaneously)
  
  ### Why it's faster then apps like Swift Backup?
  - It uses ZAPDOS (zstd) with tar as it's compressing binary, which is much faster then zip or other binaries.
  - For Batch backup or installation, it uses Parallel Processing with Decreasing order of Apps sizes.
  - Also for Batch apps installation, it install app and runs optimization for that particular app in Background, meanwhile it install the next app which saves time.
  - [Click to Check the Comparison Between Swift Backup and Data Backup Here](https://telegram.me/buildbytes/142)
  
  ### What it backups?
  - `#App` - App (including splits)
  - `#Data` - Data (from /data/data)
  - `#UserDe` (included with data default) - User Direct Encryption (from /data/user_de)
  - `#ExtData` - External Data (from /Internal Storage/Android/data)
  - `#Media` - Media (from /Internal Storage/Android/media)
  - `#Obb` - OBB (from /Internal Storage/Android/obb)
  - `Granted Permissions` by default backup.
  - `#PermAll` - All Supported or Available Permissions (not only granted one)
  - `#AndroidID` - SSAID (from /data/system/users/0/settings_ssaid.xml)

  ## Why Some Binaries have Pokemon names?
  - It's just for fun XD, anyways the actual names of the binaries are:
  - Snorlax = zip binary
  - Porygon Z = aapt binary
  - Zapdos = zstd binary

## 📥 Installation Guide

### Just flash Module and follow the instructions display on your screen :)
### [Created Modules pack example here](https://t.me/buildbytes/54)

> [!NOTE]
> This module doesn’t install itself. It just helps you to build or install your modules pack.

## 🙏 Support & Donations

If you find Bundle-Mods helpful and want to support development, you can donate here:

💰 **PayPal:** [Donate via PayPal](https://paypal.me/ShivamXD6)

📲 **SuperMoney:** UPI ID - **shivam.dhage@superyes**

🔗 **GPay UPI QR Code:** [Donate via UPI QR](https://i.ibb.co/5g4J2RXR/1f38d6d7-a8a2-4696-88e6-9cf503e0592c.png)

Every contribution helps keep the project alive and improved! Thank you! 😊

## 🤝 Contribute
### Want to help improve this project?
Even if you don't know coding much you can contribute to data.sh for modules data paths :)
