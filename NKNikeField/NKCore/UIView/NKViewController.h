//*
//*  NODE KITTEN
//*

#import "NKpch.h"

#if TARGET_OS_IPHONE
@interface NKViewController : UIViewController
#else
@interface NKViewController : NSViewController
#endif

@end
