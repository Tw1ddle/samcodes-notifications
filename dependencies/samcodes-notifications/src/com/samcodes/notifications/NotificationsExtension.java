package com.samcodes.notifications;

import android.app.AlarmManager;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import com.samcodes.notifications.Constants;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.Map;
import java.util.HashMap;
import org.haxe.extension.Extension;

public class NotificationsExtension extends Extension {
	static private HashMap<Integer, PendingIntent> intents = new HashMap<Integer, PendingIntent>();
	
	public static void scheduleLocalNotification(int id, int triggerAfterMillis, String titleText, String subtitleText, String messageBodyText, String tickerText) {
		SharedPreferences.Editor editor = mainContext.getSharedPreferences(Constants.ACTION_BASE_NAME + id, Context.MODE_WORLD_READABLE).edit();
		editor.putInt(Constants.ID_TAG, id);
		editor.putString(Constants.TITLE_TEXT_TAG, titleText);
		editor.putString(Constants.SUBTITLE_TEXT_TAG, subtitleText);
		editor.putString(Constants.MESSAGE_BODY_TEXT_TAG, messageBodyText);
		editor.putString(Constants.TICKER_TEXT_TAG, tickerText);
		editor.commit();
		
		Long alertTime = new GregorianCalendar().getTimeInMillis() + triggerAfterMillis; // Time to schedule in milliseconds
		AlarmManager alarmManager = (AlarmManager)mainContext.getSystemService(Context.ALARM_SERVICE);
		Intent alertIntent = new Intent(Constants.ACTION_BASE_NAME + id);
		
		// Schedule alarm. Note FLAG_UPDATE_CURRENT updates the intent if it's already active
		PendingIntent pendingIntent = PendingIntent.getBroadcast(mainActivity, id, alertIntent, PendingIntent.FLAG_UPDATE_CURRENT);
		intents.put(id, pendingIntent);
		
		alarmManager.set(AlarmManager.RTC_WAKEUP, alertTime, pendingIntent);
	}
	
	public static void cancelLocalNotification(int id) {
		((NotificationManager)mainContext.getSystemService(Context.NOTIFICATION_SERVICE)).cancel(id);
		PendingIntent intent = intents.get(id);
		if(intent == null) {
			return;
		}
		((AlarmManager)mainContext.getSystemService(Context.ALARM_SERVICE)).cancel(intent);
		intents.remove(id);
	}
	
	public static void cancelLocalNotifications() {
		((NotificationManager)mainContext.getSystemService(Context.NOTIFICATION_SERVICE)).cancelAll();
		
		for (Map.Entry<Integer, PendingIntent> entry : intents.entrySet()) {
			PendingIntent intent = entry.getValue();
			if(intent != null) {
				((AlarmManager)mainContext.getSystemService(Context.ALARM_SERVICE)).cancel(intent);
			}
		}
		intents.clear();
	}
}