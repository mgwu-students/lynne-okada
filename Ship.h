//
//  Ship.h
//  lynneokada
//
//  Created by Lynne Okada on 7/28/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface Ship : CCSprite <CCPhysicsCollisionDelegate>
- (void)sendShip;
- (void)spawn;
- (void)moveShip;
@property (nonatomic, assign) BOOL brakeOff;
@end
