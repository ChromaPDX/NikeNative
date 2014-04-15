//
//  ofxTableNode.m
//  example-ofxTableView
//
//  Created by Chroma Developer on 2/18/14.
//
//

#import "NodeKitten.h"

@implementation NKScrollNode


#pragma ADD Cells




-(instancetype) initWithColor:(UIColor *)color size:(CGSize)size {
    
    
    self = [super initWithColor:color size:size];
    
    if (self) {
        
        _normalColor = color;
        _highlightColor = NKWHITE;
        
        _scrollDirectionVertical = true;
        _scrollingEnabled = true;
        _verticalPadding = 10;
        _horizontalPadding = 10;
        _fdirty = true;
        
        self.userInteractionEnabled = true;
        //float nbgColor[4] = {rand()%255/255., rand()%255/255.,rand()%255/255.,1.};
        
        //        setBgColor(nbgColor);
        //
        //        _xRootOffset = getX();
        //        _yRootOffset = getY();
        //
        //        xTouchOffset = &_xRootOffset;
        //        yTouchOffset = &_yRootOffset;
        
        restitution = 3;
        drag = 1.5;
        
    }
    
    return self;
}

-(instancetype) initWithParent:(NKScrollNode *)parent autoSizePct:(float)autoSizePct {
    
    if (!parent){
        return nil;
    }
    
    CGSize size;
    if (parent.scrollDirectionVertical) {
        size = CGSizeMake(parent.size.width, parent.size.height*autoSizePct);
    }
    else {
        size = CGSizeMake(parent.size.width*autoSizePct,parent.size.height);
    }
    
    self = [super initWithColor:nil size:size];
    
    if (self) {
        
        _autoSizePct = autoSizePct;
        
        _horizontalPadding = 0;
        _verticalPadding = 0;
        
        parent->cdirty = true;
        parent.fdirty = true;
        
        restitution = 3;
        drag = 1.5;
        
        self.userInteractionEnabled = true;
    }
    
    return self;
    
}

#pragma DRAW etc.

-(void)setHighlighted:(bool)highlighted {
    
    if (highlighted && !_highlighted) {
        
        NSLog(@"highlight %@", self.name);
        
        [self setColor:_highlightColor];
        
        if (_delegate) {
            [_delegate cellWasSelected:self];
        }
        
    }
    else if (!highlighted && _highlighted){
        
        NSLog(@"unhighlight %@", self.name);
        
        [self setColor:_normalColor];
        
        if (_delegate) {
            [_delegate cellWasDeSelected:self];
        }
    }
    
    _highlighted = highlighted;
//    
//    int numVerticies = box->getMesh().getNumIndices();
//    box->getMesh().setColorForIndices(0, numVerticies, color);
    
}

#pragma mark - Scroll

-(void)setNormalColor:(UIColor *)normalColor {
    if (!_highlighted) {
        [self setColor:normalColor];
    }
    _normalColor = normalColor;
}


-(float)contentSize {
    if (cdirty) {
        
        int tempSize = 0;
        
        for(int i = 0; i < intChildren.count; i++)
        {
            NKScrollNode *child = intChildren[i];
            
            if (_scrollDirectionVertical) {
                int temp = child.size.height;
                
                tempSize += temp + _verticalPadding;
            }
            else {
                int temp = child.size.width;
                tempSize += temp + _horizontalPadding;
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
    
    if (_scrollDirectionVertical) {
        
        if (_scrollPosition > _verticalPadding) {
            return _scrollPosition - _verticalPadding;
        }
        
        else {
            
            if (self.contentSize > self.size.height) {
                
                int diff = _scrollPosition + self.contentSize - self.size.height;
                if (diff < 0){
                    
                    return diff;
                    
                }
                
            }
            else {
                if (_scrollPosition < _verticalPadding) {
                    return _scrollPosition - _verticalPadding;
                }
            }
            
        }
        
    }
    
    else {
        
        if (_scrollPosition > _horizontalPadding) {
            return _scrollPosition - _horizontalPadding;
        }
        
        else {
            
            if (self.contentSize > self.size.width) {
                
                int diff = _scrollPosition + self.contentSize - self.size.width;
                
                if (diff < 0){
                    
                    return diff;
                    
                }
                
            }
            else {
                if (_scrollPosition < _horizontalPadding) {
                    return _scrollPosition - _horizontalPadding;
                }
            }
            
        }
        
        
    }
    
    return 0;
    
}

-(void) setChildFrame:(NKScrollNode *)child{
    
    if (_fdirty) {
        
        if (_scrollDirectionVertical){
            
            int tempSize = 0;
            for(int i = 0; i < [intChildren indexOfObject:child]; i++)
            {
                int temp = [intChildren[i] size].height;
                tempSize += temp + _verticalPadding;
            }
            
            CGSize childSize;
            
            if ([child isKindOfClass:[NKScrollNode class]]) {
                childSize.height = self.size.height * child.autoSizePct;
                childSize.width = self.size.width-(_horizontalPadding);
                child.fdirty = true;
                
            }
            else {
                childSize = child.size;
            }
            
            [child setPosition3d:V3Make(0,self.size.height/2. - (tempSize + childSize.height/2.) + _scrollPosition,4)];
            
            [child setSize:childSize];
            
            
        }
        
        else {
            
            int tempSize = 0;
            for(int i = 0; i < [intChildren indexOfObject:child]; i++)
            {
                int temp = [intChildren[i] size].width;
                tempSize += temp + _horizontalPadding;
            }
            
            CGSize childSize;
            
            if ([child isKindOfClass:[NKScrollNode class]]) {
                childSize.width = self.size.width * child.autoSizePct;
                childSize.height = self.size.height-(_verticalPadding);
                child.fdirty = true;
                
            }
            else {
                childSize = child.size;
            }
            
            [child setPosition3d:V3Make(tempSize + childSize.width/2. + _scrollPosition - self.size.width/2.,0,4)];
            
            [child setSize:childSize];
            
        }
        
        child.hidden = [child shouldCull];
        
        
        
    }
    
}

-(bool)shouldCull {
    
    return [self scrollShouldCull];
    
}
-(bool)scrollShouldCull {
    
    return false;
    
    R4t d = [self.parent getDrawFrame];
    
    if ([(NKScrollNode*)self.parent scrollDirectionVertical] && (self.position3d.y + self.size.height/2. < d.y ||
                                                                 self.position3d.y - self.position3d.y/2. > d.y + self.parent.size.height)) {
        return true;
    }
    
    else if (self.position3d.x + self.size.width/2. < d.x || self.position3d.x - self.size.width/2. > d.x + d.w) {
        return true;
    }
    
}

-(void)setScrollPosition:(float)scrollPosition {
    [self setScrollPostion:scrollPosition animated:false];
}

-(void)setScrollPostion:(int)offset animated:(bool)animated {
    
    if (_scrollPosition != offset) {
        _scrollPosition = offset;
        _fdirty = true;
    }
    
}

#pragma mark - update / draw

-(void)updateWithTimeSinceLast:(F1t)dt {
    
    [super updateWithTimeSinceLast:dt];
    
    if  (_scrollingEnabled){
        
        
        if (_scrollPhase != ScrollPhaseNil) {
            
            if (fabsf(scrollVel) > restitution){
                scrollVel = scrollVel / drag;
            }
            
            else {
                scrollVel = 0;
            }
            
            
            if (fabsf(counterVel) > restitution){
                counterVel = counterVel / drag;
            }
            
            else {
                counterVel = 0;
            }
            
        }
        
        if (_scrollPhase == ScrollPhaseEnded) {
            
            drag = 1.04;
            
            if (scrollVel != 0 && !self.outOfBounds) {
                [self setScrollPosition:_scrollPosition + scrollVel];
            }
            
            else {
                _scrollPhase = ScrollPhaseRestitution;
                easeIn = 20;
                easeOut = false;
                //NSLog(@"start restitution");
            }
            
        }
        
        if (_scrollPhase == ScrollPhaseRestitution) {
            
            scrollVel = 0;
            
            if (!easeOut) {
                if (easeIn > 5) easeIn--;
                else easeOut = true;
            }
            else {
                if (easeIn < 20) easeIn++;
            }
            
            float dir = self.outOfBounds;
            
            if (dir != 0) {
                [self setScrollPosition:_scrollPosition - dir / easeIn];
            }
            
            else {
                //NSLog(@"scroll stopped");
                _scrollPhase = ScrollPhaseNil;
            }
            
        }
        
    }
    
    if (_scrollingEnabled){
        if (_fdirty || cdirty) {
            for (int i = 0; i < intChildren.count; i++){
                [self setChildFrame:intChildren[i]];
            }
            
            _fdirty = false;
        }
    }
    
}


#pragma mark - Touch Handling

// TOUCH HANDLING

-(NKTouchState) touchDown:(CGPoint)location id:(int) touchId
{

     NKTouchState hit = NKTouchNone;
    
    if (_scrollingEnabled) {
        
        if  (self.userInteractionEnabled){
            
            if ([self containsPoint:location]) {
                
                
                
                
                _scrollPhase = ScrollPhaseBegan;
                
                xOrigin = location.x;
                yOrigin = location.y;
                
                counterVel = 0;
                scrollVel = 0;
                
                drag = 1.5;
                
                return NKTouchIsFirstResponder;
                
            }
            
            
            
        }
        
        return NKTouchNone;
        
    }
    
    else {
        hit = [super touchDown:location id:touchId];
        
        if (hit == NKTouchIsFirstResponder) {
            NSLog(@"highlight yes!");
            [self setHighlighted:true];
        }
        else {
            [self setHighlighted:false];
        }
    }
        

    return hit;
    
}

-(NKTouchState)touchMoved:(CGPoint)location id:(int)touchId {
    
    NKTouchState hit = NKTouchNone;
    
    if  (_scrollingEnabled) {
        
        if (self.userInteractionEnabled) {
            
            if ([self containsPoint:location]) {
                
                hit = NKTouchIsFirstResponder;
                
                int sDt;
                int cDt;
                
                if (_scrollDirectionVertical) {
                    sDt = (location.y - yOrigin);
                    cDt = (location.x - xOrigin);
                }
                else {
                    sDt = (location.x - xOrigin);
                    cDt = (location.y - yOrigin);
                }
                
                xOrigin = location.x;
                yOrigin = location.y;
                
                scrollVel += sDt;
                counterVel += cDt;
                
                if (_scrollPhase <= ScrollPhaseBegan){
                    
                    if (fabs(scrollVel) > fabs(counterVel) + (restitution * 2.)){
                        _scrollPhase = ScrollPhaseRecognized;
                        NSLog(@"Scroll started %f, %f", scrollVel, counterVel);
                        
                    }
                    
                    else if (fabs(counterVel) > fabs(scrollVel) + (restitution)){
                        NSLog(@"FAILED %f, %f", counterVel, scrollVel);
                        _scrollPhase = ScrollPhaseBeginFail;
                    }
                    
                }
                
                else if (_scrollPhase == ScrollPhaseRecognized){
                    
                    [self setScrollPostion:_scrollPosition + sDt animated:false];
                    
                }
                
                else if (_scrollPhase == ScrollPhaseBeginFail) {
                    
                    for (NKNode *child in intChildren) {
                        if ([child touchDown:location id:touchId ] > 0) {
                            hit = NKTouchContainsFirstResponder;
                        };
                    }
                    _scrollPhase = ScrollPhaseFailed;
                    
                }
                
                else if (_scrollPhase == ScrollPhaseFailed) {
                    
                    for (NKNode *child in intChildren) {
                        if ([child touchMoved:location id:touchId ] > 0) {
                            hit = NKTouchContainsFirstResponder;
                        };
                    }
                    
                    
                }
                
            }

        }
    }
    
    else {
        
        return [super touchMoved:location id:touchId];
    }
    
    return hit;
    
}

-(NKTouchState)touchUp:(CGPoint)location id:(int)touchId    {
    
    NKTouchState hit = NKTouchNone;
    
    if (_scrollingEnabled) {
        
        if (_scrollPhase == ScrollPhaseFailed || _scrollPhase == ScrollPhaseBegan || _scrollPhase == ScrollPhaseNil) {
            for (NKNode *child in intChildren) {
                if ([child touchUp:location id:touchId ] > 0){
                    hit = NKTouchContainsFirstResponder;
                }
            }
            _scrollPhase = ScrollPhaseNil;
        }
        
        else {
            hit = NKTouchIsFirstResponder;
            _scrollPhase = ScrollPhaseEnded;
        }
        
    }
    
    else {
        
        hit = [super touchUp:location id:touchId];
        
        if (hit == NKTouchIsFirstResponder) {
            [self setHighlighted:true];
        }
        
        else {
            [self setHighlighted:false];
        }
        
    }
    
    
    
    return hit;
    
    
}



@end
