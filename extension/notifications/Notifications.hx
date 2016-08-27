package extension.notifications;

#if android
import openfl.utils.JNI;
#end

#if ios
import extension.notifications.PrimeLoader;
#end

#if (android || ios)
class Notifications {
	// Note, keeping these separate since the common parameters serve pretty different purposes
	#if android
	public static function scheduleLocalNotification(slot:Int, triggerAfterMillis:Int, titleText:String, subtitleText:String, messageBodyText:String, tickerText:String, incrementBadgeCount:Bool):Void {
		schedule_local_notification(slot, triggerAfterMillis, titleText, subtitleText, messageBodyText, tickerText, incrementBadgeCount);
	}
	#elseif ios
	public static function scheduleLocalNotification(slot:Int, triggerAfterMillis:Int, titleText:String, messageBodyText:String, actionButtonText:String, incrementBadgeCount:Bool):Void {
		schedule_local_notification(slot, triggerAfterMillis, titleText, messageBodyText, actionButtonText, incrementBadgeCount);
	}
	#end
	
	public static function cancelLocalNotification(slot:Int):Void {
		cancel_local_notification(slot);
	}
	
	public static function cancelLocalNotifications():Void {
		cancel_local_notifications();
	}
	
	public static function getApplicationIconBadgeNumber():Int {
		return get_application_icon_badge_number();
	}
	
	public static function setApplicationIconBadgeNumber(number:Int):Bool {
		return set_application_icon_badge_number(number);
	}

	#if android
	private static inline var packageName:String = "com/samcodes/notifications/NotificationsExtension";
	private static inline function bindJNI(jniMethod:String, jniSignature:String):Dynamic {
		return JNI.createStaticMethod(packageName, jniMethod, jniSignature);
	}
	private static var schedule_local_notification:Dynamic = bindJNI("scheduleLocalNotification", "(IILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Z)V");
	private static var cancel_local_notification:Dynamic = bindJNI("cancelLocalNotification", "(I)V");
	private static var cancel_local_notifications:Dynamic = bindJNI("cancelLocalNotifications", "()V");
	private static var get_application_icon_badge_number:Dynamic = bindJNI("getApplicationIconBadgeNumber", "()I");
	private static var set_application_icon_badge_number:Dynamic = bindJNI("setApplicationIconBadgeNumber", "(I)Z");
	#elseif ios
	private static var schedule_local_notification:Dynamic = PrimeLoader.load("samcodesnotifications_schedule_local_notification", "iissssbv");
	private static var cancel_local_notification:Dynamic = PrimeLoader.load("samcodesnotifications_cancel_local_notification", "iv");
	private static var cancel_local_notifications:Dynamic = PrimeLoader.load("samcodesnotifications_cancel_local_notifications", "v");
	private static var get_application_icon_badge_number:Dynamic = PrimeLoader.load("samcodesnotifications_get_application_icon_badge_number", "i");
	private static var set_application_icon_badge_number:Dynamic = PrimeLoader.load("samcodesnotifications_set_application_icon_badge_number", "ib");
	#end
}
#end