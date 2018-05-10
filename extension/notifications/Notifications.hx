package extension.notifications;

#if android
import lime.system.JNI;
#end

#if ios
import extension.notifications.PrimeLoader;
#end

#if (android || ios)
class Notifications {
	// Note, keeping these separate since the common parameters serve pretty different purposes
	#if android
	public static function scheduleLocalNotification(slot:Int, triggerAfterSecs:Float, titleText:String, subtitleText:String, messageBodyText:String, tickerText:String, incrementBadgeCount:Bool, ongoing=true):Void {
		schedule_local_notification(slot, triggerAfterSecs, titleText, subtitleText, messageBodyText, tickerText, incrementBadgeCount, ongoing);
	}
	#elseif ios
	public static function scheduleLocalNotification(slot:Int, triggerAfterSecs:Float, titleText:String, messageBodyText:String, actionButtonText:String, incrementBadgeCount:Bool):Void {
		schedule_local_notification.call(slot, triggerAfterSecs, titleText, messageBodyText, actionButtonText, incrementBadgeCount);
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
	private static var schedule_local_notification = bindJNI("scheduleLocalNotification", "(IFLjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ZZ)V");
	private static var cancel_local_notification = bindJNI("cancelLocalNotification", "(I)V");
	private static var cancel_local_notifications = bindJNI("cancelLocalNotifications", "()V");
	private static var get_application_icon_badge_number = bindJNI("getApplicationIconBadgeNumber", "()I");
	private static var set_application_icon_badge_number = bindJNI("setApplicationIconBadgeNumber", "(I)Z");
	#elseif ios
	private static var schedule_local_notification = PrimeLoader.load("samcodesnotifications_schedule_local_notification", "ifsssbv");
	private static var cancel_local_notification = PrimeLoader.load("samcodesnotifications_cancel_local_notification", "iv");
	private static var cancel_local_notifications = PrimeLoader.load("samcodesnotifications_cancel_local_notifications", "v");
	private static var get_application_icon_badge_number = PrimeLoader.load("samcodesnotifications_get_application_icon_badge_number", "i");
	private static var set_application_icon_badge_number = PrimeLoader.load("samcodesnotifications_set_application_icon_badge_number", "ib");
	#end
}
#end