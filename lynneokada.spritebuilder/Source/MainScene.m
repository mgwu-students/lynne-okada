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
#import "ShieldMeter.h"
#import "Warning.h"
#import "HealthBar.h"
#import "Hit.h"

@implementation MainScene{
    CCPhysicsNode *_physicsNode;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_highscoreLabel;
    CCLabelTTF *_gameOverLabel;
    CCNode *_safety;
    //CCNode *_yellow;
    //CCNode *_red;
    CCProgressNode *_progressShield;
    CCProgressNode *_progressHealth;
    //CCLabelTTF *_deadLabel;
    //CCLabelTTF *_scoreLabelTemp;
    CGSize _winSize;
    CMMotionManager *_motion;
    NSMutableArray *_spawnedAstroids;
    NSMutableArray *_spawnedStranded;
    NSMutableArray *_spawnedComets;
    NSMutableArray *_attachedStranded;
    NSMutableArray *_soundEffects;
    //NSMutableArray *_shipSpace;
    NSInteger _score;
    //NSInteger _highscore;
    //NSInteger _dead;
    UISwipeGestureRecognizer *_rightRecognizer;
    CGPoint _initialTouch;
    CGPoint _lastTouch;
    //int _pointsTemp;
    int _points;
    //int _deadPoints;
    int _astroidNum;
    float _astroidTime;
    float _cometTime;
//    UIAccelerationValue _xa;
//    UIAccelerationValue _ya;
    float _calX;
    float _calY;
    BOOL _hasBeenCal;
    OALSimpleAudio *_incoming;
    BOOL _gameOver;
    float _gameOverDelay;
}

static const int numberOfAstroids = 15;
static const int numberOfStranded = 5;

//static const int spotsInShip = 5;
//static const int numberOfAttachedStranded = 10;

- (void)didLoadFromCCB {
    _winSize = [CCDirector sharedDirector].viewSize;
    //_physicsNode.debugDraw = YES;
    _physicsNode.collisionDelegate = self;
    _points = 0;
    _astroidNum = 3;
    _calX = 0;
    _calY = 0;
    _hasBeenCal = YES;
    //_deadPoints = 0;
    [self addShip];
    [self schedule:@selector(addAstronaut) interval:1.0f repeat:0 delay:3.0f];
    [self astroidLoop];
    [self strandedLoop];
    _activate = NO;
    
    _gameOverDelay = 0;
    
    //shield meter
    [self schedule:@selector(updateShield) interval:0.1f];
    
    //add an astroid for given interval
    [self schedule:@selector(increaseDiff) interval:10.0f];
    
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
        _soundEffects = [NSMutableArray array];
        //_shipSpace = [NSMutableArray array];
        //_rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:ship action:@selector(detectSwipe)];
        //_rightRecognizer.numberOfTouchesRequired = 1;
        //_rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    }
    return self;
}

- (void)updateShield {
    if (_ship.position.x == _winSize.width/2) {
        if (_progressShield.percentage < 100 && !_activate) {
            _progressShield.percentage += 2.0f;
        } else if (_progressShield.percentage > 0.0f && _activate) {
            _progressShield.percentage -= 10.0f;
        } else if (_progressShield.percentage <= 0.0f && _activate) {
            [shield removeFromParent];
        }
    }
}

- (void)updateHealth {
    if (_progressHealth.percentage > 0) {
        _progressHealth.percentage -= 30;
//            if (_progressHealth.percentage <= 50) {
//                _yellow = [CCBReader load:@"HealthBarYellow"];
//            }
//            if (_progressHealth.percentage <= 10) {
//                _red = [CCBReader load:@"HealthBarRed"];
    }
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    _initialTouch = touch.locationInWorld;
    _activate = YES;
    
    if (_ship.physicsBody.velocity.x == 0 &&_progressShield.percentage > 0.0f) {
        [self addShield];
    }
}

- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    _activate = NO;
    [shield removeFromParent];

    
    //_lastTouch = touch.locationInWorld;
    //minimum touch length
    //float touchLen = ccpDistance(_initialTouch, _lastTouch);
    
    //check to see if swipe is to right
//    if (_initialTouch.x < _lastTouch.x && touchLen > 125) {
//        if (_shipSpace.count == spotsInShip) {
//            _ship.brakeOff = NO;
//            [_ship sendShip];
//        }
//    }
    }
- (void)increaseDiff {
    _astroidNum++;
}

- (void)astroidLoop {
    //spawn astroids
    for (int i = 0; i < _astroidNum; i++) {
        [self addAstroid];
    }
}

- (void)strandedLoop {
    //spawn stranded astronauts
    for (int i = 0; i < 1; i++) {
        [self addStrandedAstronaut];
    }
}

-(void)update:(CCTime)delta {
    //accelerometer
    CMAccelerometerData * accelerometerData= _motion.accelerometerData;
    CMAcceleration acceleration = accelerometerData.acceleration;
    //NSLog(@"acceleration-x: %f <> y:%f", acceleration.x, acceleration.y);
//    if(!_hasBeenCal) {
//        _calX = acceleration.x;
//        _calY = acceleration.y;
//        _hasBeenCal = YES;
//    }
    
    float spriteSpeed = 5.0f; //change this to change sprite speed
    float xa, ya;
    
    
    xa = acceleration.x;
    ya = acceleration.y;
    NSLog(@"acceleration-x: %f <> y:%f", xa, ya);
    
    float velocityVectorY = spriteSpeed*ya;  //tilting side-to-side when held horizontally
    float velocityVectorX = spriteSpeed*xa;
    
    //NSLog(@"clamped:%f preclamp:%f window: %f",velocityVectorY,spriteSpeed*ya, _winSize.height);
    CGPoint velocity = CGPointMake(velocityVectorY, -velocityVectorX);
    CGPoint newPosition = ccpAdd(astronaut.position, velocity);
    //CGPoint newPositionStranded = ccpAdd(stranded.position, velocity);
    newPosition = ccp(clampf(newPosition.x, 0, _winSize.width),clampf(newPosition.y, 0, _winSize.height));
    
//    //Wrap astronaut position
//    if (astronaut.position.x < 0) {
//        newPosition = ccp(_winSize.width,astronaut.position.y);
//    }
//    else if (astronaut.position.x > _winSize.width) {
//        newPosition = ccp(0, astronaut.position.y);
//    }
//    else if (astronaut.position.y < 0) {
//        newPosition = ccp(astronaut.position.x, _winSize.height);
//    }
//    else if (astronaut.position.y > _winSize.height) {
//        newPosition = ccp(astronaut.position.x, 0);
//    }
    astronaut.position = newPosition;
    
    //wrap stranded position
    for (StrandedAstronaut* dude in _spawnedStranded) {
        if (dude.position.x < 0 - dude.contentSize.width/2) {
            dude.position = ccp(_winSize.width, dude.position.y);
        }
        else if (dude.position.x > _winSize.width + dude.contentSize.width/2) {
            dude.position = ccp(0, dude.position.y);
        }
        else if (dude.position.y < 0 - dude.contentSize.height/2) {
            dude.position = ccp(dude.position.x, _winSize.height);
        }
        else if (dude.position.y > _winSize.height + dude.contentSize.height/2) {
            dude.position = ccp(dude.position.x, 0);
        }
    }
    
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
        [self addWarning];
        [self schedule:@selector(addComet) interval:1.0f repeat:0 delay:0.8f];
        [self schedule:@selector(removeWarning) interval:1.0f];
        _cometTime = 0;
    }
    [self checkToRemoveAstroids];
    //[self checkToRemoveStranded];
    
    _scoreLabel.string = [NSString stringWithFormat:@"%d", (int)_points];
    _highscoreLabel.string = [NSString stringWithFormat:@"%d", (int)_points];
    
    
    if (_gameOver) {
        _gameOverDelay += delta;
        if (_gameOverDelay > 2) {
            [self gameOver];
            _gameOver = false;
        }
    }
    
    
    //destroy ship once no health
    if (_progressHealth.percentage <= 0) {
        //        _ship.brakeOff = NO;
        //        [_ship sendShip];
        [self shipRemoved:_ship];
        _gameOverLabel.visible = YES;
        _healthBar.visible = NO;
        _scoreLabel.visible = NO;
        _gameOver = true;
    }

    if (_progressHealth.percentage > 0 && _ship.position.x == _winSize.width/2) {
        _healthBar.visible = YES;
        _scoreLabel.visible = YES;
    }
}

-(void)onEnter
{
    [super onEnter];
    
    _scoreLabel.visible = FALSE;
    [_motion startAccelerometerUpdates];
    
    _hasBeenCal = NO;
    
    //health bar
    _healthBar = (HealthBar*) [CCBReader load:@"HealthBar"];
    _healthBar.visible = NO;
    _progressHealth = [CCProgressNode progressWithSprite:_healthBar];
    [_healthBar barLocation];
    [_physicsNode addChild:_healthBar];
    _progressHealth.type = CCProgressNodeTypeBar;
    //_progressHealth.barChangeRate = ccp(1.0f, 0.0f);
    _progressHealth.percentage = 100;
    _progressHealth.positionType = CCPositionTypeNormalized;
    _progressHealth.position = ccp(0.5f, 0.5f);
    [_healthBar addChild:_progressHealth];
    
    //shield meter
     _shieldMeter = (ShieldMeter*) [CCBReader load:@"ShieldMeter"];
    [_shieldMeter meterPosition];
    [_physicsNode addChild:_shieldMeter];
    _progressShield = [CCProgressNode progressWithSprite:_shieldMeter];
    
    _progressShield.type = CCProgressNodeTypeBar;
    //_progressNode.midpoint = ccp(0.0f, 0.0f);
    _progressShield.barChangeRate = ccp(1.0f, 0.0f);
    _progressShield.percentage = 100;
    _progressShield.positionType = CCPositionTypeNormalized;
    _progressShield.position = ccp(0.5f, 0.5f);
    [_shieldMeter addChild:_progressShield];
    
//    OALSimpleAudio* Yo =  [[OALSimpleAudio sharedInstance] playEffect:@"Art/Yo.wav"];
//    OALSimpleAudio* Sweet = [[OALSimpleAudio sharedInstance] playEffect:@"Art/Sweet.wav"];
//    OALSimpleAudio* Cool = [[OALSimpleAudio sharedInstance] playEffect:@"Art/Cool.wav"];
//    [_soundEffects addObject:Yo];
//    [_soundEffects addObject:Sweet];
//    [_soundEffects addObject:Cool];
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
    [[OALSimpleAudio sharedInstance] playEffect:@"Art/dead.wav"];
    [self astronautRemoved:nodeA];
    _gameOverLabel.visible = YES;
    [self schedule:@selector(gameOver) interval:1.0f repeat:0 delay:3.0f];
    return true;
}

//astronaut - comet
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair astronaut:(CCNode *)nodeA comet:(CCNode *)nodeB {
    [[OALSimpleAudio sharedInstance] playEffect:@"Art/dead.wav"];
    [self astronautRemoved:nodeA];
    _gameOverLabel.visible = YES;
    [self schedule:@selector(gameOver) interval:1.0f repeat:0 delay:3.0f];
    return TRUE;
}

//astroid - astroid
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair astroid:(CCNode *)nodeA astroid:(CCNode *)nodeB {
    return FALSE;
}

//astroid - ship
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair astroid:(CCNode *)nodeA ship:(Ship *)nodeB {
    //ship should not die from astroid before moving to center
    if (nodeB.position.x < _winSize.width/2 || nodeB.position.x > _winSize.width) {
        return FALSE;
    } else if (_ship.physicsBody.velocity.x == 0) {
        [self updateHealth];
        [[OALSimpleAudio sharedInstance] playEffect:@"Art/explosion.wav"];
        [self astroidRemoved:nodeA];
    }
    return NO;
}

//stranded - comet
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair comet:(CCNode *)nodeA stranded:(CCNode *)nodeB {
    return FALSE;
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
    [[OALSimpleAudio sharedInstance] playEffect:@"Art/shieldComet.wav"];
    [self cometRemovedShield:nodeA];
    return TRUE;
}

//astroid - shield
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair astroid:(CCNode *)nodeA shield:(CCNode *)nodeB {
    [[OALSimpleAudio sharedInstance] playEffect:@"Art/shieldAstroid.wav"];
    [self astroidRemovedShield:nodeA];
    return TRUE;
}

//comet - ship
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair comet:(CCNode *)nodeA ship:(Ship *)nodeB{
    //ship should not die from astroid before moving to center
    if (_ship.physicsBody.velocity.x > 0) {
        return FALSE;
    } else if (_ship.physicsBody.velocity.x == 0) {
        //[self addHit];
        nodeA.physicsBody.collisionGroup = @"destroyed";
        nodeB.physicsBody.collisionGroup = @"destroyed";
        [self updateHealth];
        [self cometRemovedShip:comet];
        [[OALSimpleAudio sharedInstance] playEffect:@"Art/explosion.wav"];
        [nodeA removeFromParent];
        //[self schedule:@selector(removeHit) interval:0.5f];
    }
    return NO;
}

//astronaut - stranded
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair astronaut:(CCNode *)nodeA stranded:(CCNode *)nodeB {
    [[OALSimpleAudio sharedInstance] playEffect:@"Art/Yo.wav"];
    [_attachedStranded addObject:nodeB];
    nodeA.physicsBody.collisionGroup = @"attached";
    nodeB.physicsBody.collisionGroup = @"attached";
    CCActionMoveToNode *moveTo = [CCActionMoveToNode actionWithSpeed:170.f positionUpdateBlock:^CGPoint{
        return nodeA.position;
    } followInfinite:YES];
    [nodeB runAction:moveTo];
    return YES;
}

//astronaut - ship
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair astronaut:(CCNode *)nodeA ship:(CCNode *)nodeB {
    _points += _attachedStranded.count;
    _scoreLabel.string = [NSString stringWithFormat:@"%d", _points];
    
    if (_attachedStranded.count > 0) {
        [[OALSimpleAudio sharedInstance] playEffect:@"Art/Thanks.wav"];
    }
    
    for (CCNode* node in _attachedStranded) {
        [node removeFromParent];
        
    }
    
    [_attachedStranded removeAllObjects];
    [_spawnedStranded removeAllObjects];
    return NO;
}

//ship - shield
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ship:(CCNode *)nodeA shield:(CCNode *)nodeB {
    return FALSE;
}

//ship - safety
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ship:(Ship *)nodeA safety:(CCNode *)nodeB {
    [self gameOver];
    return NO;
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
    //[self saveDeadScore];
    CCScene *score = [CCBReader loadAsScene:@"Score"];
    CCTransition *transition = [CCTransition transitionCrossFadeWithDuration:0.8f];
    [[CCDirector sharedDirector] presentScene:score withTransition:transition];
}

- (void)addAstronaut {
    astronaut = (Astronaut*)[CCBReader load:@"Astronaut"];
    [astronaut startPosition];
    [_physicsNode addChild:astronaut];
}

- (void)addStrandedAstronaut {
    _stranded = (StrandedAstronaut*)[CCBReader load:@"StrandedAstronaut"];
    [_stranded setupRandomPosition];
    [_stranded pushToRandomPoint];
    [_physicsNode addChild:_stranded];
    [_spawnedStranded addObject:_stranded];
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
    [[OALSimpleAudio sharedInstance] playEffect:@"Art/shield.wav"];
}

- (void)addWarning {
    _warning = (Warning*) [CCBReader load:@"Warning"];
    [[OALSimpleAudio sharedInstance] playEffect:@"Art/warning.wav"];
    [self addChild:_warning];
    _warning.position = ccp(_winSize.width/2,_winSize.height/2 + 20);
}

- (void)removeWarning {
    [_warning removeFromParent];
}

- (void)addComet {
    comet = (Comet*) [CCBReader load:@"Comet"];
    [comet setupRandomPosition];
    [comet pushToCenter];
    [_physicsNode addChild:comet];
    [[OALSimpleAudio sharedInstance] playEffect:@"Art/comet.wav"];
}

- (void)addShip {
    _ship = (Ship*) [CCBReader load:@"Ship"];
    [_ship spawn];
    [_ship moveShip];
    [_physicsNode addChild:_ship];
}

- (void)cometRemovedShip:(CCNode *)comett {
    CCParticleSystem *_cometExplosionShip = (CCParticleSystem*)[CCBReader load:@"CometExplosionShip"];
    _cometExplosionShip.autoRemoveOnFinish = YES;
    _cometExplosionShip.position = comett.position;
    [comett.parent addChild:_cometExplosionShip];
    
    [comett removeFromParent];
}

- (void)cometRemovedShield:(CCNode *)comett {
    CCParticleSystem *_cometExplosionShield = (CCParticleSystem*)[CCBReader load:@"CometExplosionShield"];
    _cometExplosionShield.autoRemoveOnFinish = YES;
    _cometExplosionShield.position = comett.position;
    [comett.parent addChild:_cometExplosionShield];
    
    [comett removeFromParent];
}

- (void)astroidRemoved:(CCNode *)astroidd {
    CCParticleSystem *_astroidExplosion = (CCParticleSystem*)[CCBReader load:@"AstroidExplosion"];
    _astroidExplosion.autoRemoveOnFinish = TRUE;
    _astroidExplosion.position = astroidd.position;
    [astroidd.parent addChild:_astroidExplosion];
    
    [astroidd removeFromParent];
}

- (void)astroidRemovedShield:(CCNode *)astroidd {
    CCParticleSystem *_astroidExplosionShield = (CCParticleSystem*)[CCBReader load:@"AstroidExplosionShield"];
    _astroidExplosionShield.autoRemoveOnFinish = YES;
    _astroidExplosionShield.position = astroidd.position;
    [astroidd.parent addChild:_astroidExplosionShield];
    
    [astroidd removeFromParent];
}

- (void)astronautRemoved:(CCNode *)astronautt {
    CCParticleSystem *_astronautRemoved = (CCParticleSystem*)[CCBReader load:@"Dead"];
    _astronautRemoved.autoRemoveOnFinish = YES;
    _astronautRemoved.position = astronautt.position;
    [astronautt.parent addChild:_astronautRemoved];
    
    [astronautt removeFromParent];
}

- (void)shipRemoved:(CCNode *)shipp {
    CCParticleSystem *_shipRemoved = (CCParticleSystem*)[CCBReader load:@"ShipDead"];
    _shipRemoved.autoRemoveOnFinish = YES;
    _shipRemoved.position = _ship.position;
    [shipp.parent addChild:_shipRemoved];
    
    [shipp removeFromParent];
}

//- (void)addHit {
//    _hit = (Hit*) [CCBReader load:@"Hit"];
//    [_physicsNode addChild:_hit];
//    CGPoint hitPosition = ccp(_winSize.width/2,_winSize.height/2);
//    _hit.position = hitPosition;
//}
//
//- (void)removeHit {
//    _hit.visible = NO;
//}

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

//- (void)checkToRemoveStranded {
//    int i = 0;
//    CGSize winSize = [CCDirector sharedDirector].viewSize;
//    while (i < _spawnedStranded.count) {
//        //this is the future: check astroids that have not been on screen
//        stranded = [_spawnedStranded objectAtIndex:i];
//        if (!stranded.hasBeenOnScreen) {
//            if (stranded.position.x > 0 && stranded.position.x < winSize.width && stranded.position.y > 0 && stranded.position.y < winSize.height) {
//                stranded.hasBeenOnScreen = YES;
//            }
//            i++;
//        } else {
//            if (stranded.position.x < -20 || stranded.position.x > winSize.width + 20 || stranded.position.y < -20 || stranded.position.y > winSize.height + 20) {
//                //remove from array
//                [_spawnedStranded removeObject:stranded];
//                //removes from scene
//                [stranded removeFromParent];
//                [_spawnedStranded removeAllObjects];
//            }else{
//                i++;
//            }
//        }
//    }
//}

- (void)saveScore {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:_points forKey:@"score"];
    [prefs synchronize];
}

//Save the number of stranded missed
//- (void)saveDeadScore {
//    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//    [prefs setInteger:_deadPoints forKey:@"dead"];
//    [prefs synchronize];
//}
@end
