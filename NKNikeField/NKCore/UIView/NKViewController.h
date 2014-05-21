//*
//*  NODE KITTEN
//*

#import "NKpch.h"

#if TARGET_OS_IPHONE
#define GOTIT
@interface NKViewController : UIViewController
#endif

#if TARGET_MAC_OS && !TARGET_MAC_IPHONE
@interface NKViewController : NSViewController
#else
#ifndef GOTIT
@interface NKViewController : UIViewController
#endif
#endif

@end
