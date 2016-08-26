package com.samcodes.notifications;

import android.app.AlarmManager;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import com.samcodes.notifications.Common;
import java.lang.System;
import java.util.Map;
import org.haxe.extension.Extension;

public class NotificationsExtension extends Extension {
	public static void scheduleLocalNotification(int id, int triggerAfterMillis, String titleText, String subtitleText, String messageBodyText, String tickerText) {
		Long alertTime = System.currentTimeMillis() + triggerAfterMillis; // UTC time to schedule in milliseconds
		Common.writePreference(mainContext, id, alertTime, titleText, subtitleText, messageBodyText, tickerText);
		PendingIntent intent = Common.scheduleLocalNotification(mainContext, id, alertTime, titleText, subtitleText, messageBodyText, tickerText);
		Common.pendingIntents.put(id, intent);
	}
	
	public static void cancelLocalNotification(int id) {
		NotificationManager notificationManager = ((NotificationManager)mainContext.getSystemService(Context.NOTIFICATION_SERVICE));
		if(notificationManager != null) {
			notificationManager.cancel(id);
		}
		
		AlarmManager alarmManager = ((AlarmManager)mainContext.getSystemService(Context.ALARM_SERVICE));
		PendingIntent intent = Common.pendingIntents.get(id);
		if(intent != null && alarmManager != null) {
			alarmManager.cancel(intent);
		}
		Common.pendingIntents.remove(id);
		
		Common.erasePreference(mainContext, id);
	}
	
	public static void cancelLocalNotifications() {
		NotificationManager notificationManager = ((NotificationManager)mainContext.getSystemService(Context.NOTIFICATION_SERVICE));
		if(notificationManager != null) {
			notificationManager.cancelAll();
		}
		
		AlarmManager alarmManager = ((AlarmManager)mainContext.getSystemService(Context.ALARM_SERVICE));
		for (Map.Entry<Integer, PendingIntent> entry : Common.pendingIntents.entrySet()) {
			PendingIntent intent = entry.getValue();
			if(intent != null && alarmManager != null) {
				alarmManager.cancel(intent);
			}
			Integer id = entry.getKey();
			Common.erasePreference(mainContext, id);
		}
		Common.pendingIntents.clear();
	}
}