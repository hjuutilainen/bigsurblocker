# Big Sur Blocker

Detect when `Install macOS Big Sur.app` installer application has launched, terminate the process and display an alert.

![bigsurblocker](https://raw.githubusercontent.com/hjuutilainen/bigsurblocker/main/screenshot.jpg)

This project is heavily inspired by Erik Berglund's [AppBlocker](https://github.com/erikberglund/AppBlocker). It uses the same underlying idea of registering and listening for NSWorkspace notifications when app has started up and then checking the CFBundleIdentifier of the launched app to identify a Big Sur installer launch.

# Why

Apple wants end users to upgrade to the latest macOS as soon as it becomes available. Depending on the software and policies your organization uses, this might be unacceptable. As an administrator, you currently have some options:
- Use an MDM to push a profile to delay updates for maximum of 90 days. This will however postpone _all_ updates, not just the macOS upgrade.
- If your fleet is enrolled in an MDM, you can use `softwareupdate --ignore` to hide certain updates. This will result in a highly broken user experience where the system thinks it has an update pending but it is unable to download and install it. Apple has also decided that only MDM enrolled systems can use the `--ignore` flag.
- If you are already using a binary authorization system such as Googles [Santa](https://github.com/google/santa), you should use it but deploying a system like Santa only for blocking Big Sur might be unfeasible.

# How

The `bigsurblocker` binary is installed in `/usr/local/bin` and is launched for each user through a launch agent. This means that the binary is running in the user session and therefore has the privileges of the current user. It runs silently in the background and listens for app launch notifications. As soon as the user launches the macOS installer application, the binary (forcefully) terminates it and displays a warning message.

# Requirements

The binary requires at least macOS 10.9, however I've only tested this on macOS 10.13 and 10.14.

# Configuration

All configuration is optional. If needed, the alert title and text can be set through a configuration profile. Use `com.hjuutilainen.bigsurblocker` as the domain and `AlertTitle` and `AlertText` as the keys.

# Installation

Download a prebuilt package from the [Releases page](https://github.com/hjuutilainen/bigsurblocker/releases) and deploy with your favorite method. The package is signed and notarized.

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

# License

Big Sur Blocker is licensed under [the MIT License](https://github.com/hjuutilainen/bigsurblocker/blob/main/LICENSE).
