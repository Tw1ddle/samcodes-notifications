#include "SamcodesNotifications.h"

#import <UIKit/UIKit.h>

#define kNotificationSlotKey @"kNotificationSlotKey"
#define kIncrementBadgeKey @"kIncrementBadgeKey"

@interface NotificationsController : NSObject<UIApplicationDelegate>
@end

@implementation NotificationsController

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
	return YES;
}

- (void)application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification*)notification
{
	// This should be triggered if the app is active in the foreground when a local notification is received
	// Or if the user just launched the app from a notification
}

- (void)scheduleLocalNotification:(int)slot withTimeInterval:(int)timeInterval withTitle:(NSString*)title withBody:(NSString*)messageBody withAction:(NSString*)action incrementBadgeCount:(bool)incrementBadgeCount
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
	
	NSDictionary* userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:kNotificationSlotKey, [NSNumber numberWithInt:slot], kIncrementBadgeKey, [NSNumber numberWithBool:incrementBadgeCount], nil];
	notification.userInfo = userInfo;
	[[UIApplication sharedApplication] scheduleLocalNotification:notification];
	[self recalculateLocalNotificationBadgeCounts];
}

- (void)cancelLocalNotification:(int)slot
{
	NSArray* pendingNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
	if (pendingNotifications.count == 0)
	{
		return;
	}
	
	for (UILocalNotification* notification in pendingNotifications)
	{
		NSDictionary* userInfo = notification.userInfo;
		if(!([[userInfo allKeys] containsObject:kNotificationSlotKey]))
		{
			continue;
		}
		if([userInfo[kNotificationSlotKey] intValue] != slot)
		{
			continue;
		}
		
		[[UIApplication sharedApplication] cancelLocalNotification:notification];
		[self recalculateLocalNotificationBadgeCounts];
		return;
	}
}

- (void)cancelLocalNotifications
{
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (int) getApplicationIconBadgeNumber
{
	return [UIApplication sharedApplication].applicationIconBadgeNumber;
}
	
- (bool) setApplicationIconBadgeNumber:(int)number
{
	[UIApplication sharedApplication].applicationIconBadgeNumber = number;
	[self recalculateLocalNotificationBadgeCounts];
	return true;
}

// Ensures local notifications set badge numbers correctly
- (void)recalculateLocalNotificationBadgeCounts
{
	// Get a copy of all pending notifications
	NSMutableArray* pendingNotifications = [[[UIApplication sharedApplication] scheduledLocalNotifications] mutableCopy];
	if(pendingNotifications.count == 0)
	{
		[pendingNotifications release];
		return;
	}
	
	// Sort them by fire date
	NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fireDate" ascending:TRUE];
	[pendingNotifications sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	
	// Reschedule all pending local notifications with updated badge numbers
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	NSUInteger badgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber;
	for (UILocalNotification* notification in pendingNotifications)
	{
		NSDictionary* userInfo = notification.userInfo;
		if(!([[userInfo allKeys] containsObject:kIncrementBadgeKey]))
		{
			continue;
		}
		
		bool shouldIncrementBadgeCount = (bool)([userInfo[kIncrementBadgeKey] integerValue]);
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
		[controller scheduleLocalNotification:slot withTimeInterval:triggerAfterSeconds withTitle:newTitle withBody:newMessage withAction:newAction incrementBadgeCount:incrementBadgeCount];
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
		return [controller setApplicationIconBadgeNumber:number];
	}
}