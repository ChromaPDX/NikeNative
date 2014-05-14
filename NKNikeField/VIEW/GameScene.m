//
//  NKGameScene.m
//  nike3dField
//
//  Created by Chroma Developer on 2/27/14.
//
//

#import "NikeNodeHeaders.h"
#import "BoardLocation.h"
#import "ModelHeaders.h"

int THICK_LINE;
int MED_LINE;
float DRIBBLE_WIDTH;
float THUMB_OFFSET;
float UI_MULT;
float WINDOW_WIDTH;
float WINDOW_HEIGHT;
float ANCHOR_WIDTH;
float PARTICLE_SCALE;

#define BALL_SPEED .2

@interface GameScene (){
    float boardScale;
    NSMutableDictionary *playerSprites;
    BoardLocation *fingerLocationOnBoard;  // so far, used when moving a card onto the board, traversing over board tiles
    
    //    ButtonSprite *end;
    //    ButtonSprite *draw;
}
@end

@implementation GameScene

-(void)setOrientation:(Q4t)orientation {
    [_pivot setOrientation:orientation];
}

-(instancetype)initWithSize:(S2t)size {
    self = [super initWithSize:size];
    
    if (self) {
        
        if ([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPhone ) {
            THICK_LINE = 2;
            MED_LINE = 1;
            THUMB_OFFSET = .72;
            UI_MULT = 1.1;
            WINDOW_WIDTH = size.width*.265;
            WINDOW_HEIGHT = size.height;
            ANCHOR_WIDTH = size.width * .65;
            PARTICLE_SCALE = 1.;
            DRIBBLE_WIDTH = 3;
        }
        else {
            DRIBBLE_WIDTH = 6;
            THICK_LINE = 3;
            MED_LINE = 2;
            THUMB_OFFSET = .05;
            UI_MULT = 1.;
            WINDOW_WIDTH = size.width*.275;
            WINDOW_HEIGHT = size.height;
            ANCHOR_WIDTH = size.width * .65;
            PARTICLE_SCALE = 2.;
            
        }
        

        boardScale = 1.;
        
        _soundFiles = @{@"fieldSong":@"30 PWSteal.Ldpinch.D.mp3",
                        
                        @"cardTap":@"Androyd-Uck-41.wav",
                        @"cardLock":@"lock.aiff",
                        @"cardPlay":@"DotMatrix-Pang-84.wav",
                        @"cardSlideIn":@"swish.aiff",
                        @"cardExpand":@"expand.aiff",
                        @"cardContract":@"contract.aiff",
                        @"cardSwipe":@"PlucknWiggleA#1.wav",
                        
                        @"playerDeploy":@"DeStablizer-MetalBowl-41.wav",
                        @"playerTap":@"Androyd-Alert-84.wav",
                        @"enemyTap":@"Androyd-Agitake-42.wav",
                        @"playerMove":@"KnifeMachine-MindEraser-42.wav",
                        @"playerPass":@"slope-rattle.wav",
                        @"playerShoot":@"slope-rattle.wav",
                        
                        @"kickoff":@"kickoff.aiff",
                        @"goal":@"goal.aiff",
                        
                        @"challengeSuccessful":@"FattNedA4.wav",
                        @"challengeFail":@"Tom-FMD-TomiVoz-Lo-127.wav",
                        
                        @"badTouch":@"anomaly_7.wav"
                        };
        
        _soundVolumes = @{@"fieldSong": @.5,
                          @"cardExpand":@.5,
                          @"cardContract":@.5,
                          @"cardPlay":@.5,
                          @"cardSwipe":@.5,
                          @"cardLock":@4.,
                          @"playerMove":@1.5,
                          @"playerPass":@2.,
                          @"playerShoot":@2.,
                          @"playerTap":@.75
                          };
        
        [NKSoundManager loadMultipleSoundFiles:_soundFiles.allValues];
        
        //
        //        _scoreBoard = [[ScoreBoard alloc] initWithTexture:nil color:nil size:S2Make(WINDOW_WIDTH*2., WINDOW_WIDTH*.5)];
        //        [_scoreBoard setPosition:P2Make(ANCHOR_WIDTH, self.size.height*.978333)];
        //        [_scoreBoard setDelegate:self];
        //        [_scoreBoard setZPosition:Z_INDEX_BOARD+2];
        //        _scoreBoard.delegate = self;
        //
        //        [self addChild:_scoreBoard];
        //
        //        _fuelBar = [[FuelBar alloc]initWithTexture:[NKTexture textureWithImageNamed:@"BoostBarFull"] color:Nil size:S2Make(size.height*.05625, size.height*.9)];
        //        [self addChild:_fuelBar];
        //        [_fuelBar setPosition:P2Make(WINDOW_WIDTH + size.height*.015, size.height*.49)];
        //        [_fuelBar setZPosition:Z_INDEX_BOARD];
        //
        //        NSLog(@"fuelBarSize: %f %f", size.height*.05625,size.height*.5);
        
        [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1.] ];
        
        _game = [[Game alloc] init];
        _game.gameScene = self;
        
        
        
    }
    
    return self;
}

-(void)setupGameBoard {
    
    NKSpriteNode* bg = [NKSpriteNode spriteNodeWithTexture:[NKTexture textureWithImageNamed:@"Background_Field"] size:S2Make(w*2, h*2)];
    [self addChild:bg];
    [bg setZPosition:-1000];
    
    
    NSLog(@"setup gameBoard %f :%f",w,h);
    
    playerSprites = [NSMutableDictionary dictionaryWithCapacity:(BOARD_LENGTH * BOARD_WIDTH)];
    _gameTiles = [NSMutableDictionary dictionaryWithCapacity:(BOARD_LENGTH * BOARD_WIDTH)];
    
    _pivot = [[NKNode alloc]init];
    
    
    _pivot.name = @"PIVOT";
    
    [self addChild:_pivot];
    [_pivot setPosition3d:(V3Make(0,-h*.5,0))];
    
    
    _uxWindow = [[UXWindow alloc] initWithTexture:nil color:[NKColor colorWithRed:0. green:0. blue:0. alpha:.8] size:S2Make(w, h*.15)];
    [_uxWindow setPosition3d:V3Make(0,-h*.42,30)];
    _uxWindow.delegate = self;
    [self addChild:_uxWindow];
    [_uxWindow setAlpha:0];
    
    _uxTopBar = [[UXTopBar alloc] initWithTexture:nil color:[NKColor colorWithRed:0. green:0. blue:0. alpha:0]  size:S2Make(w, h*.08)];
    [_uxTopBar setPosition3d:V3Make(0,h*.45,30)];
    _uxTopBar.delegate = self;
    [self addChild:_uxTopBar];
    [_uxTopBar setAlpha:0];
    
    //    NKSpriteNode *logo = [[NKSpriteNode alloc]initWithTexture:[NKTexture textureWithImageNamed:@"GAMELOGO.png"] color:nil size:S2Make(TILE_WIDTH*4, TILE_WIDTH*5.2)];
    //    [_pivot addChild:logo];
    //    [logo setZPosition:-3];
    
    
    //    _boardScroll = [[NKScrollNode alloc] initWithColor:nil size:S2Make(BOARD_WIDTH*TILE_WIDTH + (TILE_WIDTH*.7), BOARD_LENGTH*TILE_HEIGHT + (TILE_HEIGHT*.5))];
    //
    //    [_pivot addChild:_boardScroll];
    
    //_boardScroll.userInteractionEnabled = false;
    
    _gameBoardNode = [[GameBoardNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"Field_Layer01"] color:NKWHITE size:S2Make(BOARD_WIDTH*TILE_WIDTH + (TILE_WIDTH*.7), BOARD_LENGTH*TILE_HEIGHT + (TILE_HEIGHT*.5))];
    
    [_pivot addChild:_gameBoardNode];
    [_gameBoardNode setPosition3d:V3Make(0,h*.5,0)];
    _gameBoardNode.userInteractionEnabled = true;
    _gameBoardNode.name = @"Game Board";
    [_gameBoardNode setAlpha:.3];
    
    NKSpriteNode *lines = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"Field_Layer02"] color:NKWHITE size:_gameBoardNode.size];
    
    //[lines setBlendMode:NKBlendModeAdd];
    
    [_gameBoardNode addChild:lines];
    
    [lines setPosition3d:V3Make(0,0,2)];
    
    [lines setAlpha:0.3];
    
    for(int i = 0; i < BOARD_WIDTH; i++){
        for(int j = 0; j < BOARD_LENGTH; j++){
            BoardTile *square = [[BoardTile alloc] initWithTexture:Nil color:nil size:S2Make(TILE_WIDTH-2, TILE_HEIGHT-2)];
            
            [square setLocation:[BoardLocation pX:i Y:j]];
            
            square.delegate = self;
            
            [square setAlpha:.3];
            
            [_gameBoardNode addChild:square];
            
            [_gameTiles setObject:square forKey:square.location];
            
            [square setPosition3d:V3Make((i+.5)*TILE_WIDTH - (TILE_WIDTH*BOARD_WIDTH*.5), ((j+.5)*TILE_HEIGHT) - (TILE_HEIGHT*BOARD_LENGTH*.5),6) ];
        }
    }
    
    NKNode* playerLayer = [[NKNode alloc]init];
    playerLayer.name = @"playerLayer";
    [_gameBoardNode addChild:playerLayer];
    
    NKSpriteNode *glow = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"Field_Layer03"] color:NKWHITE size:_gameBoardNode.size];
    [glow setBlendMode:NKBlendModeAdd];
    [_gameBoardNode addChild:glow];
    [glow setPosition3d:V3Make(0,0,4)];
    
    [_pivot runAction:[NKAction rotate3dToAngle:V3Make(-26, 0,0) duration:2.]];
    [_pivot runAction:[NKAction move3dTo:V3Make(0,-h*.25,0) duration:2.]];
    
    [self playMusicWithKey:@"fieldSong"];
}

//-(void)startMiniGame {
//
//    _miniGameNode = [[MiniGameNode alloc] initWithSize:self.size];
//
//    [self addChild:_miniGameNode];
//
//    [_miniGameNode startMiniGame];
//
//    // [self loadShader:[[NKGaussianBlur alloc] initWithNode:self blurSize:4 numPasses:4]];
//
//}
//
//-(void)gameDidFinishWithWin {
//    [_miniGameNode removeFromParent];
//    _miniGameNode = nil;
//}
//
//-(void)gameDidFinishWithLose {
//    [_miniGameNode removeFromParent];
//    _miniGameNode = nil;
//}

#pragma mark - UI

#pragma mark - CREATE PLAYER EVENT

-(void)resetFingerLocation {
    fingerLocationOnBoard = [BoardLocation pX:-999 Y:-999];
}


#pragma mark - UX INTERACTION

-(BoardLocation*)locationOnBoardFromPoint:(P2t)location {
    
    return [BoardLocation pointWithP2:P2Make((location.x + _gameBoardNode.size.width/2.) / TILE_WIDTH,(location.y + _gameBoardNode.size.height/2.) /TILE_HEIGHT)];
    
}

-(BOOL)isNewLocation:(BoardLocation*)loc {
    
    if ([loc isEqual:fingerLocationOnBoard]) {
        return 0;
    }
    
    fingerLocationOnBoard = [loc copy];
    
    return 1;
    
}


-(void)cleanUpUIForSequence:(GameSequence *)sequence {
    for (BoardTile* tile in _gameTiles.allValues) {
        if([self.game.blockedBoardLocations containsObject:tile.location]){
          //  [tile removeAllActions];
           // [tile setColor:V2GREEN];
            NSArray *path = [[NSArray alloc] initWithObjects:tile.location, nil];
            [tile.location setBorderShapeInContext:path];
            [tile setTextureForBorder:tile.location.borderShape];
            [tile setUserInteractionEnabled:true];
           // [tile runAction:[NKAction fadeAlphaTo:1. duration:FAST_ANIM_DUR]];
            [tile setColor:V2RED];
        }
        else{
            [tile setColor:nil];
        }
        [tile setTexture:nil];
        [tile setUserInteractionEnabled:false];
    }
}



-(void)showCardPath:(NSArray*)path{
    
    for (BoardTile* tile in _gameTiles.allValues) {
        [tile setColor:nil];
        [tile setTexture:nil];
        [tile setUserInteractionEnabled:false];
        [tile runAction:[NKAction fadeAlphaTo:0. duration:FAST_ANIM_DUR]];
    }
    
    P2t p;
    
    if  (path.count){
        for (BoardLocation* loc in path) {
            BoardTile* tile = [_gameTiles objectForKey:loc];
            [tile removeAllActions];
            [tile setColor:V2GREEN];
            [tile.location setBorderShapeInContext:path];
            [tile setTextureForBorder:tile.location.borderShape];
            [tile setUserInteractionEnabled:true];
            [tile runAction:[NKAction fadeAlphaTo:.5 duration:FAST_ANIM_DUR]];
        }
        
        p  = [self centerOfBoundingBox:[_game boundingBoxForLocationSet:path]];
        [_gameBoardNode removeAllActions];
        [_gameBoardNode runAction:[NKAction moveTo:P2Make(0, -p.y + h/3.) duration:1.]];
    }
    
    //    else {
    //        p = [self centerOfBoundingBox:[_game boundingBoxForLocationSet:[_game allPlayerLocations]]];
    //        if ((-p.y + h/4.) > _gameBoardNode.position.y+100 || (-p.y + h/4.) < _gameBoardNode.position.y-100) { // filter out subtle moves
    //            [_gameBoardNode removeAllActions];
    //            [_gameBoardNode runAction:[NKAction moveTo:P2Make(0, -p.y + h/4.) duration:1.]];
    //        }
    //    }
    
}

-(void)playerSpriteDidSelectPlayer:(Player*)player {
    
    // ABORT IF SELECTING PLAYER AS CARD TARGET
    BoardTile *tile = [_gameTiles objectForKey:player.location];
    
    if (tile.userInteractionEnabled) {
        [self setSelectedBoardTile:tile];
        return;
    }
    
    [self setSelectedPlayer:player];
}

-(void)setSelectedPlayer:(Player*)selectedPlayer {
    
    if (![selectedPlayer.manager isEqual:_game.me]) {
        [self playSoundWithKey:@"enemyTap"];
    }
    
    else {
        
        if ([_game canUsePlayer:selectedPlayer]) {
            
            [self playSoundWithKey:@"playerTap"];
            
            [self showPlayerSelection:selectedPlayer];
            
            _selectedPlayer = selectedPlayer;
            
            [self refreshUXWindowForPlayer:selectedPlayer withCompletionBlock:^{
                if (_selectedCard) {
                    [self showCardPath:[_selectedCard validatedSelectionSetForPlayer:_selectedPlayer]];
                }
            }];
            
        }
        else {
            [self playSoundWithKey:@"badTouch"];
        }
        
    }
}

-(void)showPlayerSelection:(Player*)p{
    for (PlayerSprite *p in playerSprites.allValues) {
        [p setHighlighted:false];
    }
    [[playerSprites objectForKey:p] setHighlighted:true];
    
}

#pragma mark - AI selection

-(void)AISelectedPlayer:(Player *)selectedPlayer {
    
    //PlayerSprite *ps = [playerSprites objectForKey:selectedPlayer];
    
    [self showPlayerSelection:selectedPlayer];
    
    _selectedPlayer = selectedPlayer;
    _game.selectedPlayer = selectedPlayer;
    
    for (Card *c in selectedPlayer.manager.allCardsInHand) { // RESET CARDS
        c.AIShouldUse = true;
    }
    
    if (_selectedCard) {
        [self setSelectedCard:nil];
    }
    
    [self refreshUXWindowForPlayer:selectedPlayer withCompletionBlock:^{
        [_game AIChooseCardForPlayer:selectedPlayer];
    }];
    
    
}

-(void)setSelectedCard:(Card *)selectedCard {
    _selectedCard = selectedCard;
    _game.selectedCard = selectedCard;
}

-(void)AISelectedCard:(Card *)selectedCard {
    
    _selectedCard = selectedCard;
    _game.selectedCard = selectedCard;
    
    [_uxWindow setSelectedCard:selectedCard];
    
    [self showCardPath:[_selectedCard validatedSelectionSetForPlayer:_selectedPlayer]];
    
    [self runAction:[NKAction moveByX:0 y:0 duration:AI_SPEED] completion:^{
        [_game AIChooseLocationForCard:selectedCard];
    }];
    
}

-(void)setSelectedBoardTile:(BoardTile *)selectedBoardTile {
    
    
    if (_selectedCard) {
        _game.selectedLocation = selectedBoardTile.location;
    }
    
    _selectedBoardTile = selectedBoardTile;
    
}

-(void)AISelectedLocation:(BoardLocation*)selectedLocation {
    
    BoardTile *selectedBoardTile = [_gameTiles objectForKey:selectedLocation];
    
    if (_selectedCard) {
        _game.selectedLocation = selectedBoardTile.location;
    }
    
    _selectedBoardTile = selectedBoardTile;
    
}


#pragma mark - ANIMATIONS !!! AKA SOCCER_STAR_GALACTICA

-(void)animateEvent:(GameEvent*)event withCompletionBlock:(void (^)())block {
    
    float MOVE_SPEED = .35;
    
    PlayerSprite* player = [playerSprites objectForKey:event.playerPerforming];
    
    if (event.type == kEventStartTurn){
        
        if (_selectedPlayer) {
            [_gameBoardNode removeAllActions];
            PlayerSprite* p2 = [playerSprites objectForKey:_selectedPlayer];
            [_gameBoardNode runAction:[NKAction moveTo:P2Make(0, -p2.position.y + h/3.) duration:1.]];
        }
        P2t p = [self centerOfBoundingBox:[_game boundingBoxForLocationSet:[_game allPlayerLocations]]];
        if ((-p.y + h/4.) > _gameBoardNode.position.y+100 || (-p.y + h/4.) < _gameBoardNode.position.y-100) { // filter out subtle moves
            [_gameBoardNode removeAllActions];
            [_gameBoardNode runAction:[NKAction moveTo:P2Make(0, -p.y + h/4.) duration:1.]];
        }
        
        block();
        

    }
    
    else if (event.type == kEventSetBallLocation) {
        
        [_gameBoardNode fadeInChild:self.ballSprite duration:.3];
        //[self cameraShouldFollowSprite:Nil withCompletionBlock:^{}];
        
        if (_game.ball.enchantee) {
            
            [self animateMoveBallToPlayer:_game.ball.enchantee withCompletionBlock:^{
                block();
            }];
        }
        
        else {
            block();
        }
        
    }
    
    else if (event.type == kEventMove){
        [player runAction:[NKAction moveTo:[(NKNode*)[_gameTiles objectForKey:event.location] position] duration:MOVE_SPEED] completion:^(){
            
            if (event.playerPerforming.ball) {
                [player getReadyForPosession:^{
                    [self.ballSprite runAction:[NKAction move3dTo:[player.ballTarget positionInNode3d:_gameBoardNode] duration:BALL_SPEED] completion:^{
                        [player startPossession];
                        block();
                    }];
                }];
            }
            else {
                
                block();
            }
        }];
        
        [self playSoundWithKey:@"playerMove"];
        
        
    }
    
    else if (event.type == kEventChallenge) {
        
        PlayerSprite* receiver = [playerSprites objectForKey:event.playerReceiving];
        
        if (!event.playerReceiving) {
            NSLog(@"null receiver");
        }
        
        [player runAction:[NKAction moveTo:[(NKNode*)[_gameTiles objectForKey:event.location] position] duration:MOVE_SPEED] completion:^{
            
            if (event.wasSuccessful) {
                
                [self playSoundWithKey:@"challengeSuccessful"];
                [receiver stopPosession:^{
                    [receiver runAction:[NKAction moveTo:[(NKNode*)[_gameTiles objectForKey:event.startingLocation] position] duration:MOVE_SPEED]];
                    
                    [player getReadyForPosession:^{
                        [player startPossession];
                        block();
                    }];
                    
                }];
                
            }
            
            else {
                [self playSoundWithKey:@"challengeFail"];
                [player runAction:[NKAction moveTo:[(NKNode*)[_gameTiles objectForKey:event.startingLocation] position] duration:MOVE_SPEED] completion:^{
                    
                    block();
                }];
                
            }
            
        }];
        
    }
    
    else if (event.type == kEventKickPass || event.type == kEventKickGoal || event.type == kEventKickGoalLoss) {
        
        NKEmitterNode *enchant = [[NKEmitterNode alloc] init];
        
        [self.ballSprite addChild:enchant];
        [enchant setScale:.01];
        
        PlayerSprite* receiver = [playerSprites objectForKey:event.playerReceiving];
        
        float locScale = .5;
        if (event.type == kEventKickGoal || event.type == kEventKickGoalLoss) {
            locScale = 1.;
        }
        
        [enchant runAction:[NKAction scaleTo:2. * PARTICLE_SCALE * locScale duration:CAM_SPEED*.75] completion:^{
            
            [player stopPosession:^{
                
                // SUCCESSFUL PASS
                if ((event.type == kEventKickPass && event.wasSuccessful)) {
                    
                    [self playSoundWithKey:@"playerPass"];
                    
                    if (receiver) {
                        [receiver getReadyForPosession:^{
                            NKAction *move = [NKAction move3dTo:[receiver.ballTarget positionInNode3d:_gameBoardNode] duration:BALL_SPEED];
                            [move setTimingMode:NKActionTimingEaseOut];
                            
                            [self.ballSprite runAction:move completion:^(){
                                [receiver startPossession];
                                [enchant runAction:[NKAction scaleTo:.01 duration:CARD_ANIM_DUR*2] completion:^{
                                    [enchant removeFromParent];
                                    block();
                                }];
                            }];
                            
                        }];
                        
                    }
                    else { // pass to board square
                        
                        P2t dest = [(NKNode*)[_gameTiles objectForKey:_game.ball.location] position];
                        
                        
                        NKAction *move = [NKAction moveTo:dest duration:BALL_SPEED];
                        
                        [move setTimingMode:NKActionTimingEaseOut];
                        
                        [self.ballSprite runAction:move completion:^(){
                            
                            [self.ballSprite runAction:[NKAction scaleTo:BALL_SCALE_SMALL duration:CARD_ANIM_DUR]];
                            
                            block();
                            
                        }];
                    }
                }
                
                // SUCCESSFUL GOAL
                else if ((event.type == kEventKickGoalLoss || event.type == kEventKickGoal) && event.wasSuccessful) {
                    
                    [self playSoundWithKey:@"playerShoot"];
                    
                    P2t dest = [(NKNode*)[_gameTiles objectForKey:event.location] position];
                    NKAction *move = [NKAction moveTo:dest duration:.3];
                    [move setTimingMode:NKActionTimingEaseOut];
                    
                    
                    /*
                    [self.ballSprite runAction:move completion:^(){
                        NSLog(@"GameScene.m : animateEvent : GOAL");
                        [self animateBigText:@"GOAL !!!" withCompletionBlock:^{
                            block();
                            [self runAction:[NKAction fadeAlphaTo:0 duration:2.5] completion:^{
                                [_game endGame];
                                [self.nkView setScene:[[RecapMenu alloc] initWithSize:self.size]];
                            }];
                        }];
                     }];
                     */
                    if(event.type == kEventKickGoal){
                        [self.ballSprite runAction:move completion:^(){
                            NSLog(@"GameScene.m : animateEvent : GOAL");
                            NKTexture *image = [NKTexture textureWithImageNamed:[NSString stringWithFormat:@"GOAL_text.png"]];
                            NKSpriteNode* goal = [[NKSpriteNode alloc] initWithTexture:image];
                            [self addChild:goal];
                            
                            [self playSoundWithKey:@"goal"];
                            
                            
                            [self runAction:[NKAction fadeAlphaTo:0 duration:2.5] completion:^{
                                [_game endGame];
                                RecapMenuWin *recapMenu = [[RecapMenuWin alloc] init];
                                [self.nkView setScene:[recapMenu initWithSize:self.size]];
                            }];
                        }];
                    }
                    else if(event.type == kEventKickGoalLoss){
                        [self.ballSprite runAction:move completion:^(){
                            NSLog(@"GameScene.m : animateEvent : GOAL");
                            NKTexture *image = [NKTexture textureWithImageNamed:[NSString stringWithFormat:@"GOAL_text.png"]];
                            NKSpriteNode* goal = [[NKSpriteNode alloc] initWithTexture:image];
                            [self addChild:goal];
                            
                            [self playSoundWithKey:@"goal"];
                            
                            
                            [self runAction:[NKAction fadeAlphaTo:0 duration:2.5] completion:^{
                                [_game endGame];
                                RecapMenuLoss *recapMenu = [[RecapMenuLoss alloc] init];
                                [self.nkView setScene:[recapMenu initWithSize:self.size]];
                            }];
                        }];
                    }
                }
                
                else { // FAILED PASS OR FAILED GOAL
                    P2t dest = [(NKNode*)[_gameTiles objectForKey:_game.ball.location] position];
                    
                    NKAction *move = [NKAction moveTo:dest duration:BALL_SPEED];
                    
                    [move setTimingMode:NKActionTimingEaseOut];
                    
                    [self.ballSprite runAction:move completion:^(){
                        
                        [self.ballSprite runAction:[NKAction scaleTo:BALL_SCALE_SMALL duration:CARD_ANIM_DUR]];
                        
                        block();
                        
                    }];
                }
            }];
        }];
    }
    
    
    else if (event.type == kEventResetPlayers) {
        
        for (PlayerSprite *ps in playerSprites.allValues) {
            [ps runAction:[NKAction moveTo:[(NKNode*)[_gameTiles objectForKey:ps.model.location] position] duration:1.]];
        }
        [self animateMoveBallToPlayer:_game.ball.enchantee withCompletionBlock:^{
            block();
        }];
        
    }
    
    else if (event.type == kEventPlayCard){
        
        if (event.card) {
            
            CardSprite* card = [_uxWindow spriteForCard:event.card];
            
            if (card) {
                
                [card removeAllActions];
                
                V3t dest = [[_gameTiles objectForKey:event.location] getGlobalPosition];
                
                NKAction *grow = [NKAction group:@[
                                                   [NKAction move3dTo:V3Make(dest.x, dest.y - _uxWindow.position.y, 0) duration:FAST_ANIM_DUR],
                                                   [NKAction scaleTo:1.5 duration:FAST_ANIM_DUR]]];
                
                [card runAction:grow completion:^{
                    
                    [self playSoundWithKey:@"cardPlay"];
                    
                    [card runAction:[NKAction delayFor:FAST_ANIM_DUR] completion:^{
                        
                        NKAction *fall = [NKAction group:@[
                                                           [NKAction move3dTo:V3Make(dest.x, dest.y - _uxWindow.position.y, dest.z) duration:FAST_ANIM_DUR],
                                                           [NKAction rotate3dByAngle:V3Make(-26, 0, 0) duration:FAST_ANIM_DUR],
                                                           [NKAction scaleTo:1. duration:FAST_ANIM_DUR],
                                                           ]];

                        [card runAction:fall completion:^{
                            [card removeAllActions];
                            [card runAction:[NKAction fadeAlphaTo:0. duration:FAST_ANIM_DUR]completion:^{
                                [card removeFromParent];
                                block();
                            }];
                        }];
                        
                    }];
                    
                }];
            }
            
            else { // WERE USING AN AI CARD WITH NO GRAPHICS
                block();
            }
            
        }
        else {
            NSLog(@"ERROR *** play card event with no Card !!!");
            block();
        }
        
        
        
    }
    
    else if (event.type == kEventAddPlayer){
        [self addPlayerToBoardScene:event.playerPerforming animated:true withCompletionBlock:^{
            block();
        }];
    }
    
    else if (event.type == kEventRemovePlayer) {
        
        // [self cameraShouldFollowSprite:nil withCompletionBlock:^{   }];
        
        
        NSLog(@"GameScene.m : animateEvent : remove player");
        
        
        PlayerSprite* p = [playerSprites objectForKey:event.playerPerforming];
        
        [self removePlayerFromBoard:p animated:YES withCompletionBlock:^{
            block();
            
        }];
        
        
        
    }
    
    else if (event.type == kEventAddSpecial) {
        
        NSLog(@"GameScene.m : animateEvent : enchant");
        // MY PLAYER
        
        NKEmitterNode *enchant = [[NKEmitterNode alloc] init];
        //        NKEmitterNode *enchant = [NNKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"Install" ofType:@"sks"]];
        //
        //        NKKeyframeSequence *seq = [[NKKeyframeSequence alloc] initWithKeyframeValues:@[[NKColor blackColor], event.manager.color] times:@[@0,@.2]];
        //        enchant.particleColorSequence = seq;
        
        [enchant setScale:2];
        [_gameBoardNode addChild:enchant];
        [enchant setPosition:[(NKNode*)[_gameTiles objectForKey:event.location] position]];
        [enchant runAction:[NKAction fadeAlphaTo:.9 duration:CARD_ANIM_DUR] completion:^{
            
            [enchant runAction:[NKAction fadeAlphaTo:0. duration:CARD_ANIM_DUR] completion:^{
                [enchant removeFromParent];
                block();
            }];
        }];
        
        
        
        
    }
    
    else if (event.type == kEventStartTurnDraw) {
        
        [_uxWindow refreshCardsForManager:event.manager WithCompletionBlock:^{
            block();
        }];
        
    }
    
    else if (event.type == kEventDraw) {
        
        block();
        
    }
    
    else if (event.type == kEventShuffleDeck) {
        NSLog(@"GameScene.m : animateEvent : shuffle");
        block();
    }
    
    else if (event.type == kEventRemoveSpecial) {
        
        
        NSSet *enchantments = [_game temporaryEnchantments];
        
        if (enchantments.count) {
            
            NSLog(@"GameScene purging enchantments");
            
            for (Card *c in enchantments) {
                
                PlayerSprite *p = [playerSprites objectForKey:c.enchantee];
                
                NKEmitterNode *glow = [self ballGlowWithColor:[NKColor colorWithRed:.6 green:1. blue:.6 alpha:.5]];
                
                [p addChild:glow];
                
                [glow runAction:[NKAction scaleTo:2.*PARTICLE_SCALE duration:CARD_ANIM_DUR*2] completion:^{
                    [glow removeFromParent];
                }];
                
                [glow runAction:[NKAction fadeAlphaTo:0. duration:CARD_ANIM_DUR*2]];
                
            }
            
        }
        
        block();
        
        
    }
    
    else if (event.type == kEventKickoff){
        [self playSoundWithKey:@"kickoff"];
        block();
       // [self animateBigText:@"KICK OFF" withCompletionBlock:^{
        //    [self animateBigText:@"GAME ON" withCompletionBlock:^{
       //        block();
        //    }];
       // }];
        
    }
    else if (event.type == kEventEndTurn){
        [_uxWindow removeCardsAnimated:true WithCompletionBlock:^{
            block();
        }];
    }
    
    else {
        block();
    }
    
    
}

-(NKEmitterNode*)ballGlowWithColor:(NKColor*)color {
    
    NKEmitterNode *enchant = [[NKEmitterNode alloc] init];
    
    //    NKEmitterNode *enchant = [NNKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"Install" ofType:@"sks"]];
    //    NKKeyframeSequence *seq = [[NKKeyframeSequence alloc] initWithKeyframeValues:@[[NKColor blackColor], color] times:@[@0,@.2]];
    //    enchant.particleColorSequence = seq;
    //
    //    [enchant setZPosition:Z_INDEX_FX];
    //    [enchant setScale:.01];
    
    return enchant;
    
};

//-(void)animatePosessionFor:(Card*)card withCompletionBlock:(void (^)())block {
//
//    if (card.ball) {
//        PlayerSprite* player = [playerSprites objectForKey:card];
//
//        [player showBall];
//
//    }
//
//}

-(void)touchedScoreBoard {
    NSLog(@"touched score board");
    [_game showMetaData];
}

-(void)animateBigText:(NSString*)theText withCompletionBlock:(void (^)())block {
    
    NKLabelNode *bigText = [[NKLabelNode alloc]initWithSize:S2Make(300, 60) FontNamed:@"Coe"];
    bigText.fontSize = 40;
    bigText.fontColor = NKWHITE;
    [bigText setZPosition:400];
    
    [bigText loadAsyncText:theText completion:^{
        
        /*
        //[bigText setScale:1.5];
        float alpha = 1;
        for (int i = 0; i<6; i++) {
            NKLabelNode *bigText2 = [[NKLabelNode alloc]initWithSize:S2Make(300, 60) FontNamed:@"Arial-BoldMT"];
            bigText2.fontSize = 40;
            bigText2.fontColor = NKWHITE;
            bigText2.text = theText;
            bigText2.alpha = alpha/2;
            alpha = bigText2.alpha;
            [bigText2 setOrientationEuler:V3Make(0,0,15*i)];
            
            [bigText addChild:bigText2];
            
            // [bigText2 setScale:2.];
        }
         
        float animateDuration = 1.1;
        [self fadeInChild:bigText duration:.1 withCompletion:^{
            [bigText runAction:[NKAction group: @[[NKAction rotateByAngle:-90 duration:animateDuration],[NKAction scaleBy:10 duration:animateDuration],[NKAction fadeAlphaTo:0. duration:animateDuration]]] completion:^{
                [self fadeOutChild:bigText duration:.05 withCompletion:^{
                    block();
                }];
            }];
        }];
         */
        /*
        float animateDuration = 2;
        [self fadeInChild:bigText duration:.1 withCompletion:^{
            [bigText runAction:[NKAction group: @[[NKAction scaleBy:2 duration:animateDuration],[NKAction fadeAlphaTo:0. duration:animateDuration]]] completion:^{
                [self fadeOutChild:bigText duration:.05 withCompletion:^{
                    block();
                }];
            }];
        }];
         */
        [self fadeInChild:bigText duration:.25 withCompletion:^{
            [bigText runAction:[NKAction delayFor:2.5] completion:^{
                [self fadeOutChild:bigText duration:.25 withCompletion:^{
                    block();
                }];
            }];
        }];
    }];
}


-(void)refreshUXWindowForPlayer:(Player*)p withCompletionBlock:(void (^)())block {
    
    
    NSLog(@"refresh UX window");
    
    _uxWindow.selectedPlayer = p;
    
    if (p) {
        
        if (!_uxWindow.alpha) {
            [_uxWindow runAction:[NKAction fadeAlphaTo:1. duration:.5]];
            [_uxTopBar runAction:[NKAction fadeAlphaTo:1. duration:.5]];
        }
        
        
        [_uxWindow refreshCardsForManager:p.manager WithCompletionBlock:^{
            block();
        }];
        
        
        [_uxTopBar setPlayer:p WithCompletionBlock:^{}];
        
    }
    
}



//-(void)AniamteRoll:(GameEvent*)event withCompletionBlock:(void (^)())block {
//    if (!event.wasSuccessful) {
//
//        float width = TILE_WIDTH*3;
//        float height = TILE_HEIGHT;
//
//        NKSpriteNode *rollNode = [[NKSpriteNode alloc]initWithColor:[NKColor colorWithRed:0. green:0. blue:0. alpha:1.] size:S2Make(width, height)];
//        [rollNode setAlpha:.7];
//
//        [self addChild:rollNode];
//        [rollNode setPosition:P2Make(self.size.width/2. - width/2., self.size.height/2. - height/2.)];
//        [rollNode setAnchorPoint:CGPointZero];
//
//        NKSpriteNode *difficulty = [[NKSpriteNode alloc]initWithColor:[NKColor colorWithRed:0. green:1. blue:0. alpha:.7] size:S2Make(width, height/2)];
//        NKSpriteNode *roll = [[NKSpriteNode alloc]initWithColor:[NKColor colorWithRed:1. green:0. blue:.2 alpha:.7] size:S2Make(width, height/2)];
//
//        [roll setAnchorPoint:CGPointZero];
//        [difficulty setAnchorPoint:CGPointZero];
//
//        [rollNode addChild:difficulty];
//        [rollNode addChild:roll];
//
//        [difficulty setPosition:P2Make(0, height/2.)];
//        [roll setPosition:P2Make(0, 0)];
//
//        [difficulty setSize:S2Make(10, height/2.)];
//        [roll setSize:S2Make(10, height/2.)];
//
//        [difficulty runAction:[NKAction resizeToWidth:(width*action.totalSucess) height:height/2 duration:.2]];
//        //[difficulty runAction:[NKAction moveTo:P2Make(-width*event.success/2., height/4.) duration:.5]];
//
//        [roll runAction:[NKAction resizeToWidth:(width*event.roll) height:height/2 duration:1.] completion:^{
//            //[roll runAction:[NKAction moveTo:P2Make((-width*event.roll)/2., -height/4.) duration:1.5] completion:^{
//
//            [roll removeFromParent];
//            [difficulty removeFromParent];
//
//            if (action.wasSuccessful) {
//                [rollNode setColor:[NKColor greenColor]];
//            }
//            else {
//                [rollNode setColor:[NKColor redColor]];
//            }
//            [rollNode runAction:[NKAction fadeAlphaTo:.5 duration:.5] completion:^{
//                [rollNode runAction:[NKAction fadeAlphaTo:0. duration:.5] completion:^{
//                    [rollNode removeFromParent];
//
//                }];
//                block();
//            }];
//        }];
//
//    }
//    else {
//        NSLog(@"GameScene.m : rollEvent : SUCCESS, NO ROLL");
//        block();
//    }
//}
-(void)animateMoveBallToPlayer:(Player *)player withCompletionBlock:(void (^)())block{
    PlayerSprite* ps = [playerSprites objectForKey:player];
    [ps getReadyForPosession:^{
        [self.ballSprite runAction:[NKAction move3dTo:[ps.ballTarget positionInNode3d:_gameBoardNode] duration:BALL_SPEED]  completion:^{
            //[_ballSprite removeAllActions];
            block();
            [ps startPossession];
            //NSLog(@"ball actions : %d", [self.ballSprite hasActions]);
        }];
    }];
}

-(void)addPlayerToBoardScene:(Player *)player animated:(BOOL)animated withCompletionBlock:(void (^)())block{
    
    PlayerSprite *person = [[PlayerSprite alloc] initWithTexture: Nil color:nil size:S2Make(TILE_WIDTH, TILE_WIDTH * (67./65.))];
    
    person.delegate = self;
    
    [person setModel:player];
    
    [playerSprites setObject:person forKey:person.model];
    
    BoardTile* tile = [_gameTiles objectForKey:player.location];
    
    [[_gameBoardNode childNodeWithName:@"playerLayer" ] addChild:person];
    
    person.userInteractionEnabled = true;
    
    //[person setZPosition:Z_BOARD_PLAYER];
    
    if (!animated){
        
        [person setPosition:tile.position];
        
        block();
    }
    
    else {
        
        [self playSoundWithKey:@"playerDeploy"];
        
        int newY = tile.position.y + TILE_HEIGHT*10;
        if (!_game.me.teamSide) {
            newY = tile.position.y - TILE_HEIGHT*10;
        }
        
        [person setPosition3d:V3Make(tile.position.x, newY, 200)];
        [person setXScale:.33];
        
        
        V3t target = tile.position3d;
        target.z += 2;
        
        [person runAction:[NKAction move3dTo:target duration:.4] completion:^{
            
            NKEmitterNode *enchant = [[NKEmitterNode alloc]init];
            //            NKEmitterNode *enchant = [NNKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"Enchant" ofType:@"sks"]];
            //            NKKeyframeSequence *seq = [[NKKeyframeSequence alloc] initWithKeyframeValues:@[[NKColor blackColor], card.manager.color] times:@[@0,@.2]];
            //            enchant.particleColorSequence = seq;
            
            [person addChild:enchant];
            
            [enchant setScale:PARTICLE_SCALE];
            
            [enchant runAction:[NKAction fadeAlphaTo:0.01 duration:CARD_ANIM_DUR*2] completion:^{
                [enchant removeFromParent];
            }];
            
            block();
            
            [person runAction:[NKAction scaleXTo:1. duration:.3] completion:^{
            }];
            
            
            
        }];
        
        
        
        
        
    }
    
    
    
    
}

-(void)removePlayerFromBoard:(PlayerSprite *)person animated:(BOOL)animated withCompletionBlock:(void (^)())block {
    
    if (person) {
        
        [playerSprites removeObjectForKey:person.model];
        
        if (animated) {
            
            [person runAction:[NKAction scaleYTo:.2 duration:.2] completion:^{
                
                block();
                
                int newX = person.position.x - TILE_WIDTH*5;
                if (!_game.me.teamSide) {
                    newX = person.position.x + TILE_WIDTH*5;
                }
                
                [person runAction:[NKAction moveTo:P2Make(newX, person.position.y) duration:.4] completion:^{
                    
                    [person removeFromParent];
                    
                }];
                
            }];
            
            
        }
        
        else {
            
            [person removeFromParent];
            block();
        }
        
    }
    
    else {
        NSLog(@"### ERROR ### removing Nil Player Sprite");
        block();
    }
    
}

-(void)addCardToHand:(Card *)card {
    //[_uxWindow addCard:card];
}

-(void)removeCardFromHand:(Card *)card {
    // [_uxWindow removeCard:card];
}

-(BallSprite*)ballSprite {
    if (!_ballSprite) {
        //        _ballSprite = [[BallSprite alloc]init];
        //        _ballSprite.texture = [NKTexture textureWithImageNamed:@"ball_Texture.png"];
        _ballSprite = [[BallSprite alloc]initWithPrimitive:NKPrimitiveSphere texture:[NKTexture textureWithImageNamed:@"ball_Texture.png"] color:nil size:V3Make(50,50,50)];
    }
    if (!_ballSprite.parent) {
        [_gameBoardNode addChild:_ballSprite];
    }
    return _ballSprite;
}

-(void)moveBallToLocation:(BoardLocation *)location {
    
    [_ballSprite setScale:BALL_SCALE_BIG];
    [_ballSprite setPosition:[(NKNode*)[_gameTiles objectForKey:location] position]];
    _game.ball.location = location;
    
    NSLog(@"GameScene.m :: moving ball to: %d %d", location.x, location.y);
}

-(void)fadeOutHUD {
    
}

#pragma mark - SOUND

-(void)playMusicWithKey:(NSString*)key {
    [NKSoundManager playMusicNamed:[_soundFiles objectForKey:key]];
    if ([_soundVolumes objectForKey:key]) {
        [NKSoundManager setVolume:[[_soundVolumes objectForKey:key]floatValue] forSoundNamed:[_soundFiles objectForKey:key]];
    }
}

-(void)playSoundWithKey:(NSString*)key {
    [NKSoundManager playSoundNamed:[_soundFiles objectForKey:key]];
    if ([_soundVolumes objectForKey:key]) {
        [NKSoundManager setVolume:[[_soundVolumes objectForKey:key]floatValue] forSoundNamed:[_soundFiles objectForKey:key]];
    }
}

#pragma mark - POSITION FUNCTIONS

-(P2t)centerOfBoundingBox:(NSArray*)boundingBoxLocations {
    
    BoardTile *ll = [_gameTiles objectForKey:boundingBoxLocations[0]];
    BoardTile *ur = [_gameTiles objectForKey:boundingBoxLocations[1]];
    
    P2t llpos = [ll position];
    P2t urpos = [ur position];
    
    return P2Make((llpos.x + urpos.x) / 2., (llpos.y + urpos.y)/2.);
    
}

//-(void)cameraShouldFollowSprite:(NKSpriteNode*)sprite withCompletionBlock:(void (^)())block {
//    if (MOVE_CAMERA) {
//
//        if (!sprite) {
//
//            _followNode = Nil;
//            [_gameBoardNode removeAllActions];
//
//            if (_gameBoardNode.position.x != [self camPosNormal].x) {
//
//                //[_gameBoardNode runAction:[NKAction scaleTo:1. duration:1.]];
//                NKAction *move = [NKAction moveTo:[self camPosNormal] duration:.5];
//                // boardScale = 1.;
//                [move setTimingMode:NKActionTimingEaseOut];
//                [_gameBoardNode runAction:move completion:^{
//                    block();
//                }];
//
//            }
//
//            else {
//                block();
//            }
//
//        }
//        else {
//            [_gameBoardNode removeAllActions];
//            NKAction *move = [NKAction moveTo:[self boardPosForSprite:sprite] duration:.5];
//            [move setTimingMode:NKActionTimingEaseOut];
//            [_gameBoardNode runAction:move completion:^{
//                _followNode = sprite;
//                block();
//            }];
//        }
//
//    }
//
//    else {
//
//        [_gameBoardNode runAction:[NKAction scaleTo:1. duration:.05]];
//        NKAction *move = [NKAction moveTo:[self camPosNormal] duration:.5];
//        [move setTimingMode:NKActionTimingEaseIn];
//        [_gameBoardNode runAction:move completion:^{
//            block();
//        }];
//
//    }
//}
//
//-(void)zoomTowards:(NKSpriteNode*)sprite withCompletionBlock:(void (^)())block {
//
//    [_gameBoardNode removeAllActions];
//
//    [_gameBoardNode runAction:[NKAction scaleTo:1.2 duration:.5]];
//    boardScale = 1.2;
//    NKAction *move = [NKAction moveTo:[self boardPosForSprite:sprite] duration:.5];
//    [move setTimingMode:NKActionTimingEaseIn];
//
//    [_gameBoardNode runAction:move completion:^{
//
//    }];
//
//    block();
//
//}
//
//
//-(void)dollyTowards:(NKSpriteNode*)sprite duration:(float)duration{
//
//    [_gameBoardNode removeAllActions];
//
//
//    NKAction *move = [NKAction moveTo:[self camPosHalfTrack:sprite] duration:duration];
//
//    [move setTimingMode:NKActionTimingEaseOut];
//
//
//    [_gameBoardNode runAction:move completion:^{
//    }];
//
//
//}




#pragma mark - CALLED FROM GAME ENGINE
//
//-(void)enableSkip {
//    [_uxWindow setActionButtonTo:@"skip"];
//}

-(void)setMyTurn:(BOOL)myTurn {
    if (_gameBoardNode) { // only if we're living
        
        
        if (myTurn) {
            
            //            if (_game.canDraw) {
            //                [_uxWindow setActionButtonTo:@"draw"];
            //            }
            //            else {
            //                [_uxWindow setActionButtonTo:@"end"];
            //            }
            //
            
        }
        else {
            // [_uxWindow setActionButtonTo:nil];
        }
        
        
        
    }
}

-(void)rtIsActive:(BOOL)active {
    
    //    if (!_RTsprite) {
    //        _RTsprite = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"triangle_white"] color:_game.opponent.color size:S2Make(TILE_SIZE/4., TILE_SIZE/4)];
    //        _RTsprite.colorBlendFactor = 1.;
    //        [_RTsprite setZRotation:M_PI];
    //        [_RTsprite setZPosition:Z_INDEX_BOARD];
    //        [_RTsprite setPosition:P2Make(self.size.width - TILE_SIZE/6., self.size.height - TILE_SIZE/6.)];
    //    }
    //    if (active) {
    //        [self fadeInChild:_RTsprite];
    //    }
    //
    //    else {
    //        [self fadeOutChild:_RTsprite];
    //    }
    
}

-(void)receiveRTPacket {
    
    
    NKSpriteNode *led = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"spark"] color:nil size:S2Make(TILE_WIDTH/2., TILE_WIDTH/2.)];
    [self addChild:led];
    [led setPosition:_RTSprite.position];
    //[led setPosition:P2Make(_gameDelegate.size.width - led.size.width*.5,_gameDelegate.size.height-led.size.height*.5)];
    [led runAction:[NKAction fadeAlphaTo:0. duration:.5] completion:^{
        [led removeFromParent];
    }];
    
}

-(void)setWaiting:(BOOL)waiting {
    
    //    if (!waiting) {
    //        [self removeSepia];
    //    }
    //
    //    else {
    //        [self applySepia];
    //    }
    
}

-(void)endTurn:(NKNode*)sender {
    
    if ([_game shouldEndTurn]) {
        
        
        
        [_game playTouchSound];
    }
    
}

-(void)cleanupGameBoard {
    for (NKSpriteNode *s in playerSprites.allValues)
        [s removeFromParent];
    playerSprites = [NSMutableDictionary dictionaryWithCapacity:(BOARD_LENGTH * BOARD_WIDTH)];
    
    //[_uxWindow cleanup];
}

-(void)refreshScoreBoard {
    
}



#pragma mark - UPDATE CYCLE

-(void)updateWithTimeSinceLast:(F1t)dt {
    [super updateWithTimeSinceLast:dt];
}

//-(NKTouchState)touchUp:(P2t)location id:(int)touchId {
//
//    if ([super touchUp:location id:touchId] == NKTouchIsFirstResponder) {
//        if (!_miniGameNode) {
//            [self startMiniGame];
//        }
//        return NKTouchIsFirstResponder;
//    };
//
//    return NKTouchNone;
//
//}

@end
