# CHANGELOG

## 1.0.6 -> 1.0.7
 * Update to latest version of ShortcutBadger.
 * Changes for Android Oreo support, adding required channel and importance fields to notifications (old scheduled notifications will be assigned to a channel called "Pre-Android Oreo notifications").

## 1.0.5 -> 1.0.6
 * Update for latest OpenFL support.
 * Update to latest version of ShortcutBadger.
 * No longer embedding the extension-v4 jar in the haxelib (install it via the Android SDK manager instead).
 * Added "ongoing" parameter for Android notifications to optionally make the notification the ongoing type.
 * Added "smallIconName" and "largeIconName" parameters for Android notifications, for optionally specifying custom notification icons from your Android package resources.
 * Now attempts to reschedule notifications on app launch on Android, for the case force-stopping resulted in alarms being cancelled.
 * Now using SharedPreferences with ''MODE_PRIVATE'' instead of ''MODE_WORLD_READABLE''.

## 1.0.4 -> 1.0.5
 * Update to latest version of ShortcutBadger, fix badging error affecting some Android devices.

## 1.0.3 -> 1.0.4
 * Fix bug displaying high dpi notification icons on some devices.

## 1.0.2 -> 1.0.3
* Minor tweaks to Android notification icon appearances.

## 1.0.1 -> 1.0.2
* Breaking change - notification delays must now be specified in seconds.
* Work around another integer overflow bug for long-term notifications.

## 1.0.0 -> 1.0.1
* Update to latest ShortcutBadger, for better Samsung phone badging support.
* Fix 38 day (integer overflow) limit when scheduling notifications.

## 1.0.0
* Initial release