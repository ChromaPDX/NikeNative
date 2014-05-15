//
//  NKPickerNode.m
//  NKNikeField
//
//  Created by Leif Shackelford on 4/16/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#import "NodeKitten.h"

@implementation NKPickerNode

-(void)tableInit {
    [super tableInit];
    contentOffset = P2Make(.5,.5);
    
}
-(void) setChildFrame:(NKScrollNode *)child{
    
    if (self.fdirty) {
        
        if (self.scrollDirectionVertical){
            
            
            int tempSize = 0;
            for(int i = 0; i < [intChildren indexOfObject:child]; i++)
            {
                int temp = [(NKNode*)intChildren[i] size].height;
                tempSize += temp + self.padding.y;
            }
            
            S2t childSize;
            
            if ([child isKindOfClass:[NKScrollNode class]]) {
                childSize.height = self.size.height * child.autoSizePct.y;
                childSize.width = self.size.width-(self.padding.x);
                child.fdirty = true;
                
            }
            else {
                childSize = child.size;
            }
            
            float cOffset = tempSize + self.scrollPosition.y;
            float zPos = -(fabs(cOffset) * .75);
            float rotation = MAX(-45,MIN(cOffset / 8., 45));
            [child setPosition3d:V3Make(0,cOffset*.95,zPos)];
            [child setOrientationEuler:V3Make(rotation,0, 0)];
            
            [child setSize:childSize];
            
            
        }
        
        else {
            
            int tempSize = 0;
            for(int i = 0; i < [intChildren indexOfObject:child]; i++)
            {
                int temp = [(NKNode*)intChildren[i] size].width;
                tempSize += temp + self.padding.x;
            }
            
            S2t childSize;
            
            if ([child isKindOfClass:[NKScrollNode class]]) {
                childSize.width = self.size.width * child.autoSizePct.x;
                childSize.height = self.size.height-(self.padding.y);
                child.fdirty = true;
                
            }
            else {
                childSize = child.size;
            }
            
            float cOffset = tempSize + self.scrollPosition.x - self.size.width/2.;
            float zPos = -(fabs(cOffset) * .75);
            float rotation = MAX(-45,MIN(cOffset / 8., 45));
            [child setPosition3d:V3Make(cOffset*.95,0,zPos)];
            [child setOrientationEuler:V3Make(0, rotation, 0)];
            
            [child setSize:childSize];
            
        }
        
        child.hidden = [child shouldCull];
        
        
        
    }
    
}

-(void)endScroll {
    
    drag = 1.15;
    
    if (scrollVel > restitution) {
        
        if (self.scrollDirectionVertical) {
            [self setScrollPosition:P2Make(self.scrollPosition.x, self.scrollPosition.y + scrollVel)];
        }
        else {
            [self setScrollPosition:P2Make(self.scrollPosition.x + scrollVel, self.scrollPosition.y)];
        }
        
    }
    
    else {
        
        for (NKNode* n in intChildren) {
            
            if ([n containsPoint:P2Make(0,0)]) {
                
                self.selectedChild = n;
                
                int pos = [intChildren indexOfObject:n];
                
                if (self.scrollDirectionVertical) {
                    
                }
                
                else {
                    if (pos > 0 && n.position.x > n.size.width * .1 && scrollVel > 0) {
                        NSLog(@"going left, %f",scrollVel);
                        self.selectedChild = intChildren[pos-1];
                    }
                    else if (pos < (intChildren.count - 1 ) && n.position.x < -n.size.width * .1 && scrollVel < 0) {
                        self.selectedChild = intChildren[pos+1];
                        NSLog(@"going right, %f",scrollVel);
                    }
                }
                
            }
//            else {
//                if (self.scrollPosition.x < self.contentSize.width){
//                    self.selectedChild = intChildren[0];
//                }
//                else if (self.scrollPosition.x > 0){
//                    self.selectedChild = [intChildren lastObject];
//                }
//            }
        }
        
     
        [self shouldBeginRestitution];
        self.scrollPhase = ScrollPhaseRestitution;
        easeIn = 12.;
        easeOut = false;
        //NSLog(@"start restitution");
    }
    
}

-(P2t)outOfBounds {
    
    P2t realEdges = [super outOfBounds];
    
    if (P2Bool(realEdges)){
        if (self.scrollDirectionVertical) {

        }
        else {
            if (realEdges.x > 0) {
                self.selectedChild = intChildren[0];
            }
            else {
                self.selectedChild = [intChildren lastObject];
            }
        }

    }
    
    if (self.selectedChild) {
        
        if (self.scrollDirectionVertical) {
            return self.selectedChild.position;
        }
        else {
            return self.selectedChild.position;
        }
        
    }
    
    return P2Make(0,0);
    
}

-(NKTouchState)touchUp:(P2t)location id:(int)touchId {
    [super touchUp:location id:touchId];
    if (self.scrollPhase == ScrollPhaseNil) {
        if (self.selectedChild) {
              [self.delegate cellWasSelected:self.selectedChild];
        }
    }
    return false;
}

@end
