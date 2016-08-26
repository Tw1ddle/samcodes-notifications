package com.samcodes.notifications;

import android.app.Activity;
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
import android.support.v4.app.NotificationCompat;
import android.support.v4.app.NotificationCompat.Builder;
import android.view.Window;
import com.samcodes.notifications.Common;
import org.haxe.extension.Extension;

public class NotificationPresenterReceiver extends BroadcastReceiver {
	@Override
	public void onReceive(Context context, Intent intent) {
		if(context == null || intent == null) {
			return;
		}
		String action = intent.getAction();
		if(action == null) {
			return;
		}
		presentNotification(context, action); // Everything should be for presenting local device notifications
	}
	
	private static void presentNotification(Context context, String action) {
		SharedPreferences prefs = context.getSharedPreferences(action, Context.MODE_WORLD_READABLE);
		if(prefs == null) {
			return;
		}
		
		int id = prefs.getInt(Common.ID_TAG, -1);
		if(id == -1) {
			return;
		}
		String titleText = prefs.getString(Common.TITLE_TEXT_TAG, "");
		String subtitleText = prefs.getString(Common.SUBTITLE_TEXT_TAG, "");
		String messageBodyText = prefs.getString(Common.MESSAGE_BODY_TEXT_TAG, "");
		String tickerText = prefs.getString(Common.TICKER_TEXT_TAG, "");
		
		Common.erasePreference(context, id);
		sendNotification(context, id, titleText, subtitleText, messageBodyText, tickerText);
	}
	
	// Actually send the local notification to the device
	private static void sendNotification(Context context, int id, String titleText, String subtitleText, String messageBodyText, String tickerText) {
		Context applicationContext = context.getApplicationContext();
		if(applicationContext == null) {
			return;
		}
		
		int iconId = 0;
		try {
			PackageManager pm = context.getPackageManager();
			if(pm != null) {
				ApplicationInfo ai = pm.getApplicationInfo(Common.getPackageName(), 0);
				if(ai != null) {
					iconId = ai.icon;
				}
			}
		} catch (NameNotFoundException e) {
			iconId = android.R.drawable.ic_dialog_info;
		}
		
		PendingIntent pendingIntent = PendingIntent.getActivity(applicationContext, id, new Intent(), PendingIntent.FLAG_UPDATE_CURRENT);
		NotificationCompat.Builder builder = new NotificationCompat.Builder(applicationContext);
		builder.setAutoCancel(true);
		builder.setContentTitle(titleText);
		builder.setSubText(subtitleText);
		builder.setContentText(messageBodyText);
		builder.setTicker(tickerText);
		builder.setSmallIcon(iconId);
		builder.setContentIntent(pendingIntent);
		builder.setOngoing(false);
		builder.setWhen(System.currentTimeMillis());
		builder.setDefaults(NotificationCompat.DEFAULT_SOUND | NotificationCompat.DEFAULT_VIBRATE | NotificationCompat.DEFAULT_LIGHTS);
		builder.build();
		
		NotificationManager notificationManager = ((NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE));
		if(notificationManager != null) {
			notificationManager.notify(id, builder.getNotification());
		}
	}
}