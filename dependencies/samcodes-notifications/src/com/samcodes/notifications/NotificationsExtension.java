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
import me.leolin.shortcutbadger.ShortcutBadger;
import org.haxe.extension.Extension;

public class NotificationsExtension extends Extension {
	public static void scheduleLocalNotification(int slot, int triggerAfterMillis, String titleText, String subtitleText, String messageBodyText, String tickerText) {
		Long alertTime = System.currentTimeMillis() + triggerAfterMillis; // UTC time to schedule in milliseconds
		Common.writePreference(mainContext, slot, alertTime, titleText, subtitleText, messageBodyText, tickerText);
		PendingIntent intent = Common.scheduleLocalNotification(mainContext, slot, alertTime, titleText, subtitleText, messageBodyText, tickerText);
		Common.pendingIntents.put(slot, intent);
	}
	
	public static void cancelLocalNotification(int slot) {
		NotificationManager notificationManager = ((NotificationManager)mainContext.getSystemService(Context.NOTIFICATION_SERVICE));
		if(notificationManager != null) {
			notificationManager.cancel(slot);
		}
		
		AlarmManager alarmManager = ((AlarmManager)mainContext.getSystemService(Context.ALARM_SERVICE));
		PendingIntent intent = Common.pendingIntents.get(slot);
		if(intent != null && alarmManager != null) {
			alarmManager.cancel(intent);
		}
		Common.pendingIntents.remove(slot);
		
		Common.erasePreference(mainContext, slot);
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
			Integer slot = entry.getKey();
			Common.erasePreference(mainContext, slot);
		}
		Common.pendingIntents.clear();
	}
	
	public static boolean setApplicationIconBadgeNumber(int number) {
		if(number <= 0) {
			return ShortcutBadger.removeCount(mainContext);
		} else {
			return ShortcutBadger.applyCount(mainContext, number);
		}
	}
}