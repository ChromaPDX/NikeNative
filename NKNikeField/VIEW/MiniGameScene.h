//
//  MiniGameScene.h
//  nike3dField
//
//  Created by Chroma Developer on 3/25/14.
//
//

#import "NKSceneNode.h"
#import "MiniGames.h"

@interface MiniGameScene : NKSceneNode <MiniCupsObjDelegate,MiniMazeObjDelegate,MiniTouchObjDelegate>

@property (nonatomic, strong) MiniGameNode* miniGameNode;

@end
