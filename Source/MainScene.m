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
#import "Ship.h"

@implementation MainScene{
    CCPhysicsNode *_physicsNode;
    CCLabelTTF *_scoreLabelTemp;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_highscoreLabel;
    CCLabelTTF *_deadLabel;
    CCNode *_safety;
    CGSize _winSize;
    CMMotionManager *_motion;
    NSMutableArray *_spawnedAstroids;
    NSMutableArray *_spawnedStranded;
    NSMutableArray *_spawnedComets;
    NSMutableArray *_attachedStranded;
    NSMutableArray *_shipSpace;
    NSInteger _score;
    NSInteger _highscore;
    NSInteger _dead;
    UISwipeGestureRecognizer *_rightRecognizer;
    CGPoint _initialTouch;
    CGPoint _lastTouch;
    int _pointsTemp;
    int _points;
    int _deadPoints;
    float _astroidTime;
    float _cometTime;
}
static const int numberOfAstroids = 15;
static const int numberOfStranded = 15;
static const int spotsInShip = 5;
//static const int numberOfAttachedStranded = 10;

- (void)didLoadFromCCB {
    _winSize = [CCDirector sharedDirector].viewSize;
    _physicsNode.debugDraw = YES;
    _physicsNode.collisionDelegate = self;
    //[self addBoundingBox];
    _points = 0;
    _deadPoints = 0;
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
        _shipSpace = [NSMutableArray array];
        //_rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:ship action:@selector(detectSwipe)];
        //_rightRecognizer.numberOfTouchesRequired = 1;
        //_rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        
    }
    return self;
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    _initialTouch = touch.locationInWorld;
    if (_ship.physicsBody.velocity.x == 0) {
        [self addShield];
    }
}

- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    
    _lastTouch = touch.locationInWorld;
    //minimum touch length
    float touchLen = ccpDistance(_initialTouch, _lastTouch);

    //check to see if swipe is to right
    if (_initialTouch.x < _lastTouch.x && touchLen > 125) {
        if (_pointsTemp == 5) {
            [_ship sendShip];
        }
    }
    [shield removeFromParent];
}

- (void)astroidLoop {
    //spawn astroids
    for (int i = 0; i < 3; i++) {
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
    //newPosition = ccp(clampf(newPosition.x, 0, _winSize.width),clampf(newPosition.y, 0, _winSize.height));
    
    //Wrap astronaut position
    if (astronaut.position.x < 0) {
        newPosition = ccp(_winSize.width,astronaut.position.y);
    }
    else if (astronaut.position.x > _winSize.width) {
        newPosition = ccp(0, astronaut.position.y);
    }
    else if (astronaut.position.y < 0) {
        newPosition = ccp(astronaut.position.x, _winSize.height);
    }
    else if (astronaut.position.y > _winSize.height) {
        newPosition = ccp(astronaut.position.x, 0);
    }
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
    
    _scoreLabel.string = [NSString stringWithFormat:@"%d", (int)_points];
    _highscoreLabel.string = [NSString stringWithFormat:@"%d", (int)_points];
}

-(void)onEnter
{
    [super onEnter];
    [self addAstronaut];
    [self astroidLoop];
    [self strandedLoop];
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
    if (!astroid.hasBeenOnScreen) {
        return FALSE;
    } else {
    [_ship removeFromParent];
    [self gameOver];
    return TRUE;
    }
}

//astroid - stranded
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair astroid:(CCNode *)nodeA stranded:(CCNode *)nodeB {
    return FALSE;
}

//stranded - ship
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair stranded:(CCNode *)nodeA ship:(CCNode *)nodeB {
    return FALSE;
}

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

//comet - ship
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair comet:(CCNode *)nodeA ship:(CCNode *)nodeB{
    [nodeB removeFromParent];
    [self gameOver];
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
    if (_shipSpace.count < spotsInShip) {
        NSUInteger saved = _attachedStranded.count;
        _pointsTemp += saved;
        for (int i = 0; i < saved; i++) {
            [_shipSpace addObject:stranded];
        }
        _scoreLabelTemp.string = [NSString stringWithFormat:@"%d", _pointsTemp];
        for (CCNode* node in _attachedStranded) {
            [node removeFromParent];
        }
        [_attachedStranded removeAllObjects];
        [_spawnedStranded removeAllObjects];
    }
    return FALSE;
}

//ship - shield
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ship:(CCNode *)nodeA shield:(CCNode *)nodeB {
    return FALSE;
}

//ship - safety
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ship:(CCNode *)nodeA safety:(CCNode *)nodeB {
    _points += 5;
    _scoreLabel.string = [NSString stringWithFormat:@"%d", _points];
    [_ship removeFromParent];
    _pointsTemp = 0;
    _scoreLabelTemp.string = [NSString stringWithFormat:@"%d", _pointsTemp];
    return TRUE;
}

//astroid - safety
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair astroid:(CCNode *)nodeA safety:(CCNode *)nodeB {
    return FALSE;
}

//stranded - safety
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair stranded:(CCNode *)nodeA safety:(CCNode *)nodeB {
    return FALSE;
}
//comet - safety
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair comet:(CCNode *)nodeA safety:(CCNode *)nodeB {
    return FALSE;
}

- (void)gameOver {
    [self saveScore];
    [self saveDeadScore];
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

- (void)addShip {
    _ship = (Ship*) [CCBReader load:@"Ship"];
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
            if (astroid.position.x < -10 || astroid.position.x > winSize.width + 10 || astroid.position.y < -10 || astroid.position.y > winSize.height + 10) {
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
            if (stranded.position.x < -20 || stranded.position.x > winSize.width + 20 || stranded.position.y < -20 || stranded.position.y > winSize.height + 20) {
                //remove from array
                [_spawnedStranded removeObject:stranded];
                //removes from scene
                [stranded removeFromParent];
                [_spawnedStranded removeAllObjects];
                //Point to dead stranded
                _deadPoints++;
                _deadLabel.string = [NSString stringWithFormat:@"%ld", (long)_dead];
            }else{
                i++;
            }
        }
    }
}

- (void)saveScore {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:_points forKey:@"score"];
    [prefs synchronize];
}

//Save the number of stranded missed
- (void)saveDeadScore {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:_deadPoints forKey:@"dead"];
    [prefs synchronize];
}
@end
