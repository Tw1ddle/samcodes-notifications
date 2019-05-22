package extension.notifications;

#if android
import lime.system.JNI;
#end

#if ios
import extension.notifications.PrimeLoader;
#end

#if android

// Android uses the importance of a notification to determine how much the notification should interrupt the user (visually and audibly). The higher the importance of a notification, the more interruptive the notification will be.
// Mirrors NotificationImportance constants from Android 8.0 (API level 26)
@:enum abstract NotificationImportance(Int)
{
	var NONE = 0;
	var MIN = 1;
	var LOW = 2;
	var DEFAULT = 3;
	var HIGH = 4;
	var MAX = 5;
}

#end

#if (android || ios)
class Notifications {
	// Note, keeping these methods separate since even the common parameters here serve pretty different purposes
	// It would be better to wrap these methods if you use them a lot, as they might change in the future
	// See the demo project here for usage examples: https://github.com/Tw1ddle/samcodes-notifications-demo
	#if android
	
	/**
	   Schedules a local notification on Android
	   @param	slot The slot index of the notification (you should define a set of values for these using an enum abstract)
	   @param	triggerAfterSecs The number of seconds until the notification will be presented
	   @param	titleText The title text shown in the notification
	   @param	subtitleText The subtitle text shown in the notification
	   @param	messageBodyText The body/message text shown in the notification
	   @param	tickerText The ticker/status bar text shown in the notification (likely to be what's read by accessibility services too)
	   @param	incrementBadgeCount Whether to increment the application badge count when the notification is triggered
	   @param	isOngoing Whether the notification is the "ongoing" (persistent) notification type
	   @param	smallIconName The name of the small icon resource to show with the notification, will use generic icon if empty or null
	   @param	largeIconName The name of the large icon resource to show with the notification, will use application or generic icon if empty or null
	   @param	channelId Identifier for the channel that the notification will be assigned to. Starting in Android 8.0, notifications must be assigned a channel or they do not appear.
	   @param	channelName The display name of the channel that the notification will be assigned to.
	   @param	channelDescription The descriptive text for the channel that the notification will be assigned to.
	   @param	importance The importance of the notification. The higher the importance, the more interruptive the notification will be. Note this can only be set once per channel (i.e. the first time it's set, it sticks).
	**/
	public static function scheduleLocalNotification(
	slot:Int, triggerAfterSecs:Float, titleText:String, subtitleText:String, messageBodyText:String, tickerText:String, incrementBadgeCount:Bool, isOngoing:Bool, smallIconName:String, largeIconName:String, channelId:String, channelName:String, channelDescription:String, channelImportance:NotificationImportance):Void {
		schedule_local_notification(slot, triggerAfterSecs, titleText, subtitleText, messageBodyText, tickerText, incrementBadgeCount, isOngoing, smallIconName, largeIconName, channelId, channelName, channelDescription, channelImportance);
	}
	#elseif ios
	/**
	   Schedules a local notification on iOS
	   @param	slot The slot index of the notification (you should define a set of values for these using an enum abstract)
	   @param	triggerAfterSecs The number of seconds until the notification will be presented
	   @param	titleText The title text shown in the notification
	   @param	messageBodyText The body/message text shown in the notification
	   @param	actionButtonText The text shown on the action button associated with the notification
	   @param	incrementBadgeCount Whether to increment the application badge count when the notification is triggered
	**/
	public static function scheduleLocalNotification(slot:Int, triggerAfterSecs:Float, titleText:String, messageBodyText:String, actionButtonText:String, incrementBadgeCount:Bool):Void {
		schedule_local_notification.call(slot, triggerAfterSecs, titleText, messageBodyText, actionButtonText, incrementBadgeCount);
	}
	#end
	
	#if ios
	// Since about iOS 9+ you require user permission to show local notifications
	// See: https://developer.apple.com/documentation/usernotifications/asking_permission_to_use_notifications
	public static function requestNotificationPermissions():Void {
		request_notification_permissions.call();
	}
	#end
	
	public static function cancelLocalNotification(slot:Int):Void {
		#if android
		cancel_local_notification(slot);
		#elseif ios
		cancel_local_notification.call(slot); // Note use of call() seems required with HXCPP functions
		#end
	}
	
	public static function cancelLocalNotifications():Void {
		#if android
		cancel_local_notifications();
		#elseif ios
		cancel_local_notifications.call();
		#end
	}
	
	public static function getApplicationIconBadgeNumber():Int {
		#if android
		return get_application_icon_badge_number();
		#elseif ios
		return get_application_icon_badge_number.call();
		#end
	}
	
	public static function setApplicationIconBadgeNumber(number:Int):Bool {
		#if android
		return set_application_icon_badge_number(number);
		#elseif ios
		return set_application_icon_badge_number.call(number);
		#end
	}
	
	#if android
	private static inline var packageName:String = "com/samcodes/notifications/NotificationsExtension";
	private static inline function bindJNI(jniMethod:String, jniSignature:String) {
		return JNI.createStaticMethod(packageName, jniMethod, jniSignature);
	}
	private static var schedule_local_notification = bindJNI("scheduleLocalNotification", "(IFLjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ZZLjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V");
	private static var cancel_local_notification = bindJNI("cancelLocalNotification", "(I)V");
	private static var cancel_local_notifications = bindJNI("cancelLocalNotifications", "()V");
	private static var get_application_icon_badge_number = bindJNI("getApplicationIconBadgeNumber", "()I");
	private static var set_application_icon_badge_number = bindJNI("setApplicationIconBadgeNumber", "(I)Z");
	#elseif ios
	private static var request_notification_permissions = PrimeLoader.load("samcodesnotifications_request_notification_permissions", "v");
	private static var schedule_local_notification = PrimeLoader.load("samcodesnotifications_schedule_local_notification", "ifsssbv");
	private static var cancel_local_notification = PrimeLoader.load("samcodesnotifications_cancel_local_notification", "iv");
	private static var cancel_local_notifications = PrimeLoader.load("samcodesnotifications_cancel_local_notifications", "v");
	private static var get_application_icon_badge_number = PrimeLoader.load("samcodesnotifications_get_application_icon_badge_number", "i");
	private static var set_application_icon_badge_number = PrimeLoader.load("samcodesnotifications_set_application_icon_badge_number", "ib");
	#end
}
#end