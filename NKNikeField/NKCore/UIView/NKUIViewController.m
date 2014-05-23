//
//  NKUIViewController.m
//  EMA Stage
//
//  Created by Leif Shackelford on 5/21/14.
//  Copyright (c) 2014 EMA. All rights reserved.
//

#if TARGET_OS_IPHONE

#import "NKUIViewController.h"
#import "NKUIView.h"


@implementation NKUIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"nkView load scene");
    [self.nkView loadScene];
    // Do any additional setup after loading the view.
}

-(NKUIView*)nkView {
    return (NKUIView*)self.view;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

#endif