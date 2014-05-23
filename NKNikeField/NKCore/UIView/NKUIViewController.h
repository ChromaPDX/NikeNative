//
//  NKUIViewController.h
//  EMA Stage
//
//  Created by Leif Shackelford on 5/21/14.
//  Copyright (c) 2014 EMA. All rights reserved.
//

#if TARGET_OS_IPHONE

@class NKUIView;

@interface NKUIViewController : UIViewController

-(NKUIView*)nkView;

@end



#endif