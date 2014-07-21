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

@interface MainScene : CCNode <CCPhysicsCollisionDelegate>
{
    Astronaut* astronaut;
    Astroid* astroid;
    StrandedAstronaut* stranded;
}

@end
