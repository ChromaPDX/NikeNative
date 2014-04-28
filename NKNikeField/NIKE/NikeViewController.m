//
//  ViewController.m
//  Nico
//
//  Created by Robby on 7/1/13.
//  Copyright (c) 2013 robbykraft. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "NikeViewController.h"
#import "GraphScreens.h"
#import "Nike.h"
#import "ParseController.h"


@interface NikeViewController (){
    NikeConnect *nikeConnect;
    GraphScreens *graphScreens;
    NSInteger panOffset;
}
@end

@implementation NikeViewController




- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0. green:0. blue:0. alpha:.3];
    nikeConnect = [[NikeConnect alloc] init];
    [nikeConnect setDelegate:self];

    graphScreens = [[GraphScreens alloc] initWithFrame:self.view.bounds];
    [graphScreens setNikeConnect:nikeConnect];
    [self.view addSubview:graphScreens];
    
    
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
    [self.view addGestureRecognizer:panGesture];

    CGRect frame = self.view.frame;

    _loginButton = [[UIButton alloc] initWithFrame: CGRectMake(frame.size.width-frame.size.width*.66, frame.size.height-frame.size.width*.25, frame.size.width*.33, frame.size.width*.1)];
    
    
    [_loginButton.layer setBorderColor:[UIColor colorWithWhite:.4 alpha:.4].CGColor];
    [_loginButton.layer setCornerRadius:2.0];
    [_loginButton.layer setBorderWidth:1.0];
    

    
    [_loginButton setBackgroundColor:V2GREEN];
    
    [_loginButton.titleLabel setFont:[UIFont fontWithName:@"Arial Black.ttf" size:20]];
    [_loginButton.titleLabel setTextColor:[UIColor blackColor]];
    [_loginButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_loginButton addTarget:self action:@selector(logOutInPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_loginButton];
    
    
    
//    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width*.05, frame.size.height-frame.size.width*.15, frame.size.width*.35, frame.size.width*.1)];
//    backButton.userInteractionEnabled = YES;
//    
//    [backButton.layer setBorderColor:[UIColor colorWithWhite:.4 alpha:.4].CGColor];
//    [backButton.layer setCornerRadius:2.0];
//    [backButton.layer setBorderWidth:1.0];
//    
//    [backButton setTitle:@"BACK" forState:UIControlStateNormal];
//    
//    [backButton.titleLabel setFont:[UIFont fontWithName:@"Arial Black.ttf" size:20]];
//    [backButton.titleLabel setTextColor:[UIColor blackColor]];
//    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    
//    backButton.backgroundColor = V2BLUE;
//    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.view addSubview:backButton];
    
   // [nikeConnect loadAllPriorLogins];
    
    NSLog(@"NIKE VC DID LOAD");
}

-(void)viewDidAppear:(BOOL)animated {
    if ([Nike isLoggedIn]) {
        [_loginButton setTitle:@"LOGOUT" forState:UIControlStateNormal];
    }
    else {
        [_loginButton setTitle:@"LOGIN" forState:UIControlStateNormal];
        
    }
    
    [self dataDidUpdate];
     
}
-(void) logOutInPressed:(UIButton*)sender{
    if([nikeConnect isConnected])
        [nikeConnect disconnect];
    else
        [nikeConnect connect];
    // [loginView performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:1.0];
}


-(void)back:(UIButton*)sender {
   // NSLog(@"CANCEL FUEL");
    [self.parentViewController dismissViewControllerAnimated:YES completion:^{
       // [_delegate showGK];
    }];

}

-(void) connectionSuccessful{
    NSLog(@"DELEGATE, Nike connection Sucessfull");


    [nikeConnect request10Days];
    
    //[nikeConnect requestCascadingDataOfMonths:1];
    
}

-(void) dataDidUpdate{
    NSLog(@"View Controller received: dataDidUpdate");
    [graphScreens update];
    
  
    
}

-(void)panHandler:(UIPanGestureRecognizer*)sender{
    if([sender state] == 1)
        panOffset = 0;
    if([sender state] == 2){
        NSInteger newPanOffset = (int)([sender translationInView:sender.view].x*.1);
        if(panOffset != newPanOffset){
            [graphScreens pan:panOffset-newPanOffset];
            panOffset = newPanOffset;
        }
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

