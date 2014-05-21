//*
//*  NODE KITTEN
//*

#import "NKpch.h"

#if NK_USE_GLES
@interface NKViewController : UIViewController
#else
@interface NKViewController : NSViewController
#endif

@end
