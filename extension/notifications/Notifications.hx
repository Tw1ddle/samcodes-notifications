package extension.notifications;
import cpp.Prime;

#if android
import openfl.utils.JNI;
#end

#if (android || ios)
class Notifications {
	// Must be called before use of any other methods in this class
	public static function init():Void {
		Notifications.initBindings();
	}
	
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

	private static function initBindings():Void {
		#if ios
		cpp.Lib.pushDllSearchPath("project/ndll/" + cpp.Lib.getBinDirectory());
		#end
		
		schedule_local_notification = initBinding("scheduleLocalNotification", "(IILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Z)V", "schedule_local_notification", "iissssbv");
		cancel_local_notification = initBinding("cancelLocalNotification", "(I)V", "cancel_local_notification", "iv");
		cancel_local_notifications = initBinding("cancelLocalNotifications", "()V", "cancel_local_notifications", "v");
		get_application_icon_badge_number = initBinding("getApplicationIconBadgeNumber", "()I", "get_application_icon_badge_number", "i");
		set_application_icon_badge_number = initBinding("setApplicationIconBadgeNumber", "(I)Z", "set_application_icon_badge_number", "ib");
	}
	
	private static inline function initBinding(jniMethod:String, jniSignature:String, primeMethod:String, primeSignature:String):Dynamic {
		#if android
		var binding = JNI.createStaticMethod(packageName, jniMethod, jniSignature);
		#end
		
		#if ios
		var binding = Prime.load(ndllName, ndllName + "_" + primeMethod, primeSignature, false);
		#end
		
		#if debug
		if (binding == null) {
			throw "Failed to bind method: " + jniMethod + ", " + jniSignature + ", " + primeMethod + ", " + primeSignature;
		}
		#end
		
		return binding;
	}
	
	#if android
	private static inline var packageName:String = "com/samcodes/notifications/NotificationsExtension";
	#end
	#if ios
	private static inline var ndllName:String = "samcodesnotifications";
	#end
	
	private static var schedule_local_notification:Dynamic = null;
	private static var cancel_local_notification:Dynamic = null;
	private static var cancel_local_notifications:Dynamic = null;
	private static var get_application_icon_badge_number:Dynamic = null;
	private static var set_application_icon_badge_number:Dynamic = null;
}
#end