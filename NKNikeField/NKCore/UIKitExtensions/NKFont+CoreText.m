//
//  UIFont+UIFont_CoreText.m
//  NKNikeField
//
//  Created by Leif Shackelford on 4/30/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#import "NKFont+CoreText.h"

@implementation NKFont (CoreTextExtensions)

- (CTFontRef)createCTFont;
{
    CTFontRef font = CTFontCreateWithName((CFStringRef)self.fontName, self.pointSize, NULL);
    return font;
}

+ (CTFontRef)bundledFontNamed:(NSString *)name size:(CGFloat)size
{
    // Adapted from http://stackoverflow.com/questions/2703085/how-can-you-load-a-font-ttf-from-a-file-using-core-text
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    if (path) {
    CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)path, kCFURLPOSIXPathStyle, false);
    CGDataProviderRef dataProvider = CGDataProviderCreateWithURL(url);
    CGFontRef theCGFont = CGFontCreateWithDataProvider(dataProvider);
    CTFontRef result = CTFontCreateWithGraphicsFont(theCGFont, size, NULL, NULL);
    CFRelease(theCGFont);
    CFRelease(dataProvider);
    CFRelease(url);
    return result;
    }
    
    NSLog(@"CoreText: Error loading Font from Bundle named %@", name);
    return CTFontCreateWithName((CFStringRef) @"Helvetica", size, NULL);
}

@end