//
//  Tutorial.h
//  lynneokada
//
//  Created by Lynne Okada on 8/4/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "Ship.h"

@interface Tutorial : CCNode <CCPhysicsCollisionDelegate>
{
    Ship* _ship;
}

@end
