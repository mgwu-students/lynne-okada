//
//  MainScene.h
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "Astronaut.h"
#import "Astroid.h"
#import "StrandedAstronaut.h"
#import "Shield.h"
#import "Comet.h"
#import "Ship.h"
#import "ShieldMeter.h"
#import "Warning.h"
#import "HealthBar.h"
#import "Hit.h"
#import "GameOver.h"

@interface MainScene : CCNode <CCPhysicsCollisionDelegate, UIGestureRecognizerDelegate>
{
    Astronaut* astronaut;
    Astroid* astroid;
    StrandedAstronaut* _stranded;
    Shield* shield;
    Comet* comet;
    Ship* _ship;
    ShieldMeter* _shieldMeter;
    Warning* _warning;
    HealthBar* _healthBar;
    Hit* _hit;
    GameOver* _gameOverWindow;
}

@property (nonatomic, assign) BOOL activate;
@property (nonatomic, assign) BOOL cometEntered;
@end
