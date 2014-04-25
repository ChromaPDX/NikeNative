//
//  LineGraph
//  Nico
//
//  Created by Robby on 7/1/13.
//  Copyright (c) 2013 robbykraft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LineGraph : UIView
@property (nonatomic, strong) NSArray *values;
- (id)initWithSize:(CGSize)frame Values:(NSArray*)v;
-(UIImage*)getImage;

@end
