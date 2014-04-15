//
//  SSButtonSprite.m
//  PatchBook
//
//  Created by Leif Shackelford on 7/7/13.
//  Copyright (c) 2013 Structure Sound. All rights reserved.
//

#import "ofxNodeKitten.h"

#import "ButtonSprite.h"

@implementation ButtonSprite

+ (instancetype) buttonWithTextureOn:(NKTexture*)textureOn TextureOff:(NKTexture*)textureOff type:(ButtonType)type size:(CGSize) size {
    
    ButtonSprite* button = [super spriteNodeWithTexture:textureOff size:size];
    button.userInteractionEnabled = YES;
    button.onTexture = textureOn;
    button.offTexture = textureOff;
    [button setColor:[UIColor clearColor]];
    button.type = type;
    button.state = ButtonStateOff;
    return button;
}

+ (instancetype) buttonWithNames:(NSArray*)names color:(NSArray*)colors type:(ButtonType)type size:(CGSize) size {
    
    ButtonSprite* button = [super spriteNodeWithColor:colors[0] size:CGSizeMake(size.width-2, size.height-2)];
    button.userInteractionEnabled = YES;
    button.type = type;
    button.stateLabels = names;
    button.stateColors = colors;
    button.label = [NKLabelNode labelNodeWithFontNamed:@"TradeGothicLTStd-BdCn20"];
    button.label.fontSize = 16;
    button.label.fontColor = [NKColor blackColor];
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


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
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

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    switch (self.type) {
        case ButtonTypePush:
            
            self.state = 0;
            
            break;
            
        default:
            break;
            
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


- (UIImage*) drawGradient:(UIColor*)color{
    
    float w = self.size.width;
    float h = self.size.height;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(w, h), NO, 0);
    
    CGContextRef con = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(con, 0.0, h);
    
    CGContextScaleCTM(con, 1.0, -1.0);
    
    CGContextClearRect(con, CGRectMake(0, 0, w, h));
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    float components[8];
    float locations[3] = {0, 1};
    
    float colors[4];
    
    [color getRed:&colors[0] green:&colors[1] blue:&colors[2] alpha:&colors[3]];
    
    CGPoint bottomPoint, topPoint;
    
    for (int c = 0; c<4; c++){
        components[c] = colors[c];
        components[c + 4] = colors[c] + .15;
    }
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, components, locations, 2);
    
    
    bottomPoint = CGPointMake(w / 2 , 0);
    topPoint = CGPointMake(w / 2, h);
    
    CGContextDrawLinearGradient(con, gradient, bottomPoint, topPoint, 0);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorspace);
    
    // [border stroke];
    
    UIImage* render =  UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return render;
    
}

- (UIImage*) drawBorder:(UIColor*)color {
    
    float w = self.size.width;
    float h = self.size.height;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(w, h), NO, 0);
    
    CGContextRef con = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(con, CGRectMake(0, 0, w, h));
    
    UIBezierPath *border = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, w, h) byRoundingCorners:15 cornerRadii:CGSizeMake(0, 0)];;
    
    border.lineWidth = 2.;
    
    
    [[UIColor whiteColor] setStroke];
    [color setFill];
    
    
    [border fill];
    if(_border)
        [border stroke];
    
    UIImage* render =  UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return render;
    
}


@end
