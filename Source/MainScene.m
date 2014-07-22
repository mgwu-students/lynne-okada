//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import <CoreMotion/CoreMotion.h>
#import "CCPhysics+ObjectiveChipmunk.h"
#import "Score.h"
#import "Astroid.h"
#import "Astronaut.h"
#import "StrandedAstronaut.h"
#import "CCActionMoveToNode.h"
#import "Shield.h"
#import "Comet.h"

@implementation MainScene{
    CCPhysicsNode *_physicsNode;
    CCNode *_ship;
    CCLabelTTF *_score;
    CGSize _winSize;
    CMMotionManager *_motion;
    NSMutableArray *_spawnedAstroids;
    NSMutableArray *_spawnedStranded;
    NSMutableArray *_spawnedComets;
    NSMutableArray *_attachedStranded;
    int points;
    float _astroidTime;
    float _cometTime;
}
static const int numberOfAstroids = 15;
static const int numberOfStranded = 15;
//static const int numberOfAttachedStranded = 10;

- (void)didLoadFromCCB {
    _winSize = [CCDirector sharedDirector].viewSize;
    _physicsNode.debugDraw = YES;
    _physicsNode.collisionDelegate = self;
    //[self addBoundingBox];
    points = 0;
}

- (id)init {
    if (self = [super init])
    {
        // activate touches on this scene
        self.userInteractionEnabled = TRUE;
        _motion = [[CMMotionManager alloc] init];
        _spawnedAstroids = [NSMutableArray array];
        _spawnedStranded = [NSMutableArray array];
        _spawnedComets = [NSMutableArray array];
        _attachedStranded = [NSMutableArray array];
    }
    return self;
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    [self addShield];
}

- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    [shield removeFromParent];
}

//- (void)cometLoop {
//    //spawn a comet
//    for (int i = 0; i < 1; i++) {
//        [self addComet];
//    }
//}

- (void)astroidLoop {
    //spawn astroids
    for (int i = 0; i < 6; i++) {
        [self addAstroid];
        
    }
}

- (void)strandedLoop {
    //spawn stranded astronauts
    for (int i =0; i < 2; i++) {
        [self addStrandedAstronaut];
    }
}

//prevent astronaut from leaving screen
- (void)addBoundingBox {
    CGRect screenSize = CGRectMake(0,0,_winSize.width,_winSize.height);
    CCNode *boundary = [CCNode node];
    boundary.physicsBody = [CCPhysicsBody bodyWithPolylineFromRect:screenSize cornerRadius:0];
    [_physicsNode addChild:boundary];
}

-(void)update:(CCTime)delta
{
    //accelerometer
    CMAccelerometerData * accelerometerData= _motion.accelerometerData;
    CMAcceleration acceleration = accelerometerData.acceleration;
    //NSLog(@"acceleration-x: %f <> y:%f <> z:%f", acceleration.x, acceleration.y, acceleration.z);
    
    float spriteSpeed = 5.0f; //change this to change sprite speed
    UIAccelerationValue xa, ya;
    xa = acceleration.x;
    ya = acceleration.y;
    float velocityVectorY = spriteSpeed*ya;  //tilting side-to-side when held horizontally
    float velocityVectorX = spriteSpeed*xa;
    
    //NSLog(@"clamped:%f preclamp:%f window: %f",velocityVectorY,spriteSpeed*ya, _winSize.height);
    CGPoint velocity = CGPointMake(velocityVectorY, -velocityVectorX);
    CGPoint newPosition = ccpAdd(astronaut.position, velocity);
    newPosition = ccp(clampf(newPosition.x, 0, _winSize.width),clampf(newPosition.y, 0, _winSize.height));
    astronaut.position = newPosition;
    
    //Spawns astroid and stranded every 5 seconds
    
    _astroidTime += delta;
    if (_astroidTime >= 5){
        //NSLog(@"count:%d",_spawnedAstroids.count);
        //check if array of objects is full
        if (_spawnedAstroids.count < numberOfAstroids) {
            [self astroidLoop];
        }
        if (_spawnedStranded.count < numberOfStranded) {
            [self strandedLoop];
        }
        _astroidTime = 0;
    }
    
    _cometTime += delta;
    int spawned = arc4random() % 500;
    if (_cometTime >= 2 && spawned == 0) {
        [self addComet];
        _cometTime = 0;
    }
    [self checkToRemoveAstroids];
    [self checkToRemoveStranded];
}

-(void)onEnter
{
    [super onEnter];
    [self addAstronaut];
    [self astroidLoop];
    [self strandedLoop];
    //[self cometLoop];
    [_motion startAccelerometerUpdates];
    
    //position astronaut to little above the ship(center of screen)
    float startX = [CCDirector sharedDirector].viewSize.width/2;
    float startY = [CCDirector sharedDirector].viewSize.height/2 + 20;
    astronaut.position = ccp(startX,startY);
}

-(void)onExit
{
    self.userInteractionEnabled = NO;
    [_motion stopAccelerometerUpdates];
    [super onExit];
}

//COLLISIONS
//astronaut - astroid
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair astronaut:(CCNode *)nodeA astroid:(CCNode *)nodeB {
    [nodeA removeFromParent];
    [self gameOver];
    return true;
}

//astronaut - comet
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair astronaut:(CCNode *)nodeA comet:(CCNode *)nodeB {
    [nodeA removeFromParent];
    [self gameOver];
    return TRUE;
}

//astroid - astroid
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair astroid:(CCNode *)nodeA astroid:(CCNode *)nodeB {
    return FALSE;
}

//astroid - ship
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair astroid:(CCNode *)nodeA ship:(CCNode *)nodeB {
    [_ship removeFromParent];
    [self gameOver];
    return TRUE;
}

//astroid - stranded
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair astroid:(CCNode *)nodeA stranded:(CCNode *)nodeB {
        return FALSE;
}

//stranded - ship
//- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair stranded:(CCNode *)nodeA ship:(CCNode *)nodeB {
//    
//}

//astronaut - shield
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair astronaut:(CCNode *)nodeA shield:(CCNode *)nodeB {
    return FALSE;
}

//stranded - shield
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair stranded:(CCNode *)nodeA shield:(CCNode *)nodeB {
    return FALSE;
}

//astroid - comet
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair astroid:(CCNode *)nodeA comet:(CCNode *)nodeB{
    return FALSE;
}

//comet - shield
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair comet:(CCNode *)nodeA shield:(CCNode *)nodeB {
    [nodeA removeFromParent];
    return TRUE;
}

//astronaut - stranded
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair astronaut:(CCNode *)nodeA stranded:(CCNode *)nodeB {
//    [CCPhysicsJoint connectedPivotJointWithBodyA:astronaut.physicsBody bodyB:stranded.physicsBody anchorA:astronaut.anchorPoint];
    [_attachedStranded addObject:nodeB];
    nodeA.physicsBody.collisionGroup = @"attached";
    nodeB.physicsBody.collisionGroup = @"attached";
    CCActionMoveToNode *moveTo = [CCActionMoveToNode actionWithSpeed:170.f positionUpdateBlock:^CGPoint{
        return nodeA.position;
    } followInfinite:YES];
    [nodeB runAction:moveTo];
    return TRUE;
}

//astronaut - ship
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair astronaut:(CCNode *)nodeA ship:(CCNode *)nodeB {
    NSUInteger saved = _attachedStranded.count;
    points += saved;
    _score.string = [NSString stringWithFormat:@"%d", points];
    for (CCNode* node in _attachedStranded) {
        [node removeFromParent];
    }
    [_attachedStranded removeAllObjects];
    return TRUE;
}

- (void)gameOver {
    CCScene *score = [CCBReader loadAsScene:@"Score"];
    CCTransition *transition = [CCTransition transitionCrossFadeWithDuration:0.8f];
    [[CCDirector sharedDirector] presentScene:score withTransition:transition];
}

- (void)addAstronaut {
    astronaut = (Astronaut*)[CCBReader load:@"Astronaut"];
    [_physicsNode addChild:astronaut];
}

- (void)addStrandedAstronaut {
    stranded = (StrandedAstronaut*)[CCBReader load:@"StrandedAstronaut"];
    [stranded setupRandomPosition];
    [stranded pushToRandomPoint];
    [_physicsNode addChild:stranded];
    [_spawnedStranded addObject:stranded];
}

- (void)addAstroid {
    astroid = (Astroid*)[CCBReader load:@"Astroid"];
    [astroid setupRandomPosition];
    [_physicsNode addChild:astroid];
    [_spawnedAstroids addObject:astroid];
    [astroid pushToRandomPoint];
}

- (void)addShield {
    shield = (Shield*) [CCBReader load:@"Shield"];
    [shield location];
    [_physicsNode addChild:shield];
}

- (void)addComet {
    comet = (Comet*) [CCBReader load:@"Comet"];
    [comet setupRandomPosition];
    [comet pushToCenter];
    [_physicsNode addChild:comet];
}
- (void)checkToRemoveAstroids {
    int i = 0;
    CGSize winSize = [CCDirector sharedDirector].viewSize;
    while (i < _spawnedAstroids.count) {
        //this is the future: check astroids that have not been on screen
        astroid = [_spawnedAstroids objectAtIndex:i];
        if (!astroid.hasBeenOnScreen) {
            if (astroid.position.x > 0 && astroid.position.x < winSize.width && astroid.position.y > 0 && astroid.position.y < winSize.height) {
                astroid.hasBeenOnScreen = YES;
            }
            i++;
        } else {
            if (astroid.position.x < 0 || astroid.position.x > winSize.width || astroid.position.y < 0 || astroid.position.y > winSize.height) {
                //remove from array
                [_spawnedAstroids removeObject:astroid];
                //removes from scene
                [astroid removeFromParent];
            }else{
                i++;
            }
        }
    }
}

- (void)checkToRemoveStranded {
    int i = 0;
    CGSize winSize = [CCDirector sharedDirector].viewSize;
    while (i < _spawnedStranded.count) {
        //this is the future: check astroids that have not been on screen
        stranded = [_spawnedStranded objectAtIndex:i];
        if (!stranded.hasBeenOnScreen) {
            if (stranded.position.x > 0 && stranded.position.x < winSize.width && stranded.position.y > 0 && stranded.position.y < winSize.height) {
                stranded.hasBeenOnScreen = YES;
            }
            i++;
        } else {
            if (stranded.position.x < 0 || stranded.position.x > winSize.width || stranded.position.y < 0 || stranded.position.y > winSize.height) {
                //remove from array
                [_spawnedStranded removeObject:stranded];
                //removes from scene
                [stranded removeFromParent];
            }else{
                i++;
            }
        }
    }
    
}
@end
