#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif

#include <hx/CFFI.h>
#include "SamcodesNotifications.h"

using namespace samcodesnotifications;

#ifdef IPHONE

static value samcodesnotifications_schedule_local_notification(value id) // TODO
{
	scheduleLocalNotification(val_int(id), val_int(time), val_string(title), val_string(message), val_string(action));
	return alloc_null();
}
DEFINE_PRIM(samcodesnotifications_schedule_local_notification, 5);

static value samcodesnotifications_cancel_local_notification(value id)
{
	cancelLocalNotification(val_int(id));
	return alloc_null();
}
DEFINE_PRIM(samcodesnotifications_cancel_local_notification, 1);

static value samcodesnotifications_cancel_local_notifications()
{
	cancelLocalNotifications();
	return alloc_null();
}
DEFINE_PRIM(samcodesnotifications_cancel_local_notifications, 0);

extern "C" void samcodesnotifications_main()
{
	val_int(0);
}
DEFINE_ENTRY_POINT(samcodesnotifications_main);

extern "C" int samcodesnotifications_register_prims()
{
	return 0;
}

#endif