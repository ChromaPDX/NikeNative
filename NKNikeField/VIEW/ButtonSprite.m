//
//  SSButtonSprite.m
//  PatchBook
//
//  Created by Leif Shackelford on 7/7/13.
//  Copyright (c) 2013 Structure Sound. All rights reserved.
//

#import "NodeKitten.h"

#import "ButtonSprite.h"

@implementation ButtonSprite

+ (instancetype) buttonWithTextureOn:(NKTexture*)textureOn TextureOff:(NKTexture*)textureOff type:(ButtonType)type size:(S2t) size {
    
    ButtonSprite* button = [super spriteNodeWithTexture:textureOff size:size];
    button.userInteractionEnabled = YES;
    button.onTexture = textureOn;
    button.offTexture = textureOff;
    [button setColor:NKCLEAR];
    button.type = type;
    button.state = ButtonStateOff;
    return button;
}

+ (instancetype) buttonWithNames:(NSArray*)names color:(NSArray*)colors type:(ButtonType)type size:(S2t) size {
    
    ButtonSprite* button = [super spriteNodeWithColor:colors[0] size:S2Make(size.width-2, size.height-2)];
    button.userInteractionEnabled = YES;
    button.type = type;
    button.stateLabels = names;
    button.stateColors = colors;
    button.label = [NKLabelNode labelNodeWithFontNamed:@"Arial Black.ttf"];
    button.label.fontSize = 16;
    button.label.fontColor = NKBLACK;
    button.state = ButtonStateOff;
    button.label.text = button.stateLabels[button.state];
    button.label.verticalAlignmentMode = NKLabelVerticalAlignmentModeCenter;
    [button addChild:button.label];
    return button;
    
}

-(void) setFontSize:(CGFloat)fontSize{
    _fontSize = fontSize;
    self.label.fontSize = fontSize;
}

-(void)handleEvent:(NKEvent *)event {
    
    if (NKEventPhaseBegin == event.phase) {
        
        switch (self.type) {
                
            case ButtonTypeToggle:
                
                self.state = 1 - self.state;
                
                // *dataSource = self.state;
                
                if (_delegate) {
                    if (_method) {
                        [_delegate performSelector:_method withObject:self];
                        
                    }
                }
                
                break;
                
            case ButtonTypePush:
                self.state = 1;
                
                if (_delegate) {
                    if (_method) {
                        [_delegate performSelector:_method withObject:self];
                        
                    }
                }
                
                
                break;
                
            default:
                break;
                
        }
        
    }
    else if (NKEventPhaseEnd == event.phase) {
        switch (self.type) {
            case ButtonTypePush:
                
                self.state = 0;
                
                break;
                
            default:
                break;
                
        }
    }
    
    
}

-(void) setBorder:(BOOL)border{
    _border = border;
    [self setState:self.state];
}

-(void)setState:(ButtonState)state {
    
    if(_onTexture){
        switch (self.type) {
            case ButtonTypeToggle: case ButtonTypePush:
                switch (state) {
                    case ButtonStateOn:
                        [self setTexture:_onTexture];
                        break;
                    case ButtonStateOff:
                        [self setTexture:_offTexture];
                        break;
                    default:
                        break;
                }
                break;
            default:
                break;
        }
        return;
    }
    
    _state = state;
    self.label.text = _stateLabels[_state];
    
    switch (self.type) {
            
        case ButtonTypeToggle: case ButtonTypePush:
            
            switch (state) {
                case ButtonStateOn:
                    //self.texture = Nil;
                    [self setTexture:[NKTexture textureWithImage:[self drawBorder:_stateColors[_state]]]];
                    break;
                    
                case ButtonStateOff:
                    
                    [self setTexture:[NKTexture textureWithImage:[self drawBorder:_stateColors[_state]]]];
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}


- (NKImage*) drawGradient:(NKByteColor*)color{

    CGContextRef con = [NKImage newRGBAContext:S2Make(w, h)];
    
    CGContextTranslateCTM(con, 0.0, h);
    
    CGContextScaleCTM(con, 1.0, -1.0);
    
    CGContextClearRect(con, CGRectMake(0, 0, w, h));
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat components[8];
    CGFloat locations[3] = {0, 1};
    
    
    CGPoint bottomPoint, topPoint;
    
    C4t colors = color.C4Color;
    
    for (int c = 0; c<4; c++){
        components[c] = colors.v[c];
        components[c + 4] = colors.v[c] + .15;
    }
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, components, locations, 2);
    
    
    bottomPoint = CGPointMake(w / 2 , 0);
    topPoint = CGPointMake(w / 2, h);
    
    CGContextDrawLinearGradient(con, gradient, bottomPoint, topPoint, 0);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorspace);
    
    // [border stroke];
    
    NKImage* render = [NKImage nkImageWithCGImage:CGBitmapContextCreateImage(con)];
    
    CGContextRelease(con);
    
    return render;
    
}

- (NKImage*) drawBorder:(NKColor*)color {
    
    CGContextRef con = [NKImage newRGBAContext:S2Make(w, h)];
    
    CGContextClearRect(con, CGRectMake(0, 0, w, h));
    
#if TARGET_OS_IPHONE
    UIBezierPath *border = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, w, h) byRoundingCorners:15 cornerRadii:CGSizeMake(0, 0)];;
#else
    NSBezierPath *border = [NSBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, w, h) xRadius:10 yRadius:10 ];
#endif
    
    border.lineWidth = 2.;
    
    
    [[NKColor whiteColor] setStroke];
    [color setFill];
    
    
    [border fill];
    if(_border)
        [border stroke];
    
    NKImage* render = [NKImage nkImageWithCGImage:CGBitmapContextCreateImage(con)];
    
    CGContextRelease(con);
    
    return render;
    
}


@end
