//
//  GraphScreens.m
//  Nico
//
//  Created by Robby on 8/4/13.
//  Copyright (c) 2013 robbykraft. All rights reserved.
//

#import "GraphScreens.h"
#import "NikeConnect.h"
#import "LineGraph.h"
#import "ParseController.h"

@implementation UIImage (UIView)

#pragma mark - remember try out all these blend modes
+ (UIImage *) imageWithImages:(NSArray *)images withSize:(CGSize)size{
    UIImage *image = [[UIImage alloc] init];
    for(int i = 0; i < images.count; i++){
        NSLog(@"+");
        UIGraphicsBeginImageContextWithOptions(size, NO, 0);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        [[images objectAtIndex:i] drawInRect:CGRectMake(0, 0, size.width, size.height) blendMode:kCGBlendModeNormal alpha:2.0/images.count];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return image;
}

@end

@interface GraphScreens (){
    UIView *rulers;
    CGSize graphSize;
    NSMutableArray *graphs;
    NSMutableArray *names;
    NSInteger topMargin;
    
    NSArray *dateArray;
    NSInteger dateIndex;
    NSInteger newDateIndex;
    UILabel *dateStamp;
}

@end

@implementation GraphScreens
@synthesize nikeConnect;
@synthesize date;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        names = [NSMutableArray array];
        graphs = [NSMutableArray array];
        graphSize = CGSizeMake(frame.size.width*.9, frame.size.height*.1);
        topMargin = 180;
        for(int i = 0; i < 10; i++){
            [names addObject:[[UILabel alloc] initWithFrame:CGRectMake(0, topMargin+i*graphSize.height*1.2, frame.size.width-graphSize.width,graphSize.height)]];
            [(UILabel*)[names objectAtIndex:i] setFont:[UIFont fontWithName:@"AvenirNextCondensed-UltraLight" size:20]];
            [(UILabel*)[names objectAtIndex:i] setTextColor:[UIColor whiteColor]];
            [self addSubview:[names objectAtIndex:i]];
            [graphs addObject:[[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width-graphSize.width, topMargin+i*graphSize.height*1.2, graphSize.width, graphSize.height)]];
            [self addSubview:[graphs objectAtIndex:i]];
        }
        
        NSDate *currDate = [NSDate date];
        
//        NSCalendar *cal = [[NSCalendar alloc] init];
//        NSDateComponents *components = [cal components:0 fromDate:currDate];
        
        //int year = [components year];
        
        //dateArray = [self dateArrayForYear:[NSString stringWithFormat:@"%d", year]];
       
        NSMutableArray * dateMutable = [[NSMutableArray alloc]init];
        
        for (int i = 0; i<10; i++) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"YYYY-MM-dd"];
            
            ;
            NSString *todaysDate = [dateFormatter stringFromDate:[NSDate dateWithTimeInterval:-(60*60*24*i) sinceDate:currDate]];
            [dateMutable insertObject:todaysDate atIndex:0];
        }
        
        //NSLog(@"available dates: %@", dateMutable);
        
        dateArray = dateMutable;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd"];
        
        NSString *todaysDate = [dateFormatter stringFromDate:currDate];
        NSLog(@"Today's Date: %@",todaysDate);
        dateIndex = 0;
        for (int i = 0; i < dateArray.count; i++)
            if([[dateArray objectAtIndex:i] isEqualToString:todaysDate])
                dateIndex = i;
        
        date = [dateArray objectAtIndex:dateIndex];
        
        dateStamp = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width*.25)];
        
        [dateStamp setFont:[UIFont fontWithName:@"AvenirNextCondensed-UltraLight" size:frame.size.width*.25]];
        [dateStamp setTextAlignment:NSTextAlignmentCenter];
        [dateStamp setTextColor:[UIColor whiteColor]];
        [dateStamp setBackgroundColor:[UIColor clearColor]];
        [dateStamp setText:[NSString stringWithFormat:@"%@ %@ %@",
                            [todaysDate substringWithRange:NSMakeRange(5, 2)],
                            [todaysDate substringWithRange:NSMakeRange(8, 2)],
                            [todaysDate substringToIndex:4]
                            ]];
        [self addSubview:dateStamp];

    }
    return self;
}

-(void)pan:(NSInteger)direction {
    dateIndex += direction;
    if(dateIndex > 0 && dateIndex < dateArray.count){
        
        NSString *key = [dateArray objectAtIndex:dateIndex];
        [self setDate:key];
        [self setNeedsLayout];
        [dateStamp setText:[NSString stringWithFormat:@"%@ %@ %@",
                            [key substringWithRange:NSMakeRange(5, 2)],
                            [key substringWithRange:NSMakeRange(8, 2)],
                            [key substringToIndex:4] ]];
    }
}

-(void)pinchIn { }
-(void)pinchOut { }

-(void)update{
    [self drawGraphsFromUserCache];
    [self setNeedsLayout];
}

//-(void)drawGraphs{
//    if(people == nil)
//        people = [NSMutableDictionary dictionary];
//    for(NSString* key in [[nikeConnect people] allKeys]){
//        if(![[people allKeys] containsObject:key])
//            [people setObject:[[NSMutableDictionary alloc] init] forKey:key];
//    }
//    
//    NSLog(@"Refreshing Graphs %@",[people allKeys]);
//    NSLog(@"nikeConnect People: %@",[[nikeConnect people] allKeys]);
//    for(NSString *person in [[nikeConnect people] allKeys]){
//        NSDictionary *activity = [[nikeConnect people] objectForKey:person];
//        
//        NSLog(@"%d entries in %@",[activity allKeys].count, person);
//        for(NSString *activityDate in [activity allKeys]){
//            
//            if([people objectForKey:person] == nil){
//                NSLog(@"Making a new spot for a %@ on screen", person);
//                [people setObject:[NSMutableDictionary dictionary] forKey:person];
//            }
//            if([[people objectForKey:person] objectForKey:activityDate] == nil){
//                
//                LineGraph *graph = [[LineGraph alloc] initWithSize:graphSize Values:[[[ParseController playerCache] objectForKey:[[PFUser user] username] ] objectForKey:date]];
//                
//                //LineGraph *graph = [[LineGraph alloc] initWithSize:graphSize Values:[[activity objectForKey:activityDate] objectForKey:@"fuel"]];
//                
//                UIImage *image = [graph getImage];
//                
//                [[people objectForKey:person] setObject:image forKey:activityDate];
//            }
//        }
//    }
//}

-(void)drawGraphsFromUserCache{
    
    if (!cachedImages) {
        cachedImages = [[NSMutableDictionary alloc] init];
    }
    
    NSDictionary *players = [ParseController sharedInstance].playerCache;
    
    //NSLog(@"Refreshing Graphs %@",[people allKeys]);
    NSLog(@"Cached People: %@",[players allKeys]);
    
    
    for(NSString *person in [players allKeys]){
        
        NSDictionary *player = [players objectForKey:person];
        
        NSDictionary *activity = [player objectForKey:FUEL_DATA_KEY];
        
        NSLog(@"%d entries in %@",[activity allKeys].count, person);
        
        for(NSString *activityDate in [activity allKeys]){
            
            if([cachedImages objectForKey:person] == nil){
                NSLog(@"Making a new spot for a %@ on screen", person);
                [cachedImages setObject:[NSMutableDictionary dictionary] forKey:person];
                
            }
            
            if([[cachedImages objectForKey:person] objectForKey:activityDate] == nil){
                
                LineGraph *graph = [[LineGraph alloc] initWithSize:graphSize Values:[[activity objectForKey:activityDate][@"data"] objectForKey:@"fuel"]];
                
                //LineGraph *graph = [[LineGraph alloc] initWithSize:graphSize Values:[[activity objectForKey:activityDate] objectForKey:@"fuel"]];
                
                UIImage *image = [graph getImage];
                
                [[cachedImages objectForKey:person] setObject:image forKey:activityDate];
                
                //[[people objectForKey:person] setObject:image forKey:activityDate];
                
               // NSLog(@"caching fuel vector %@", [[activity objectForKey:activityDate] objectForKey:@"fuel"]);
            }
        }
        
        NSLog(@"CACHED IMAGES FOR DATES: %@",[[cachedImages objectForKey:person] allKeys]);
      
    }
}

-(void) layoutSubviews{
    [super layoutSubviews];
    [rulers removeFromSuperview];
    rulers = nil;
    rulers = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:rulers];
    for(int i = 0; i < [cachedImages allKeys].count; i++){
        [(UIImageView*)[graphs objectAtIndex:i] setImage:nil];
        NSString *person = [[cachedImages allKeys] objectAtIndex:i];
        [(UILabel*)[names objectAtIndex:i] setText:person];
        if([[cachedImages objectForKey:person] objectForKey:date] != nil){
            [(UIImageView*)[graphs objectAtIndex:i] setImage:[[cachedImages objectForKey:person] objectForKey:date]];
        }
        
        UILabel *fuelTotal = [[UILabel alloc] initWithFrame:CGRectMake(0, topMargin+25+i*graphSize.height*1.2, self.bounds.size.width-graphSize.width,graphSize.height)];
        [fuelTotal setFont:[UIFont fontWithName:@"AvenirNextCondensed-UltraLight" size:15]];
        [fuelTotal setTextColor:[UIColor whiteColor]];
        NSString *fuelString = [NSString stringWithFormat:@"%@",[[[[ParseController sharedInstance].playerCache objectForKey:person] objectForKey:date] objectForKey:@"totalFuel"]];
        if(![fuelString isEqualToString:@"(null)"])
            [fuelTotal setText:[NSString stringWithFormat:@"✚%@",fuelString]];
        [rulers addSubview:fuelTotal];

        UILabel *stepsTotal = [[UILabel alloc] initWithFrame:CGRectMake(0, topMargin+40+i*graphSize.height*1.2, self.bounds.size.width-graphSize.width,graphSize.height)];
        [stepsTotal setFont:[UIFont fontWithName:@"AvenirNextCondensed-UltraLight" size:12]];
        [stepsTotal setTextColor:[UIColor whiteColor]];
        NSString *stepsString = [NSString stringWithFormat:@"%@",[[[[ParseController sharedInstance].playerCache objectForKey:person] objectForKey:date] objectForKey:@"totalSteps"]];
        if(![stepsString isEqualToString:@"(null)"])
            [stepsTotal setText:[NSString stringWithFormat:@"⇄%@",stepsString]];
        [rulers addSubview:stepsTotal];
        
        UILabel *moon = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width-graphSize.width-10, topMargin+graphSize.height+i*graphSize.height*1.2, 20, 20)];
        [moon setBackgroundColor:[UIColor clearColor]];
        [moon setText:@"❍"];
        [moon setTextColor:[UIColor whiteColor]];
        [rulers addSubview:moon];
        UILabel *sun = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width-graphSize.width*.5-10, topMargin+graphSize.height+i*graphSize.height*1.2, 20, 20)];
        [sun setBackgroundColor:[UIColor clearColor]];
        [sun setText:@"☼"];
        [sun setTextColor:[UIColor whiteColor]];
        [rulers addSubview:sun];
        
        UILabel *sunset = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width-graphSize.width*.25-cosf(dateIndex/365.0*2.0*M_PI)*graphSize.width*.075-10,
                                                                     topMargin+graphSize.height+i*graphSize.height*1.2, 20, 20)];
        [sunset setBackgroundColor:[UIColor clearColor]];
        [sunset setText:@"◓"];
        [sunset setTextColor:[UIColor whiteColor]];
        [rulers addSubview:sunset];
        
        UILabel *sunrise = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width-graphSize.width*.75+cosf(dateIndex/365.0*2.0*M_PI)*graphSize.width*.075-10, topMargin+graphSize.height+i*graphSize.height*1.2, 20, 20)];
        [sunrise setBackgroundColor:[UIColor clearColor]];
        [sunrise setText:@"◓"];
        [sunrise setTextColor:[UIColor whiteColor]];
        [rulers addSubview:sunrise];
        
        UIView *daytime = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width-graphSize.width*.75+cosf(dateIndex/365.0*2.0*M_PI)*graphSize.width*.075,
                                                                        topMargin+i*graphSize.height*1.2,
                                                                   graphSize.width*.5-2*cosf(dateIndex/365.0*2.0*M_PI)*graphSize.width*.075,
                                                                   graphSize.height)];
        [daytime setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"diagonals.png"]]];
        [daytime.layer setBorderColor:[UIColor whiteColor].CGColor];
        [daytime.layer setBorderWidth:1.0];
        [rulers addSubview:daytime];
    }
}

//-(NSArray*)dateArrayForYear:(NSString*)year{
//    NSArray *monthDays = @[@31,@28,@31,@30,@31,@30,@31,@31,@30,@31,@30,@31];
//    NSMutableArray *array = [NSMutableArray array];
//    for(int month = 1; month <= 12; month++){
//        for (int day = 1; day <= [[monthDays objectAtIndex:month-1] integerValue]; day++){
//            [array addObject:[NSString stringWithFormat:@"%@-%02d-%02d",year,month,day]];
//        }
//    }
//    return array;
//}

@end
