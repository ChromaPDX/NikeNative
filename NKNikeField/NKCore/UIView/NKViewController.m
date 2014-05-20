//
//  NKViewController.m
//  NKNikeField
//
//  Created by Leif Shackelford on 4/25/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#import "NKViewController.h"
#import "NodeKitten.h"

@implementation NKViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#if TARGET_OS_IPHONE

- (void)viewDidLoad
{
    [super viewDidLoad];
    [(NKView*)self.view setController:self];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [(NKView*)self.view startAnimation];
}
- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"view will dissappear");
    [(NKView*)self.view stopAnimation];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#endif


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
