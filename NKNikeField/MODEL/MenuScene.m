//
//  MenuScene.m
//  nike3dField
//
//  Created by Chroma Developer on 3/25/14.
//
//

#include "ofApp.h"
#import "MenuScene.h"
#import "ofxNodeKitten.h"


@implementation MenuScene


-(instancetype)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    
    if (self) {
        // _MenuNode = [[MenuNode alloc] initWithSize:self.size];
        
        // [self addChild:_MenuNode];
        
        // [_MenuNode startMenu];
        
        
        char* extensionList = (char*)glGetString(GL_EXTENSIONS);
        
        ofLogNotice("GL") << string(extensionList);
        
        NKScrollNode* table = [[NKScrollNode alloc] initWithColor:nil size:self.size];
        [self addChild:table];
        [table setVerticalPadding:0];
        [table setHorizontalPadding:0];
        // table.scrollingEnabled = true;
        // table.scale = 1.02;  // to correct for image...this needs to be fixed
        table.name = @"table";
        table.delegate = self;
        //ofVec3f rot =
        //table.node->setOrientation
        
        NKTexture *image;
        UIColor *highlightColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.5];
        
        NKScrollNode *subTable = [[NKScrollNode alloc] initWithParent:table autoSizePct:.62];
        [table addChild:subTable];
        subTable.color = [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0];
        // subTable.scrollingEnabled = true;
        image = [NKTexture textureWithImageNamed:[NSString stringWithFormat:@"menu1_a.png"]];
        [subTable setTexture:image];
        [subTable setHighlightColor:highlightColor];
        subTable.name = @"1";
        subTable.delegate = self;
        
        NKScrollNode *subTable2 = [[NKScrollNode alloc] initWithParent:table autoSizePct:.13];
        [table addChild:subTable2];
        subTable2.color = [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0];
        [subTable2 setHighlightColor:highlightColor];
        image = [NKTexture textureWithImageNamed:[NSString stringWithFormat:@"menu1_b.png"]];
        [subTable2 setTexture:image];
        subTable2.name = @"2";
        subTable2.delegate = self;
        
        NKScrollNode *subTable3 = [[NKScrollNode alloc] initWithParent:table autoSizePct:.125];
        [table addChild:subTable3];
        subTable3.color = [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0];
        // [subTable3 setHighlightColor:highlightColor];
        // subTable3.scrollingEnabled = true;
        image = [NKTexture textureWithImageNamed:[NSString stringWithFormat:@"menu1_c.png"]];
        [subTable3 setTexture:image];
        subTable3.name = @"3";
        subTable3.delegate = self;

        
        NKScrollNode *subTable4 = [[NKScrollNode alloc] initWithParent:table autoSizePct:.125];
        [table addChild:subTable4];
        subTable4.color = [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0];
        //[subTable4 setHighlightColor:highlightColor];
        //subTable4.scrollingEnabled = true;
        image = [NKTexture textureWithImageNamed:[NSString stringWithFormat:@"menu1_d.png"]];
        [subTable4 setTexture:image];
        subTable4.name = @"4";
        subTable4.delegate = self;

        
        // setupCM();
        //subTable.node->setOrientation(ofVec3f(0,1,0));
        
    }
    return self;
}


-(void)cellWasSelected:(NKScrollNode *)cell {
    NSLog(@"MainMenu cellWasSelected: %@ was selected", cell.name);
    
    if ([cell.name isEqualToString:@"1"]) {
    }
    
    else if ([cell.name isEqualToString:@"2"]) {
    //    MenuPlayerProfileScene* newScene = [[MenuPlayerProfileScene alloc]initWithSize:self.size];
    //    ((ofApp*)ofGetAppPtr())->scene = newScene;
    }
    
    else if ([cell.name isEqualToString:@"3"]) {
    }
}

-(void)cellWasDeSelected:(NKScrollNode *)cell {
    
}

@end
