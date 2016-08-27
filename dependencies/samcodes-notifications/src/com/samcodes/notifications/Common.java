package com.samcodes.notifications;

import android.app.Activity;
import android.app.AlarmManager;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.pm.ApplicationInfo;
import android.view.Window;
import java.util.concurrent.ConcurrentHashMap;
import me.leolin.shortcutbadger.ShortcutBadger;
import org.haxe.extension.Extension;

class Common {
	// Maps pending intent ids to their corresponding intents.
	// Shared between the broadcastReceiver (that populates it with any pending intents at device boot) and Haxe-facing notification scheduling code
	public static ConcurrentHashMap<Integer, PendingIntent> pendingIntents = new ConcurrentHashMap<Integer, PendingIntent>();
	
	public static final int MAX_NOTIFICATION_SLOTS = 10; // Maximum number of notification action ids to manage (e.g. 10 -> .Notification0-9)
	
	// Tag used for keeping track of last application icon badge count
	public static final String LAST_BADGE_COUNT_TAG = "lastbadgecount";
	
	// Tags used for saving notification attributes to shared preferences for later use
	public static final String SLOT_TAG = "id";
	public static final String UTC_SCHEDULED_TIME = "scheduledtime";
	public static final String TITLE_TEXT_TAG = "titletext";
	public static final String SUBTITLE_TEXT_TAG = "subtitletext";
	public static final String MESSAGE_BODY_TEXT_TAG = "messagetext";
	public static final String TICKER_TEXT_TAG = "tickertext";
	public static final String INCREMENT_BADGE_COUNT_TAG = "incrementbadge";
	
	public static String getPackageName() {
		return "::APP_PACKAGE::";
	}
	
	public static String getNotificationName(int slot) {
		return getPackageName() + ".Notification" + slot;
	}
	
	public static SharedPreferences getNotificationSettings(Context context, int slot) {
		return context.getSharedPreferences(getNotificationName(slot), Context.MODE_WORLD_READABLE);
	}
	
	public static SharedPreferences getApplicationIconBadgeSettings(Context context) {
		return context.getSharedPreferences("notificationsiconbadge", Context.MODE_WORLD_READABLE);
	}
	
	// Write notification data to preferences
	public static void writePreference(Context context, int slot, Long alertTime, String titleText, String subtitleText, String messageBodyText, String tickerText, boolean incrementBadgeCount) {
		SharedPreferences.Editor editor = getNotificationSettings(context, slot).edit();
		if(editor == null) {
			return;
		}
		editor.putInt(SLOT_TAG, slot);
		editor.putLong(UTC_SCHEDULED_TIME, alertTime);
		editor.putString(TITLE_TEXT_TAG, titleText);
		editor.putString(SUBTITLE_TEXT_TAG, subtitleText);
		editor.putString(MESSAGE_BODY_TEXT_TAG, messageBodyText);
		editor.putString(TICKER_TEXT_TAG, tickerText);
		editor.putBoolean(INCREMENT_BADGE_COUNT_TAG, incrementBadgeCount);
		editor.commit();
	}
	
	// Erase notification data from preferences
	public static void erasePreference(Context context, int slot) {
		SharedPreferences.Editor editor = getNotificationSettings(context, slot).edit();
		if(editor == null) {
			return;
		}
		editor.clear();
		editor.commit();
	}
	
	// Schedule a local notification
	public static PendingIntent scheduleLocalNotification(Context context, int slot, Long alertTime, String titleText, String subtitleText, String messageBodyText, String tickerText) {
		Intent alertIntent = new Intent(getNotificationName(slot));
		PendingIntent pendingIntent = PendingIntent.getBroadcast(context, slot, alertIntent, PendingIntent.FLAG_UPDATE_CURRENT); // Note FLAG_UPDATE_CURRENT updates the intent if it's already active
		AlarmManager alarmManager = (AlarmManager)context.getSystemService(Context.ALARM_SERVICE);
		if(alarmManager != null) {
			alarmManager.set(AlarmManager.RTC_WAKEUP, alertTime, pendingIntent);
		}
		return pendingIntent;
	}
	
	// Get application icon badge number
	public static int getApplicationIconBadgeNumber(Context context) {
		SharedPreferences prefs = getApplicationIconBadgeSettings(context);
		if(prefs == null) {
			return 0;
		}
		return prefs.getInt(LAST_BADGE_COUNT_TAG, 0);
	}
	
	// Set application icon badge number
	public static boolean setApplicationIconBadgeNumber(Context context, int number) {
		SharedPreferences.Editor editor = getApplicationIconBadgeSettings(context).edit();
		if(editor == null) {
			return false;
		}
		editor.putInt(LAST_BADGE_COUNT_TAG, number);
		editor.commit();
		
		if(number <= 0) {
			return ShortcutBadger.removeCount(context);
		} else {
			return ShortcutBadger.applyCount(context, number);
		}
	}
}