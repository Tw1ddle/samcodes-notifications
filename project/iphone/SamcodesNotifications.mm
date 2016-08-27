#include "SamcodesNotifications.h"

#import <UIKit/UIKit.h>

#define kShouldNotificationIncrementBadgeKey @"kIncrementBadgeKey"

@interface NotificationsController : NSObject<UIApplicationDelegate>
@end

@implementation NotificationsController

- (void)application:(UIApplication*)application didRegisterUserNotificationSettings:(UIUserNotificationSettings*)notificationSettings
{
    [application registerForRemoteNotifications];
}

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
	// Request permissions to provide local notifications
	UIRemoteNotificationType types = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert;
	if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) // iOS 8 and above
	{
		[[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:types categories:nil]];
	}
	else
	{
		[[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
	}
}

- (void)application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification*)notification
{
	// This should be triggered if the app is active in the foreground when a local notification is received
	// Or if the user just launched the app from a notification
}

- (void)scheduleLocalNotification:(int)slot withTimeInterval:(int)timeInterval withTitle:(NSString*)title withBody:(NSString*)messageBody withAction:(NSString*)action
{
	UILocalNotification* notification = [[UILocalNotification alloc] init];
	notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
	notification.timeZone = [NSTimeZone defaultTimeZone];
	notification.repeatInterval = nil;
	notification.alertBody = messageBody;
	
	if ([notification respondsToSelector:@selector(alertTitle)]) // iOS 8.2 and above
	{
		if([title length] != 0)
		{
			notification.alertTitle = title;
		}
	}
	if([action length] != 0)
	{
		notification.alertAction = action;
	}
	
	notification.soundName = UILocalNotificationDefaultSoundName;
	
	[[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)cancelLocalNotification:(int)slot
{
	NSMutableArray* pendingNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
	if (pendingNotifications.count != 0)
	{
		for (UILocalNotification* notification in pendingNotifications)
		{
			// TODO check userdata for id key
			// TODO if matching, then grab and cancel it, and recalculate local badge counts
			//[[UIApplication sharedApplication] cancelLocalNotification:notification];
			//if([getApplicationIconBadgeNumber] > 0)
			//{
			//	[recalculateLocalNotificationBadgeCounts:currentBadgeNumber--];
			//}
		}
	}
}

- (void)cancelLocalNotifications
{
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (int)getApplicationIconBadgeNumber
{
	return [[UIApplication sharedApplication] getApplicationIconBadgeNumber];
}

- (void)setApplicationIconBadgeNumber:(int)number
{
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:number];
	[recalculateLocalNotificationBadgeCounts:number];
}

// Ensures local notifications set badge numbers correctly
- (void)recalculateLocalNotificationBadgeCounts:(int)baseBadgeCount
{
	// Get a copy of all pending notifications
	NSMutableArray* pendingNotifications = [[[UIApplication sharedApplication] scheduledLocalNotifications] mutableCopy];
	
	// Sort them by fire date
	NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fireDate" ascending:TRUE];
	[pendingNotifications sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	
	// Reschedule all the local notifications with updated badge numbers
	if (pendingNotifications.count != 0)
	{
		[[UIApplication sharedApplication] cancelAllLocalNotifications];
		NSUInteger badgeNumber = baseBadgeCount;
		for (UILocalNotification* notification in pendingNotifications)
		{
			//TODO
			//NSDictionary* userInfo = notification.userInfo;
			//if([
			bool shouldIncrementBadgeCount = true;
			if(shouldIncrementBadgeCount)
			{
				notification.applicationIconBadgeNumber = badgeNumber++;
			}
			else
			{
				notification.applicationIconBadgeNumber = badgeNumber;
			}
			[[UIApplication sharedApplication] scheduleLocalNotification:notification];
		}
	}
	[pendingNotifications release];
}

@end

namespace samcodesnotifications
{
	NotificationsController* getNotificationsController()
	{
		static NotificationsController* controller = NULL;
		if(controller == NULL)
		{
			controller = [[NotificationsController alloc] init];
		}
		return controller;
	}
	
	void scheduleLocalNotification(int slot, int triggerAfterMillis, const char* title, const char* message, const char* action, bool incrementBadgeCount)
	{
		NSString* newTitle = [[NSString alloc] initWithUTF8String:title];
		NSString* newMessage = [[NSString alloc] initWithUTF8String:message];
		NSString* newAction = [[NSString alloc] initWithUTF8String:action];
		int triggerAfterSeconds = triggerAfterMillis * 0.001;
		NotificationsController* controller = getNotificationsController();
		[controller scheduleLocalNotification:slot withTimeInterval:triggerAfterSeconds withTitle:newTitle withBody:newMessage withAction:newAction];
	}
	
	void cancelLocalNotification(int slot)
	{
		NotificationsController* controller = getNotificationsController();
		[controller cancelLocalNotification:slot];
	}
	
	void cancelLocalNotifications()
	{
		NotificationsController* controller = getNotificationsController();
		[controller cancelLocalNotifications];
	}
	
	int getApplicationIconBadgeNumber()
	{
		NotificationsController* controller = getNotificationsController();
		return [controller getApplicationIconBadgeNumber];
	}
	
	bool setApplicationIconBadgeNumber(int number)
	{
		NotificationsController* controller = getNotificationsController();
		[controller setApplicationIconBadgeNumber:number];
	}
}