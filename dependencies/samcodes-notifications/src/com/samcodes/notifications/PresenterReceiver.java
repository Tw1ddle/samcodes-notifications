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
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Build;
import android.R.dimen;
import android.support.v4.app.NotificationCompat;
import android.support.v4.app.NotificationCompat.Builder;
import android.view.Window;
import android.util.Log;
import com.samcodes.notifications.Common;
import org.haxe.extension.Extension;

public class PresenterReceiver extends BroadcastReceiver {
	@Override
	public void onReceive(Context context, Intent intent) {
		if(context == null || intent == null) {
			Log.i(Common.TAG, "Received notification presentation broadcast with null context or intent");
			return;
		}
		String action = intent.getAction();
		if(action == null) {
			Log.i(Common.TAG, "Received notification presentation broadcast with null action");
			return;
		}
		presentNotification(context, action); // Everything should be for presenting local device notifications
	}
	
	private static void presentNotification(Context context, String action) {
		SharedPreferences prefs = context.getSharedPreferences(action, Context.MODE_WORLD_READABLE);
		if(prefs == null) {
			Log.i(Common.TAG, "Failed to read notification preference data");
			return;
		}
		
		int slot = prefs.getInt(Common.SLOT_TAG, -1);
		if(slot == -1) {
			Log.i(Common.TAG, "Failed to read notification slot id");
			return;
		}
		String titleText = prefs.getString(Common.TITLE_TEXT_TAG, "");
		String subtitleText = prefs.getString(Common.SUBTITLE_TEXT_TAG, "");
		String messageBodyText = prefs.getString(Common.MESSAGE_BODY_TEXT_TAG, "");
		String tickerText = prefs.getString(Common.TICKER_TEXT_TAG, "");
		Boolean ongoing = prefs.getBoolean(Common.ONGOING_TAG, false);
		Boolean incrementBadgeCount = prefs.getBoolean(Common.INCREMENT_BADGE_COUNT_TAG, false);
		
		Common.erasePreference(context, slot);
		
		if(incrementBadgeCount) {
			Common.setApplicationIconBadgeNumber(context, Common.getApplicationIconBadgeNumber(context) + 1);
		}
		sendNotification(context, slot, titleText, subtitleText, messageBodyText, tickerText, ongoing);
	}
	
	// Actually send the local notification to the device
	private static void sendNotification(Context context, int slot, String titleText, String subtitleText, String messageBodyText, String tickerText, Boolean ongoing) {
		Context applicationContext = context.getApplicationContext();
		if(applicationContext == null) {
			Log.i(Common.TAG, "Failed to get application context");
			return;
		}
		
		// Get small application icon
		int smallIconId = android.R.drawable.ic_dialog_info;
		
		// Get large application icon
		int largeIconId = 0;
		try {
			PackageManager pm = context.getPackageManager();
			if(pm != null) {
				ApplicationInfo ai = pm.getApplicationInfo(Common.getPackageName(), 0);
				if(ai != null) {
					largeIconId = ai.icon;
				}
			}
		} catch (NameNotFoundException e) {
			Log.i(Common.TAG, "Failed to get application icon, falling back to default");
			largeIconId = android.R.drawable.ic_dialog_alert;
		}
		
		// Get large application icon
		Bitmap largeIcon = BitmapFactory.decodeResource(applicationContext.getResources(), largeIconId);
		
		// Scale it down if it's too big
		if(android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
			int width = android.R.dimen.notification_large_icon_width > 0 ? android.R.dimen.notification_large_icon_width : 150;
			int height = android.R.dimen.notification_large_icon_height > 0 ? android.R.dimen.notification_large_icon_height : 150;
			if(largeIcon.getWidth() > width || largeIcon.getHeight() > height) {
				largeIcon = Bitmap.createScaledBitmap(largeIcon, width, height, false);
			}
		}
		
		// Launch or open application on notification tap
		Intent intent = null;
		try {
			PackageManager pm = context.getPackageManager();
			if(pm != null) {
				String packageName = context.getPackageName();
				intent = pm.getLaunchIntentForPackage(packageName);
				intent.addCategory(Intent.CATEGORY_LAUNCHER); // Should already be set, but just in case
			}
		} catch (Exception e) {
			Log.i(Common.TAG, "Failed to get application launch intent");
		}
		
		if(intent == null) {
			Log.i(Common.TAG, "Falling back to empty intent");
			intent = new Intent();
		}
		
		PendingIntent pendingIntent = PendingIntent.getActivity(applicationContext, slot, intent, PendingIntent.FLAG_UPDATE_CURRENT);
		NotificationCompat.Builder builder = new NotificationCompat.Builder(applicationContext);
		builder.setAutoCancel(true);
		builder.setContentTitle(titleText);
		builder.setSubText(subtitleText);
		builder.setContentText(messageBodyText);
		builder.setTicker(tickerText);

		if(largeIcon != null) {
			builder.setLargeIcon(largeIcon);
		}
		builder.setSmallIcon(smallIconId);
		builder.setContentIntent(pendingIntent);
		builder.setOngoing(ongoing);
		builder.setWhen(System.currentTimeMillis());
		builder.setDefaults(NotificationCompat.DEFAULT_SOUND | NotificationCompat.DEFAULT_VIBRATE | NotificationCompat.DEFAULT_LIGHTS);
		builder.build();
		
		NotificationManager notificationManager = ((NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE));
		if(notificationManager != null) {
			notificationManager.notify(slot, builder.getNotification());
		}
	}
}