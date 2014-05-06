//
//  MenuPlayerProfileScene.m
//  nike3dField
//
//  Created by Chroma Developer on 3/25/14.
//
//

#import "MenuPlayerProfileScene.h"
#import "NodeKitten.h"


@implementation MenuPlayerProfileScene


-(instancetype)initWithSize:(S2t)size {
    
    self = [super initWithSize:size];
    
    if (self) {
        
    }
    return self;
}


-(void)cellWasSelected:(NKScrollNode *)cell {
    NSLog(@"MainMenu cellWasSelected: %@ was selected", cell.name);
   }


@end
