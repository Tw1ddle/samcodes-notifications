#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif

#include <hx/CFFIPrime.h>
#include "SamcodesNotifications.h"

using namespace samcodesnotifications;

#ifdef IPHONE
void samcodesnotifications_schedule_local_notification(int slot, int triggerAfterMillis, HxString title, HxString message, HxString action, bool incrementBadgeCount)
{
	scheduleLocalNotification(slot, triggerAfterMillis, title.c_str(), message.c_str(), action.c_str(), incrementBadgeCount);
}
DEFINE_PRIME6v(samcodesnotifications_schedule_local_notification);

void samcodesnotifications_cancel_local_notification(int slot)
{
	cancelLocalNotification(slot);
}
DEFINE_PRIME1v(samcodesnotifications_cancel_local_notification);

void samcodesnotifications_cancel_local_notifications()
{
	cancelLocalNotifications();
}
DEFINE_PRIME0v(samcodesnotifications_cancel_local_notifications);

int samcodesnotifications_get_application_icon_badge_number()
{
	return getApplicationIconBadgeNumber();
}
DEFINE_PRIME0(samcodesnotifications_get_application_icon_badge_number)

bool samcodesnotifications_set_application_icon_badge_number(int number)
{
	return setApplicationIconBadgeNumber(number);
}
DEFINE_PRIME1(samcodesnotifications_set_application_icon_badge_number)

extern "C" void samcodesnotifications_main()
{
	
}
DEFINE_ENTRY_POINT(samcodesnotifications_main);

extern "C" int samcodesnotifications_register_prims()
{
	return 0;
}

#endif