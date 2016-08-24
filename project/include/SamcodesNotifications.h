#ifndef SAMCODESNOTIFICATIONSEXT_H
#define SAMCODESNOTIFICATIONSEXT_H

namespace samcodesnotifications
{
	void scheduleLocalNotification(int id, int triggerAfterMillis, const char* title, const char* message, const char* action);
	void cancelLocalNotification(int id);
	void cancelLocalNotifications();
}

#endif