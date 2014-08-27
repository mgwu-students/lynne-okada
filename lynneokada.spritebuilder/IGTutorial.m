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
    CCLabelTTF *_yoship;
    CCLabelTTF *_you;
    CCProgressNode *_progressShield;
    CCProgressNode *_progressHealth;
    CGSize _winSize;
    CMMotionManager *_motion;
    BOOL _player;
    BOOL _activate;
}

- (id)init {
    if (self = [super init])
    {
        // activate touches on this scene
        self.userInteractionEnabled = TRUE;
    }
    return self;
}

- (void)didLoadFromCCB {
    _physicsNode.collisionDelegate = self;
    _winSize = [CCDirector sharedDirector].viewSize;
}

- (void)update:(CCTime)delta {
    //accelerometer
    CMAccelerometerData * accelerometerData = _motion.accelerometerData;
    CMAcceleration acceleration = accelerometerData.acceleration;
    
    //change this to change sprite speed
    float spriteSpeed = 5.0f;
    float xa, ya;
    
    xa = acceleration.x;
    ya = acceleration.y;
    
    //tilting side-to-side when held horizontal to ground
    float velocityVectorX = spriteSpeed*xa;
    float velocityVectorY = spriteSpeed*ya;
    
    
    CGPoint velocity = CGPointMake(velocityVectorY, -velocityVectorX);
    CGPoint newPosition = ccpAdd(_astronaut.position, velocity);
    newPosition = ccp(clampf(newPosition.x, 0, _winSize.width),clampf(newPosition.y, 0, _winSize.height));
    
    _astronaut.position = newPosition;
    
    if (_ship.position.x == _winSize.width/2) {
        _yoship.visible = YES;
    }
    
    if (_player == TRUE) {
        _yoship.visible = NO;
        _you.visible = YES;
    }
}

- (void)onEnter {
    [super onEnter];
    
    _player = FALSE;
    [self addShip];
    [self schedule:@selector(addAstronaut) interval:1.0f repeat:0 delay:4.0f];
    
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
    _astronaut.physicsBody.collisionType = @"nothing";
    [_physicsNode addChild:_astronaut];
    _player = TRUE;
}

- (void)addShield {
    _shield = (Shield*) [CCBReader load:@"Shield"];
    [_shield location];
    [_physicsNode addChild:_shield];
    [[OALSimpleAudio sharedInstance] playEffect:@"Art/shield.wav"];
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
}


- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair nothing:(CCNode *)nodeA shield:(CCNode *)nodeB {
    return FALSE;
}
@end
