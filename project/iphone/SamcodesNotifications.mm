#include "SamcodesNotifications.h"

#import <UIKit/UIKit.h>

@interface NotificationsController : NSObject<UIApplicationDelegate>
@end

@implementation NotificationsController

- (void)application:(UIApplication*)application didRegisterUserNotificationSettings:(UIUserNotificationSettings*)notificationSettings
{
    [application registerForRemoteNotifications];
}

- (void)scheduleLocalNotification:(int)id withTimeInterval(int)timeInterval withTitle:(NSString*)title (NSString*)withBody:body withAction:(NSString*)action
{
	if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) { // iOS 8 and above
	{
		UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
		UIUserNotificationSettings* mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
		[[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
	}
	else
	{
		UIRemoteNotificationType types = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert;
		[[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
	}
	
	UILocalNotification* notification = [[UILocalNotification alloc] init];
	notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
	notification.timeZone = [NSTimeZone defaultTimeZone];
	notification.repeatInterval = nil;
	notification.alertBody = body;
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

- (void)cancelLocationNotification:(int)id
{
	// TODO grab list of active notifications
	// TODO check userdata for id key
	// TODO if matching, then grab and cancel it
	
	[[UIApplication sharedApplication] cancelLocalNotification:notification];
}

- (void)cancelLocalNotifications
{
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
}

@end

namespace notifications
{
	NotificationController* getNotificationController()
	{
		static NotificationController* controller = NULL;
		if(controller == NULL)
		{
			controller = [[NotificationController alloc] init];
		}
		return controller;
	}
	
	void scheduleLocalNotification(int id, int time, const char* title, const char* message, const char* action)
	{
		NSString* newTitle = [[NSString alloc] initWithUTF8String:title];
		NSString* newMessage = [[NSString alloc] initWithUTF8String:message];
		NSString* newAction = [[NSString alloc] initWithUTF8String:action];
		[getNotificationController() scheduleLocalNotification:id withTimeIntervalSinceNow:time withTitle:newTitle withBody: newMessage withAction:newAction];
	}
	
	void cancelLocalNotification(int id)
	{
		[getNotificationController() cancelLocalNotification:id];
	}
	
	void cancelLocalNotifications()
	{
		[getNotificationController() cancelLocalNotifications];
	}
}