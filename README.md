# Haxe Local Notifications

Local notifications support for OpenFL Android/iOS targets.

## Features

* Schedule, manage and cancel local notifications.
* ~~Manage app icon notification badge counts.~~

If there is something you would like adding let me know. Pull requests welcomed too.

## Install

```bash
haxelib install samcodes-notifications
```

## Usage

Include the haxelib through Project.xml:
```xml
<haxelib name="samcodes-notifications" />
```

## Example

See the [demo app](https://github.com/Tw1ddle/samcodes-notifications-demo) for a complete example.

![Screenshot of Android notification](https://github.com/Tw1ddle/samcodes-notifications-demo/blob/master/screenshots/notification-android.gif?raw=true "Notification Android")

![Screenshot of iOS notification](https://github.com/Tw1ddle/samcodes-notifications-demo/blob/master/screenshots/notification-ios.gif?raw=true "Notification iOS")

## Notes
The haxelib is based on the [local notifications](https://github.com/byrobingames/localnotifications) extension for Stencyl by [byrobingames](https://github.com/byrobingames).

Use ```#if (android || ios)``` conditionals around your imports and calls to this library for cross platform projects, as there is no stub/fallback implementation included in the haxelib.

If you need to rebuild the iOS or simulator ndlls navigate to ```/project``` and run ```rebuild_ndlls.sh```.