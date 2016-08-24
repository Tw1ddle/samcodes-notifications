package extension.notifications;

#if android
import openfl.utils.JNI;
#end

#if ios
import flash.Lib;
#end

// TODO rewrite using "HXCPP PRIME" stuff
#if (android || ios)
class Notifications {
	// Must be called before use of any other methods in this class
	public static function init():Void {
		Notifications.initBindings();
	}
	
	// Note, keeping these separate since the common parameters serve pretty different purposes
	#if android
	public static function scheduleLocalNotification(id:Int, triggerAfterMillis:Int, titleText:String, subtitleText:String, messageBodyText:String, tickerText:String):Void {
		schedule_local_notification(id, triggerAfterMillis, titleText, subtitleText, messageBodyText, tickerText);
	}
	#elseif ios
	public static function scheduleLocalNotification(id:Int, triggerAfterMillis:Int, titleText:String, messageBodyText:String, actionButtonText:String):Void {
		schedule_local_notification(id, triggerAfterMillis, titleText, messageBodyText, actionButtonText);
	}
	#end
	
	public static function cancelLocalNotification(id:Int):Void {
		cancel_local_notification(id);
	}
	
	public static function cancelLocalNotifications():Void {
		cancel_local_notifications();
	}

	private static function initBindings() {
		schedule_local_notification = initBinding("scheduleLocalNotification", "(IILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V", "schedule_local_notification", 5);
		cancel_local_notification = initBinding("cancelLocalNotification", "(I)V", "cancel_local_notification", 1);
		cancel_local_notifications = initBinding("cancelLocalNotifications", "()V", "cancel_local_notifications", 0);
	}
	
	private static inline function initBinding(jniMethod:String, jniSignature:String, ndllMethod:String, argCount:Int):Dynamic {
		#if android
		var binding = JNI.createStaticMethod(packageName, jniMethod, jniSignature);
		#end
		
		#if ios
		var binding = Lib.load(ndllName, ndllName + "_" + ndllMethod, argCount);
		#end
		
		#if debug
		if (binding == null) {
			throw "Failed to bind method: " + jniMethod + ", " + jniSignature + ", " + ndllMethod + " (" + Std.string(argCount) + ").";
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
}
#end