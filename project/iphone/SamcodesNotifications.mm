#include "SamcodesNotifications.h"

#import <UIKit/UIKit.h>

#define kNotificationSlotKey @"kNotificationSlotKey"
#define kIncrementBadgeKey @"kIncrementBadgeKey"

@interface NotificationsController : NSObject<UIApplicationDelegate>
@end

@implementation NotificationsController

- (void)requestNotificationPermissions
{
	NSLog(@"NotificationsController requestNotificationPermissions");
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

- (void)scheduleLocalNotification:(int)slot withTimeInterval:(float)timeInterval withTitle:(NSString*)title withBody:(NSString*)messageBody withAction:(NSString*)action incrementBadgeCount:(bool)incrementBadgeCount
{
	NSLog(@"NotificationsController scheduleLocalNotification");
	
	// Cancel local notification (in case one with the same slot was already scheduled)
	[self cancelLocationNotification:slot];
	
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
	
	NSDictionary* userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d", slot], kNotificationSlotKey, [NSString stringWithFormat:@"%d", (int)(incrementBadgeCount)], kIncrementBadgeKey, nil];
	notification.userInfo = userInfo;
	[[UIApplication sharedApplication] scheduleLocalNotification:notification];
	[self recalculateLocalNotificationBadgeCounts];
}

- (void)cancelLocalNotification:(int)slot
{
	NSLog(@"NotificationsController cancelLocalNotification");
	
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
	NSLog(@"NotificationsController cancelLocalNotifications");
	
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (int)getApplicationIconBadgeNumber
{
	NSLog(@"NotificationsController getApplicationIconBadgeNumber");
	
	return [UIApplication sharedApplication].applicationIconBadgeNumber;
}
	
- (bool)setApplicationIconBadgeNumber:(int)number
{
	NSLog(@"NotificationsController setApplicationIconBadgeNumber");
	
	[UIApplication sharedApplication].applicationIconBadgeNumber = number;
	[self recalculateLocalNotificationBadgeCounts];
	return true;
}

// Ensures local notifications set badge numbers correctly
- (void)recalculateLocalNotificationBadgeCounts
{
	NSLog(@"NotificationsController recalculateLocalNotificationBadgeCounts");
	
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
			notification.applicationIconBadgeNumber = ++badgeNumber;
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
			[controller requestNotificationPermissions]; // Request notification permission on first usage
		}
		return controller;
	}
	
	void scheduleLocalNotification(int slot, int triggerAfterMillis, const char* title, const char* message, const char* action, bool incrementBadgeCount)
	{
		NSString* newTitle = [[NSString alloc] initWithUTF8String:title];
		NSString* newMessage = [[NSString alloc] initWithUTF8String:message];
		NSString* newAction = [[NSString alloc] initWithUTF8String:action];
		float triggerAfterSeconds = (float)triggerAfterMillis * 0.001;
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