# CHANGELOG

## 1.0.5 -> 1.0.6
 * Update for latest OpenFL support.
 * Update to latest version of ShortcutBadger.
 * No longer embedding the extension-v4 jar in the haxelib (install it via the Android SDK manager instead).
 * Added "ongoing" parameter for Android notifications to optionally make the notification the ongoing type.
 * Now interacting with SharedPreferences with ''MODE_PRIVATE'' instead of ''MODE_WORLD_READABLE''.

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