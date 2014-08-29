//
//  IGTutorial.h
//  Stranded in Space
//
//  Created by Lynne Okada on 8/24/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "MainScene.h"
#import "Ship.h"

@interface IGTutorial : CCNode <CCPhysicsCollisionDelegate>
{
    MainScene* _mainScene;
    Ship* _ship;
    Astronaut* _astronaut;
    Astroid* _astroid;
    Shield* _shield;
    ShieldMeter* _shieldMeter;
    HealthBar* _healthBar;
    StrandedAstronaut* _stranded;
}
@end
