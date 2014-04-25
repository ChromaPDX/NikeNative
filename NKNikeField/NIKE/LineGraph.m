//
//  LineGraph.m
//  Nico
//
//  Created by Robby on 7/1/13.
//  Copyright (c) 2013 robbykraft. All rights reserved.
//

#import "LineGraph.h"

@implementation LineGraph
@synthesize values;

- (id)initWithSize:(CGSize)size Values:(NSArray*)v
{
    self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    if (self) {
        values = v;
        self.opaque = NO;
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

-(UIImage*)getImage
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 1.0);
    UIColor *color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, self.bounds);
    if(values.count){
        CGContextMoveToPoint(context, 0, self.bounds.size.height);
        for(int i = 0; i < values.count; i++){
            CGContextAddLineToPoint(context, self.bounds.size.width/values.count*i, self.bounds.size.height-[[values objectAtIndex:i] integerValue]*.5);
//            CGContextAddQuadCurveToPoint(context, self.bounds.size.width/values.count*i, self.bounds.size.height-[[values objectAtIndex:i] integerValue]*.5,
//                                         self.bounds.size.width/values.count*i, self.bounds.size.height-[[values objectAtIndex:i] integerValue]*.5);
        }
        CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);
        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGContextFillPath(context);
    }
    UIImage *image = [UIImage imageWithData:UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext())];
//    UIImage *image = [UIImage imageWithData:UIImageJPEGRepresentation(UIGraphicsGetImageFromCurrentImageContext(),.2)];
    UIGraphicsEndImageContext();
    return image;
}

@end
