# Haxe Local Notifications

[![License](http://img.shields.io/:license-mit-blue.svg?style=flat-square)](https://github.com/Tw1ddle/samcodes-notifications/blob/master/LICENSE)

Local notifications support for Haxe OpenFL Android and iOS targets. See the demo [here](https://github.com/Tw1ddle/samcodes-notifications-demo).

## Features

* Schedule, manage and cancel local device notifications.
* Manage application icon notification badge counts.
* Open application when notification is tapped.
* Custom notification icons (on Android only).

If there is something you would like adding let me know. Pull requests welcomed too.

## Install

Get the [haxelib](http://lib.haxe.org/p/samcodes-notifications):

```bash
haxelib install samcodes-notifications
```

## Usage

Include the haxelib through Project.xml:
```xml
<haxelib name="samcodes-notifications" />
```

## Known Issues
Due to a bug you cannot cancel individual notifications on iOS, though they can be cancelled all together. This means that if you schedule notifications using the same slots, any older untriggered notifications will not be overridden on iOS, but will on Android.

Due to the way Android alarm management works, force-stopping an application always cancels scheduled notifications. Notifications cancelled this way will be rescheduled the next time the device is rebooted, or when the app is relaunched.

## Example

See the [demo app](https://github.com/Tw1ddle/samcodes-notifications-demo) for a complete example.

Android notifications with badging. Badging is done using [ShortcutBadger](https://github.com/leolin310148/ShortcutBadger):

![Screenshot of Android notification](https://github.com/Tw1ddle/samcodes-notifications-demo/blob/master/screenshots/notification-android.png?raw=true "Notification Android")

Android notification with custom notification icons:

![Screenshot of Android notification](https://github.com/Tw1ddle/samcodes-notifications-demo/blob/master/screenshots/notification-android-custom-icons.png?raw=true "Notification Android")

iOS notifications and badging:

![Screenshot of iOS notification](https://github.com/Tw1ddle/samcodes-notifications-demo/blob/master/screenshots/notification-ios.png?raw=true "Notification iOS")

## Notes
This haxelib was originally based on the [local notifications](https://github.com/byrobingames/localnotifications) extension for Stencyl by [byrobingames](https://github.com/byrobingames).
Android app icon badging support is provided by [ShortcutBadger](https://github.com/leolin310148/ShortcutBadger) by [Leo Lin](https://github.com/leolin310148), which is licensed under the Apache License, Version 2.0.

Use ```#if (android || ios)``` conditionals around your imports and calls to this library for cross platform projects, as there is no stub/fallback implementation included in the haxelib.

If you need to rebuild the iOS or simulator ndlls navigate to ```/project``` and run ```rebuild_ndlls.sh```.