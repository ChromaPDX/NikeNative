//
//  ofxTableNode.m
//  example-ofxTableView
//
//  Created by Chroma Developer on 2/18/14.
//
//

#import "NodeKitten.h"

@implementation NKScrollNode

-(instancetype) initWithTexture:(NKTexture *)texture color:(UIColor *)color size:(S2t)size {
    
    self = [super initWithTexture:texture color:color size:size];
    
    if (self) {
        
        _normalColor = color;
        [self tableInit];
        
    }
    
    return self;
    
}

-(instancetype) initWithColor:(UIColor *)color size:(S2t)size {
    
    self = [super initWithColor:color size:size];
    
    if (self) {
        _normalColor = color;
        [self tableInit];
    }
    
    return self;
}

-(void)tableInit {

    _highlightColor = NKWHITE;
    
    _scrollDirectionVertical = true;
    _scrollingEnabled = true;
    _padding = P2Make(10,10);
    _fdirty = true;
    
    self.userInteractionEnabled = true;
    
    restitution = 3;
    drag = 1.5;

}

-(instancetype) initWithParent:(NKScrollNode *)parent autoSizePct:(float)autoSizePct {
    
    if (!parent){
        return nil;
    }
    
    S2t size;
    if (parent.scrollDirectionVertical) {
        size = S2Make(parent.size.width, parent.size.height*autoSizePct);
    }
    else {
        size = S2Make(parent.size.width*autoSizePct,parent.size.height);
    }
    
    self = [super initWithColor:NKCLEAR size:size];
    
    if (self) {
        
        if (parent.scrollDirectionVertical) {
             _autoSizePct.y = autoSizePct;
            _autoSizePct.x = 1.;
        }
        else {
            _autoSizePct.x = autoSizePct;
            _autoSizePct.y = 1.;
 
        }
       
        _scrollingEnabled = false;
        _padding = P2Make(0,0);
        
        _delegate = parent;
        
        parent->cdirty = true;
        parent.fdirty = true;
        
        restitution = 3;
        drag = 1.5;
        
        self.userInteractionEnabled = false;
    }
    
    return self;
    
}

#pragma DRAW etc.

-(void)setHighlighted:(bool)highlighted {
    
    if (highlighted && !_highlighted) {
        
        NSLog(@"highlight %@", self.name);
        
        [self setColor:_highlightColor];

        [_delegate cellWasSelected:(NKScrollNode*)self];
    }
    else if (!highlighted && _highlighted){
        
        NSLog(@"unhighlight %@", self.name);
        
        [self setColor:_normalColor];
        
         [_delegate cellWasDeSelected:(NKScrollNode*)self];
        
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


-(P2t)contentSize {
    if (cdirty) {
        
        contentSize = P2Make(0,0);
        
        for(int i = 0; i < intChildren.count; i++)
        {
            NKScrollNode *child = intChildren[i];
            
            //            if (_scrollDirectionVertical) {
            //                int temp = child.size.height;
            //
            //                tempSize.y += temp + _padding.y;
            //            }
            //            else {
            //                int temp = child.size.width;
            //
            //                tempSize.x += temp + _padding.x;
            //            }
            
            P2t cSize = P2Make(child.size.width + _padding.x, child.size.height + _padding.y);
            contentSize = P2Add(contentSize, cSize);
            
        }
        
        cdirty = false;
        
        
    }
    
    
    return contentSize;
    
}

-(P2t)outOfBounds {
    
    if (_scrollDirectionVertical) {
        
        if (_scrollPosition.y > _padding.y + (contentOffset.y*w)) {
            return P2Make(0,_scrollPosition.y - _padding.y);
        }
        
        else {
            
            if (self.contentSize.y > self.size.height) {
                
                int diff = _scrollPosition.y + self.contentSize.y - self.size.height;
                if (diff < 0){
                    return P2Make(0, diff);
                }
            }
            else {
                if (_scrollPosition.y < _padding.y) {
                    return P2Make(0,_scrollPosition.y - _padding.y);
                }
            }
        }
    }
    
    else {
        
        if (_scrollPosition.x > _padding.x + (contentOffset.x*w)) {
            return P2Make(_scrollPosition.x - _padding.x,0);
        }
        
        else {
            
            if (self.contentSize.x > self.size.width) {
                
                int diff = _scrollPosition.x + self.contentSize.x - self.size.width;
                if (diff < 0){
                    
                    return P2Make(diff,0);
                    
                }

                
            }
            else {
                if (_scrollPosition.x < _padding.x) {
                    return P2Make(_scrollPosition.x - _padding.x,0);
                }
            }
            
        }
        
        
    }
    
    return P2Make(0,0);
    
}

-(void) setChildFrame:(NKScrollNode *)child{
    
    if (_fdirty) {
        
        if (_scrollDirectionVertical){
            
            int tempSize = 0;
            for(int i = 0; i < [intChildren indexOfObject:child]; i++)
            {
                int temp = [(NKNode*)intChildren[i] size].height;
                tempSize += temp + _padding.y;
            }
            
            S2t childSize;
            
            if ([child isKindOfClass:[NKScrollNode class]]) {
                childSize.height = self.size.height * child.autoSizePct.y;
                childSize.width = self.size.width-(_padding.x);
                child.fdirty = true;
                
            }
            else {
                childSize = child.size;
            }
            
            [child setPosition3d:V3Make(0,self.size.height/2. - (tempSize + childSize.height/2.) + _scrollPosition.y,4)];
            
            [child setSize:childSize];
            
            
        }
        
        else {
            
            int tempSize = 0;
            for(int i = 0; i < [intChildren indexOfObject:child]; i++)
            {
                int temp = [(NKNode*)intChildren[i] size].width;
                tempSize += temp + _padding.x;
            }
            
            S2t childSize;
            
            if ([child isKindOfClass:[NKScrollNode class]]) {
                childSize.width = self.size.width * child.autoSizePct.x;
                childSize.height = self.size.height-(_padding.y);
                child.fdirty = true;
                
            }
            else {
                childSize = child.size;
            }
            
            [child setPosition3d:V3Make(tempSize + childSize.width/2. + _scrollPosition.x - self.size.width/2.,0,4)];
            
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
    
    R4t r = [self.parent getDrawFrame];
    
    if ([(NKScrollNode*)self.parent scrollDirectionVertical] && (self.position3d.y + self.size.height/2. < r.y ||
                                                                 self.position3d.y - self.position3d.y/2. > r.y + self.parent.size.height)) {
        return true;
    }
    
    else if (self.position3d.x + self.size.width/2. < r.x || self.position3d.x - self.size.width/2. > r.x + r.size.width) {
        return true;
    }
    
}


-(P2t)scrollPositionForChild:(int)child {
    
    if (_scrollDirectionVertical) {
        return P2Make(0,-([(NKNode*)intChildren[child] size].height + _padding.y) * (child) + h*contentOffset.y);
    }
    else {
        return P2Make(-([(NKNode*)intChildren[child] size].width + _padding.x) * (child) + w*contentOffset.x, 0);
    }
    
    
}

-(void)scrollToChild:(int)child duration:(F1t)duration {
    [self runAction:[NKAction scrollToPoint:[self scrollPositionForChild:child] duration:duration]];
}

-(void)setScrollPosition:(P2t)scrollPosition {
    _scrollPosition = scrollPosition;
    _fdirty = true;
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
            
            [self endScroll];
            
        }
        
        if (_scrollPhase == ScrollPhaseRestitution) {
            
            [self scrollRestitution];
            
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

-(void)endScroll {
    drag = 1.04;
    
    if (scrollVel != 0 && !P2Bool(self.outOfBounds)) {
        
        if (_scrollDirectionVertical) {
            [self setScrollPosition:P2Make(_scrollPosition.x, _scrollPosition.y + scrollVel)];
        }
        else {
            [self setScrollPosition:P2Make(_scrollPosition.x + scrollVel, _scrollPosition.y)];
        }
        
    }
    
    else {
        [self shouldBeginRestitution];
        
        _scrollPhase = ScrollPhaseRestitution;
        easeIn = 12.;
        easeOut = false;
        //NSLog(@"start restitution");
    }

}

-(void)scrollRestitution {
    scrollVel = 0;
    
    if (!easeOut) {
        if (easeIn > 4.) easeIn--;
        else easeOut = true;
    }
    else {
        if (easeIn < 12.) easeIn++;
    }
    
    P2t dir = self.outOfBounds;
    
    if (P2GreaterFloat(dir, restitution)) {
        [self setScrollPosition:P2Subtract(_scrollPosition,P2DivideFloat(dir,easeIn))];
       // NSLog(@"restituting %f, %f to scroll p %f ,%f", P2DivideFloat(dir,easeIn).x, P2DivideFloat(dir,easeIn).y,_scrollPosition.x, _scrollPosition.y);
    }
    
    else {
        //NSLog(@"scroll stopped");
        _scrollPhase = ScrollPhaseNil;
        [self scrollDidEnd];
    }
}

-(bool)scrollShouldStart {
    return true;
}

-(void)shouldBeginRestitution {
    
}

-(void)scrollDidEnd {
    
}

#pragma mark - Touch Handling

-(void)cellWasSelected:(NKScrollNode *)cell {
    [_delegate cellWasSelected:cell];
}

-(void)cellWasDeSelected:(NKScrollNode *)cell {
    [_delegate cellWasDeSelected:cell];
}

// TOUCH HANDLING

-(NKTouchState) touchDown:(P2t)location id:(int) touchId
{

    NKTouchState hit = NKTouchNone;
    
    if (_scrollingEnabled) {
        
        if  (self.userInteractionEnabled){
            
            //if ([self containsPoint:location]) {

                _scrollPhase = ScrollPhaseBegan;
                
                xOrigin = location.x;
                yOrigin = location.y;
                
                counterVel = 0;
                scrollVel = 0;
                
                drag = 1.5;
                
                return NKTouchIsFirstResponder;
                
                  NSLog(@"table touch down");
            //}
            
        }
        
        return NKTouchNone;
        
    }
    
    else {
        
        
        hit = [super touchDown:location id:touchId];
        
        if (hit == NKTouchIsFirstResponder) {
            NSLog(@"cell selected");
            [self setHighlighted:true];
        }
        else {
            [self setHighlighted:false];
        }
    }
        

    return hit;
    
}

-(void)scrollEnded {
    
}

-(NKTouchState)touchMoved:(P2t)location id:(int)touchId {
    
    NKTouchState hit = NKTouchNone;
    
    if  (_scrollingEnabled) {
        
        if (self.userInteractionEnabled) {
            
            //if ([self containsPoint:location]) {
                
                hit = NKTouchIsFirstResponder;
                
                int sDt;
                int cDt;
                P2t dt = P2Make(0,0);
                
                if (_scrollDirectionVertical) {
                    sDt = (location.y - yOrigin);
                    cDt = (location.x - xOrigin);
                    dt.y = sDt;
                    
                }
                else {
                    sDt = (location.x - xOrigin);
                    cDt = (location.y - yOrigin);
                    dt.x = sDt;
                }

                xOrigin = location.x;
                yOrigin = location.y;
                
                scrollVel += sDt;
                counterVel += cDt;
                
                if (_scrollPhase <= ScrollPhaseBegan){
                    
                    if (fabs(scrollVel) > fabs(counterVel) + (restitution * 2.)){
                  
                        if ([self scrollShouldStart]) {
                                  _scrollPhase = ScrollPhaseRecognized;
                        };
                        //NSLog(@"Scroll started %f, %f", scrollVel, counterVel);
                        
                    }
                    
                    else if (fabs(counterVel) > fabs(scrollVel) + (restitution)){
                        NSLog(@"FAILED %f, %f", counterVel, scrollVel);
                        _scrollPhase = ScrollPhaseBeginFail;
                    }
                    
                }
                
                else if (_scrollPhase == ScrollPhaseRecognized){
                    [self setScrollPosition:P2Add(_scrollPosition,dt) ];
                    
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
                
          //  }

        }
    }
    
    else {
        
        return [super touchMoved:location id:touchId];
    }
    
    return hit;
    
}

-(NKTouchState)touchUp:(P2t)location id:(int)touchId    {
    
   
    NKTouchState hit = NKTouchNone;
    
    if (_scrollingEnabled) {
        
        if (_scrollPhase == ScrollPhaseFailed || _scrollPhase == ScrollPhaseBegan || _scrollPhase == ScrollPhaseNil) {
            for (NKNode *child in intChildren) {
                if ([child touchUp:location id:touchId ] > 0){
                    hit = NKTouchContainsFirstResponder;
                    
                      [_delegate cellWasSelected:(NKScrollNode*)child];
                    
                }
            }
            _scrollPhase = ScrollPhaseNil;
        }
        
        else {
            hit = NKTouchIsFirstResponder;
            _scrollPhase = ScrollPhaseEnded;
            [self scrollEnded];
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
