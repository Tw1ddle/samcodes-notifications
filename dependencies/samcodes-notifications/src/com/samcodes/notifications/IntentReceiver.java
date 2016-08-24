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
import android.view.Window;
import com.samcodes.notifications.Constants;
import org.haxe.extension.Extension;

public class IntentReceiver extends BroadcastReceiver {
	@Override
	public void onReceive(Context context, Intent intent) {
		if ("android.intent.action.BOOT_COMPLETED".equals(intent.getAction())) {
			//Intent serviceIntent = new Intent(::APP_PACKAGE::); // TODO let's re-register notifications on boot?
			//context.getSharedPreferences(
			return;
		}
		
		SharedPreferences prefs = context.getSharedPreferences(intent.getAction(), Context.MODE_WORLD_READABLE);
		int id = prefs.getInt(Constants.ID_TAG, 1);
		String titleText = prefs.getString(Constants.TITLE_TEXT_TAG, "");
		String subtitleText = prefs.getString(Constants.SUBTITLE_TEXT_TAG, "");
		String messageBodyText = prefs.getString(Constants.MESSAGE_BODY_TEXT_TAG, "");
		String tickerText = prefs.getString(Constants.TICKER_TEXT_TAG, "");
		
		int iconID = 0;
		try {
			PackageManager pm = context.getPackageManager();
			String pkg = "::APP_PACKAGE::";
			ApplicationInfo ai = pm.getApplicationInfo(pkg, 0);
			iconID = ai.icon;
		} catch (NameNotFoundException e) {
			iconID = android.R.drawable.ic_dialog_info;
		}
		
		PendingIntent pendingIntent = PendingIntent.getActivity(context.getApplicationContext(), id, new Intent(), PendingIntent.FLAG_UPDATE_CURRENT);
		NotificationCompat.Builder builder = new NotificationCompat.Builder(context.getApplicationContext());
		builder.setAutoCancel(true);
		builder.setContentTitle(titleText);
		builder.setSubText(subtitleText);
		builder.setContentText(messageBodyText);
		builder.setTicker(tickerText);
		builder.setSmallIcon(iconID);
		builder.setContentIntent(pendingIntent);
		builder.setOngoing(false);
		builder.setWhen(System.currentTimeMillis());
		builder.setDefaults(NotificationCompat.DEFAULT_SOUND | NotificationCompat.DEFAULT_VIBRATE | NotificationCompat.DEFAULT_LIGHTS);
		builder.build();
		
		((NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE)).notify(id, builder.getNotification());
	}
}