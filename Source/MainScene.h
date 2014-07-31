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

@interface MainScene : CCNode <CCPhysicsCollisionDelegate, UIGestureRecognizerDelegate>
{
    Astronaut* astronaut;
    Astroid* astroid;
    StrandedAstronaut* _stranded;
    Shield* shield;
    Comet* comet;
    Ship* _ship;
    ShieldMeter* _shieldMeter;
}

@property (nonatomic, assign) BOOL activate;
@end
