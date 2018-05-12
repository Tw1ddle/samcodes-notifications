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
		SharedPreferences prefs = context.getSharedPreferences(action, Context.MODE_PRIVATE);
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
		String largeIconName = prefs.getString(Common.LARGE_ICON_NAME_TAG, "");
		String smallIconName = prefs.getString(Common.SMALL_ICON_NAME_TAG, "");
		
		Common.erasePreference(context, slot);
		
		if(incrementBadgeCount) {
			Common.setApplicationIconBadgeNumber(context, Common.getApplicationIconBadgeNumber(context) + 1);
		}
		sendNotification(context, slot, titleText, subtitleText, messageBodyText, tickerText, ongoing, smallIconName, largeIconName);
	}
	
	// Actually send the local notification to the device
	private static void sendNotification(Context context, int slot, String titleText, String subtitleText, String messageBodyText, String tickerText, Boolean ongoing, String smallIconName, String largeIconName) {
		Context applicationContext = context.getApplicationContext();
		if(applicationContext == null) {
			Log.i(Common.TAG, "Failed to get application context");
			return;
		}
		
		// Get small notification icon id
		int smallIconId = getSmallIconId(smallIconName, applicationContext);
		
		// Get large application icon id
		int largeIconId = getLargeIconId(largeIconName, applicationContext);
		
		// Get large application icon bitmap
		Bitmap largeIcon = BitmapFactory.decodeResource(applicationContext.getResources(), largeIconId);
		
		// Scale it down if it's too big
		if(largeIcon != null && android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
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
				String packageName = Common.getPackageName();
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
	
	// Get Android resource id for an image given the name of the drawable
	// Note that drawable name should not include an extension like ".png"
	// Returns 0 on failure (Android Resources.getIdentifier also returns 0 if no such resource is found)
	private static int getDrawableResourceId(String name, Context applicationContext)
	{
		if(name == null) {
			return 0;
		}
		return applicationContext.getResources().getIdentifier(name, "drawable", Common.getPackageName());
	}
	
	// Get the small icon id to show with the notification. Falls back to a generic info icon
	// if we cannot find the named icon in Android resources
	private static int getSmallIconId(String smallIconName, Context applicationContext)
	{
		// Try to get the named icon, if one is given
		if(smallIconName != null && !smallIconName.isEmpty()) {
			int iconId = getDrawableResourceId(smallIconName, applicationContext);
			if(iconId != 0) {
				return iconId;
			}
		}
		
		Log.i(Common.TAG, "Failed to get custom small icon for notification, will fall back to generic alert icon");
		return android.R.drawable.ic_dialog_info;
	}
	
	// Get the large icon id to show with the notification. Falls back to the app icon if
	// we cannot find the named icon in Android resources, and then the generic alert icon if that fails
	private static int getLargeIconId(String largeIconName, Context applicationContext)
	{
		// Try to get the named icon, if one is given
		if(largeIconName != null && !largeIconName.isEmpty()) {
			int iconId = getDrawableResourceId(largeIconName, applicationContext);
			if(iconId != 0) {
				return iconId;
			}
		}
		
		Log.i(Common.TAG, "Failed to get custom large icon for notification, will fall back to generic icon");
		
		// Fall back to application icon
		try {
			PackageManager pm = applicationContext.getPackageManager();
			if(pm != null) {
				ApplicationInfo ai = pm.getApplicationInfo(Common.getPackageName(), 0);
				if(ai != null) {
					return ai.icon;
				}
			}
		} catch (NameNotFoundException e) {
			Log.i(Common.TAG, "Failed to get application icon, will fall back to default");
		}
		
		// Fall back to generic alert icon
		return android.R.drawable.ic_dialog_alert;
	}
}