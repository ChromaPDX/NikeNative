//
//  NKPickerNode.m
//  NKNikeField
//
//  Created by Leif Shackelford on 4/16/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#import "NodeKitten.h"

@implementation NKPickerNode

-(float)contentSize {
    if (cdirty) {
        
        int tempSize = 0;
        
        for(int i = 0; i < intChildren.count; i++)
        {
            NKScrollNode *child = intChildren[i];
            
            if (self.scrollDirectionVertical) {
                int temp = child.size.height;
                
                tempSize += temp + self.verticalPadding;
            }
            else {
                int temp = child.size.width;
                tempSize += temp + self.horizontalPadding;
            }
            
        }
        
        contentSize = tempSize;
        
        cdirty = false;
        
        return tempSize;
        
    }
    
    else {
        return contentSize;
    }
}

-(float)outOfBounds {
    
    if (self.scrollDirectionVertical) {
        
        if (self.scrollPosition > self.verticalPadding) {
            return self.scrollPosition - self.verticalPadding;
        }
        
        else {
            
            if (self.contentSize > self.size.height) {
                
                int diff = self.scrollPosition + self.contentSize - self.size.height;
                if (diff < 0){
                    
                    return diff;
                    
                }
                
            }
            else {
                if (self.scrollPosition < self.verticalPadding) {
                    return self.scrollPosition - self.verticalPadding;
                }
            }
            
        }
        
    }
    
    else {
        
        if (self.scrollPosition > self.horizontalPadding) {
            return self.scrollPosition - self.horizontalPadding;
        }
        
        else {
            
            if (self.contentSize > self.size.width) {
                
                int diff = self.scrollPosition + self.contentSize - self.size.width;
                
                if (diff < 0){
                    
                    return diff;
                    
                }
                
            }
            else {
                if (self.scrollPosition < self.horizontalPadding) {
                    return self.scrollPosition - self.horizontalPadding;
                }
            }
            
        }
        
        
    }
    
    return 0;
    
}

-(void) setChildFrame:(NKScrollNode *)child{
    
    if (self.fdirty) {
        
        if (self.scrollDirectionVertical){
            
            int tempSize = 0;
            for(int i = 0; i < [intChildren indexOfObject:child]; i++)
            {
                int temp = [intChildren[i] size].height;
                tempSize += temp + self.verticalPadding;
            }
            
            CGSize childSize;
            
            if ([child isKindOfClass:[NKScrollNode class]]) {
                childSize.height = self.size.height * child.autoSizePct;
                childSize.width = self.size.width-(self.horizontalPadding);
                child.fdirty = true;
                
            }
            else {
                childSize = child.size;
            }
            
            [child setPosition3d:V3Make(0,self.size.height/2. - (tempSize + childSize.height/2.) + self.scrollPosition,4)];
            
            [child setSize:childSize];
            
            
        }
        
        else {
            
            int tempSize = 0;
            for(int i = 0; i < [intChildren indexOfObject:child]; i++)
            {
                int temp = [intChildren[i] size].width;
                tempSize += temp + self.horizontalPadding;
            }
            
            CGSize childSize;
            
            if ([child isKindOfClass:[NKScrollNode class]]) {
                childSize.width = self.size.width * child.autoSizePct;
                childSize.height = self.size.height-(self.verticalPadding);
                child.fdirty = true;
                
            }
            else {
                childSize = child.size;
            }
            
            [child setPosition3d:V3Make(tempSize + childSize.width/2. + self.scrollPosition - self.size.width/2.,0,4)];
            
            [child setSize:childSize];
            
        }
        
        child.hidden = [child shouldCull];
        
        
        
    }
    
}

@end
