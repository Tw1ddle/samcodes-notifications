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
import android.util.Log;
import com.samcodes.notifications.Common;
import java.lang.Math;
import org.haxe.extension.Extension;

public class BootReceiver extends BroadcastReceiver {
	@Override
	public void onReceive(Context context, Intent intent) {
		if(context == null || intent == null) {
			Log.i(Common.TAG, "Received boot broadcast with null context or intent");
			return;
		}
		String action = intent.getAction();
		if(action == null) {
			Log.i(Common.TAG, "Received boot broadcast with null action");
			return;
		}
		
		registerAlarmsPostBoot(context);
		
		// Set the last known badge number on the app icon at boot, in case it was forgotten between reboots
		Common.setApplicationIconBadgeNumber(context, Common.getApplicationIconBadgeNumber(context));
	}
	
	private static void registerAlarmsPostBoot(Context context) {
		Common.reregisterAlarms(context);
	}
}