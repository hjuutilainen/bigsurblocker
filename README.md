# Big Sur Blocker

Detect when `Install macOS Big Sur.app` installer application has launched, terminate the process and display an alert.

This project is heavily inspired by Erik Berglund's [AppBlocker](https://github.com/erikberglund/AppBlocker). It uses the same underlying idea of registering and listening for NSWorkspace notifications when app has started up and then checking the CFBundleIdentifier of the launched app to identify a Big Sur installer launch.

# Requirements

The binary requires at least macOS 10.9, however I've only tested this on macOS 10.13 and 10.14.

# Configuration

All configuration is optional. If needed, the alert title and text can be set through a configuration profile. Use `com.hjuutilainen.bigsurblocker` as the domain and `AlertTitle` and `AlertText` as the keys.

# Installation

Download the prebuilt package and deploy with your favorite method. The package is signed and notarized.

# Uninstall

To fully uninstall `bigsurblocker`, run the following (as root or with sudo):

```
current_user_uid=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/UID :/ && ! /loginwindow/ { print $3 }' )

launchd_item_path="/Library/LaunchAgents/com.hjuutilainen.bigsurblocker.plist"
launchctl bootout gui/${current_user_uid} "${launchd_item_path}"

rm -f /Library/LaunchAgents/com.hjuutilainen.bigsurblocker.plist
rm -f /usr/local/bin/bigsurblocker

pkgutil --forget com.hjuutilainen.bigsurblocker
```
