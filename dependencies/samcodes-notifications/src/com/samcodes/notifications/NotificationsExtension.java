package com.samcodes.notifications;

import android.app.AlarmManager;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.util.Log;
import com.samcodes.notifications.Common;
import java.lang.System;
import java.util.Map;
import me.leolin.shortcutbadger.ShortcutBadger;
import org.haxe.extension.Extension;

public class NotificationsExtension extends Extension {
	@Override public void onCreate (Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		// The extension should only be created when the app is launched
		// So at this point, local notifications could be have been cancelled due to a previous force-stopping of the app
		// So we attempt to re-register all pending notifications
		Common.reregisterAlarms(Extension.mainContext);
	}
	
	public static void scheduleLocalNotification(int slot, float triggerAfterSecs, String titleText, String subtitleText, String messageBodyText, String tickerText, boolean incrementBadgeCount, boolean ongoing, String smallIconName, String largeIconName, String channelId, String channelName, String channelDescription, int channelImportance) {
		Long alertTime = System.currentTimeMillis() + (long)(triggerAfterSecs * 1000.0f); // UTC time to schedule in milliseconds
		Common.writePreference(mainContext, slot, alertTime, titleText, subtitleText, messageBodyText, tickerText, incrementBadgeCount, ongoing, smallIconName, largeIconName, channelId, channelName, channelDescription, channelImportance);
		PendingIntent intent = Common.scheduleLocalNotification(mainContext, slot, alertTime);
		Common.pendingIntents.put(slot, intent);
	}
	
	public static void cancelLocalNotification(int slot) {
		Log.i(Common.TAG, "Cancelling local notification");
		
		NotificationManager notificationManager = ((NotificationManager)mainContext.getSystemService(Context.NOTIFICATION_SERVICE));
		if(notificationManager != null) {
			notificationManager.cancel(slot);
		}
		
		AlarmManager alarmManager = ((AlarmManager)mainContext.getSystemService(Context.ALARM_SERVICE));
		PendingIntent intent = Common.pendingIntents.get(slot);
		if(intent != null && alarmManager != null) {
			alarmManager.cancel(intent);
		} else {
			Log.i(Common.TAG, "Failed to remove notification from alarmManager, was it scheduled in the first place?");
		}
		Common.pendingIntents.remove(slot);
		Common.erasePreference(mainContext, slot);
	}
	
	public static void cancelLocalNotifications() {
		Log.i(Common.TAG, "Cancelling all local notifications");
		
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
	
	public static int getApplicationIconBadgeNumber() {
		return Common.getApplicationIconBadgeNumber(mainContext);
	}
	
	public static boolean setApplicationIconBadgeNumber(int number) {
		return Common.setApplicationIconBadgeNumber(mainContext, number);
	}
}