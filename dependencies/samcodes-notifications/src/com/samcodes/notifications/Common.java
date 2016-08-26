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
import org.haxe.extension.Extension;

class Common {
	// Maps pending intent ids to their corresponding intents.
	// Shared between the broadcastReceiver (that populates it with any pending intents at device boot) and Haxe-facing notification scheduling code
	public static ConcurrentHashMap<Integer, PendingIntent> pendingIntents = new ConcurrentHashMap<Integer, PendingIntent>();
	
	public static final int MAX_NOTIFICATION_SLOTS = 10; // Maximum number of notification action ids to manage (e.g. 10 -> .Notification0-9)
	
	// Tags used for saving notification attributes to shared preferences for later use
	public static final String ID_TAG = "id";
	public static final String UTC_SCHEDULED_TIME = "scheduledtime";
	public static final String TITLE_TEXT_TAG = "titletext";
	public static final String SUBTITLE_TEXT_TAG = "subtitletext";
	public static final String MESSAGE_BODY_TEXT_TAG = "messagetext";
	public static final String TICKER_TEXT_TAG = "tickertext";
	
	public static String getPackageName() {
		return "::APP_PACKAGE::";
	}
	
	public static String getNotificationName(int id) {
		return getPackageName() + ".Notification" + id;
	}
	
	public static SharedPreferences getNotificationSettings(Context context, int id) {
		return context.getSharedPreferences(getNotificationName(id), Context.MODE_WORLD_READABLE);
	}
	
	// Write notification data to preferences
	public static void writePreference(Context context, int id, Long alertTime, String titleText, String subtitleText, String messageBodyText, String tickerText) {
		SharedPreferences.Editor editor = getNotificationSettings(context, id).edit();
		if(editor == null) {
			return;
		}
		editor.putInt(ID_TAG, id);
		editor.putLong(UTC_SCHEDULED_TIME, alertTime);
		editor.putString(TITLE_TEXT_TAG, titleText);
		editor.putString(SUBTITLE_TEXT_TAG, subtitleText);
		editor.putString(MESSAGE_BODY_TEXT_TAG, messageBodyText);
		editor.putString(TICKER_TEXT_TAG, tickerText);
		editor.commit();
	}
	
	// Erase notification data from preferences
	public static void erasePreference(Context context, int id) {
		SharedPreferences.Editor editor = getNotificationSettings(context, id).edit();
		if(editor == null) {
			return;
		}
		editor.clear();
		editor.commit();
	}
	
	// Schedule a local notification
	public static PendingIntent scheduleLocalNotification(Context context, int id, Long alertTime, String titleText, String subtitleText, String messageBodyText, String tickerText) {
		Intent alertIntent = new Intent(getNotificationName(id));
		PendingIntent pendingIntent = PendingIntent.getBroadcast(context, id, alertIntent, PendingIntent.FLAG_UPDATE_CURRENT); // Note FLAG_UPDATE_CURRENT updates the intent if it's already active
		AlarmManager alarmManager = (AlarmManager)context.getSystemService(Context.ALARM_SERVICE);
		if(alarmManager != null) {
			alarmManager.set(AlarmManager.RTC_WAKEUP, alertTime, pendingIntent);
		}
		return pendingIntent;
	}
}