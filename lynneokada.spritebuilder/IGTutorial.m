//
//  IGTutorial.m
//  Stranded in Space
//
//  Created by Lynne Okada on 8/24/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "IGTutorial.h"
#import "MainScene.h"
#import "Ship.h"
#import <CoreMotion/CoreMotion.h>
#import "CCPhysics+ObjectiveChipmunk.h"
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


@implementation IGTutorial {
    CCPhysicsNode *_physicsNode;
    CCNode *_tilt;
    CCNode *_you;
    CCNode *_help;
    CCLabelTTF *_yoship;
    CCLabelTTF *_tiltText;
    CCLabelTTF *_tap;
    CCLabelTTF *_shieldd;
    CCLabelTTF *_healthMeter;
    CCLabelTTF *_saveThem;
    CCLabelTTF *_comeBack;
    CCProgressNode *_progressShield;
    CCProgressNode *_progressHealth;
    CGSize _winSize;
    CMMotionManager *_motion;
    NSMutableArray *_spawnedAstroids;
    NSMutableArray *_spawnedStranded;
    NSMutableArray *_attachedStranded;
    NSArray *_rescuedSounds;
    BOOL _player;
    BOOL _activate;
    float _tutorialTime;
    int _astroidNum;
}

- (void)didLoadFromCCB {
    _physicsNode.collisionDelegate = self;
    _winSize = [CCDirector sharedDirector].viewSize;
    
    //shield meter
    [self schedule:@selector(updateShield) interval:0.1f];
    _rescuedSounds = @[@"Art/Yo.wav",@"Art/Sweet.wav",@"Art/Cool.wav"];
}

- (id)init {
    if (self = [super init])
    {
        // activate touches on this scene
        self.userInteractionEnabled = TRUE;
        _motion = [[CMMotionManager alloc] init];
        _spawnedAstroids = [NSMutableArray array];
        _spawnedStranded = [NSMutableArray array];
        _attachedStranded = [NSMutableArray array];
        _rescuedSounds = [NSArray array];
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
            [_shield removeFromParent];
        }
    }
}

- (void)updateHealth {
    if (_progressHealth.percentage > 0) {
        _progressHealth.percentage -= 30;
    }
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    //_initialTouch = touch.locationInWorld;
    _activate = YES;
    
    if (_ship.physicsBody.velocity.x == 0 && _progressShield.percentage > 0.0f) {
        [self addShield];
    }
}

- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    _activate = NO;
    [_shield removeFromParent];
    if (_progressShield.percentage > 0.0f && _ship.position.x == _winSize.width/2) {
    [[OALSimpleAudio sharedInstance] playEffect:@"Art/shieldOff.wav"];
    }
}

- (void)update:(CCTime)delta {
    _tutorialTime += delta;
    
    //accelerometer
    CMAccelerometerData * accelerometerData= _motion.accelerometerData;
    CMAcceleration acceleration = accelerometerData.acceleration;
    
    float spriteSpeed = 5.0f;
    float xa, ya;
    
    xa = acceleration.x;
    ya = acceleration.y;
    //NSLog(@"acceleration-x: %f <> y:%f", xa, ya);
    
    float velocityVectorY = spriteSpeed*ya;
    float velocityVectorX = spriteSpeed*xa;
    
    CGPoint velocity = CGPointMake(velocityVectorY, -velocityVectorX);
    CGPoint newPosition = ccpAdd(_astronaut.position, velocity);
    newPosition = ccp(clampf(newPosition.x, 5, _winSize.width-5),clampf(newPosition.y, 10, _winSize.height-10));
    
    _astronaut.position = newPosition;
    _you.position = ccp(_astronaut.position.x + 65, _astronaut.position.y);
    _help.position = ccp(_stranded.position.x, _stranded.position.y - 10);
    
    if (_ship.position.x == _winSize.width/2) {
        _yoship.visible = YES;
    }
    
    if (_player == TRUE) {
        _yoship.visible = NO;
        _you.visible = YES;
    }
    
    if (_tutorialTime >= 10.0f) {
        [_you removeFromParent];
        _tilt.visible = YES;
        _tiltText.visible = YES;
    }
    if (_tutorialTime >= 15.0f) {
        _tilt.visible = NO;
        _tiltText.visible = NO;
        _tap.visible = YES;
    }
    if (_tutorialTime >= 20.0f) {
        if (_progressHealth.percentage > 0 && _ship.position.x == _winSize.width/2) {
            _healthBar.visible = YES;
            _shieldMeter.visible = YES;
            _shieldd.visible = YES;
            _healthMeter.visible = YES;
            [_tap removeFromParent];
        }
    }
    if (_tutorialTime >= 25.0f) {
        [_shieldd removeFromParent];
        [_healthMeter removeFromParent];
        _saveThem.visible = YES;
    }
    
    if (_attachedStranded.count > 0) {
        _comeBack.visible = YES;
        [_saveThem removeFromParent];
    }
    
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
}

- (void)onEnter {
    [super onEnter];
    
    _player = FALSE;
    [self addShip];
    [self schedule:@selector(addAstronaut) interval:1.0f repeat:0 delay:4.0f];
    [self schedule:@selector(addAstroid) interval:3.0f];
    [self schedule:@selector(addStrandedAstronaut) interval:1.0f repeat:0 delay:25.0f];
    [self addAstroid];
    
    [_motion startAccelerometerUpdates];
    
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
    _shieldMeter.visible = NO;
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
}

-(void)onExit
{
    self.userInteractionEnabled = NO;
    [_motion stopAccelerometerUpdates];
    [super onExit];
}

- (void)addShip {
    _ship = (Ship*) [CCBReader load:@"Ship"];
    [_ship spawn];
    [_ship moveShip];
    [_physicsNode addChild:_ship];
}

- (void)addAstronaut {
    _astronaut = (Astronaut*)[CCBReader load:@"Astronaut"];
    [_astronaut startPosition];
    _astronaut.physicsBody.collisionType = @"astronaut";
    [_physicsNode addChild:_astronaut];
    _player = TRUE;
}

- (void)addAstroid {
    _astroid = (Astroid*)[CCBReader load:@"Astroid"];
    [_astroid setupRandomPosition];
    [_physicsNode addChild:_astroid];
    [_spawnedAstroids addObject:_astroid];
    [_astroid pushToRandomPoint];
}

- (void)addShield {
    _shield = (Shield*) [CCBReader load:@"Shield"];
    [_shield location];
    [_physicsNode addChild:_shield];
    [[OALSimpleAudio sharedInstance] playEffect:@"Art/shield.wav"];
}

- (void)addStrandedAstronaut {
    _stranded = (StrandedAstronaut*)[CCBReader load:@"StrandedAstronaut"];
    [_stranded setupRandomPosition];
    [_stranded pushToRandomPoint];
    [_physicsNode addChild:_stranded];
    [_spawnedStranded addObject:_stranded];
}

//COLLISIONS
//astronaut - shield
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair astronaut:(CCNode *)nodeA shield:(CCNode *)nodeB {
    return FALSE;
}

//astronaut - stranded
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair astronaut:(CCNode *)nodeA stranded:(CCNode *)nodeB {
    int i = arc4random()%3;
    [[OALSimpleAudio sharedInstance] playEffect:_rescuedSounds[i]];
    nodeA.physicsBody.collisionGroup = @"attached";
    nodeB.physicsBody.collisionGroup = @"attached";
    CCActionMoveToNode *moveTo = [CCActionMoveToNode actionWithSpeed:170.f positionUpdateBlock:^CGPoint{
        return nodeA.position;
    } followInfinite:YES];
    [nodeB runAction:moveTo];
    [_attachedStranded addObject:nodeB];
    [_help removeFromParent];
    return YES;
}

//astronaut - astroid
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair astronaut:(CCNode *)nodeA astroid:(CCNode *)nodeB {
    [[OALSimpleAudio sharedInstance] playEffect:@"Art/dead.wav"];
    [self astronautRemoved:nodeA];
    [self schedule:@selector(addAstronaut) interval:1.0f repeat:0 delay:1.0f];
    return YES;
}

//astronaut - ship
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair astronaut:(CCNode *)nodeA ship:(CCNode *)nodeB {
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

//astroid - shield
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair astroid:(CCNode *)nodeA shield:(CCNode *)nodeB {
    [[OALSimpleAudio sharedInstance] playEffect:@"Art/shieldAstroid.wav"];
    [self astroidRemovedShield:nodeA];
    return TRUE;
}

//astroid - ship
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair astroid:(CCNode *)nodeA ship:(Ship *)nodeB {
    if (_ship.physicsBody.velocity.x == 0) {
        [self updateHealth];
        [[OALSimpleAudio sharedInstance] playEffect:@"Art/explosion.wav"];
        [self astroidRemoved:nodeA];
    }
    return NO;
}

//stranded - ship
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair stranded:(CCNode *)nodeA ship:(CCNode *)nodeB {
    return FALSE;
}

//stranded - shield
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair stranded:(CCNode *)nodeA shield:(CCNode *)nodeB {
    return FALSE;
}

//astroid - stranded
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair astroid:(CCNode *)nodeA stranded:(CCNode *)nodeB {
    return FALSE;
}

- (void)astronautRemoved:(CCNode *)astronautt {
    CCParticleSystem *_astronautRemoved = (CCParticleSystem*)[CCBReader load:@"Dead"];
    _astronautRemoved.autoRemoveOnFinish = YES;
    _astronautRemoved.position = astronautt.position;
    [astronautt.parent addChild:_astronautRemoved];
    
    [astronautt removeFromParent];
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

- (void)checkToRemoveAstroids {
    int i = 0;
    CGSize winSize = [CCDirector sharedDirector].viewSize;
    while (i < _spawnedAstroids.count) {
        //this is the future: check astroids that have not been on screen
        _astroid = [_spawnedAstroids objectAtIndex:i];
        if (!_astroid.hasBeenOnScreen) {
            if (_astroid.position.x > 0 && _astroid.position.x < winSize.width && _astroid.position.y > 0 && _astroid.position.y < winSize.height) {
                _astroid.hasBeenOnScreen = YES;
            }
            i++;
        } else {
            if (_astroid.position.x < -10 || _astroid.position.x > winSize.width + 10 || _astroid.position.y < -10 || _astroid.position.y > winSize.height + 10) {
                //remove from array
                [_spawnedAstroids removeObject:_astroid];
                //removes from scene
                [_astroid removeFromParent];
            }else{
                i++;
            }
        }
    }
}
@end
