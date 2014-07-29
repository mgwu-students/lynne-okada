//
//  Ship.m
//  lynneokada
//
//  Created by Lynne Okada on 7/28/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Ship.h"

@implementation Ship {
    CGSize _winSize;
    int _speed;
}

- (id)init {
    if (self = [super init])
    {
        _speed = 15;
    }
    return self;
}

- (void)didLoadFromCCB {
    _winSize = [[CCDirector sharedDirector]viewSize];
    _brakeOn = YES;
}

- (void)sendShip {
    CGPoint shipPos = ccp(_winSize.width/2, _winSize.height/2);
    CGPoint moveTo = ccp(_winSize.width,shipPos.y);
    CGPoint move = ccpSub(moveTo, shipPos);
    move = ccpMult(move,30);
    [self.physicsBody applyForce:move];
}

- (void)spawn{
    CGPoint spawnPos = ccp(-_winSize.width/2,_winSize.height/2);
    self.position = spawnPos;
}

- (void)moveShip {
    CGPoint spawnPos = ccp(-_winSize.width/2,_winSize.height/2);
    CGPoint moveTo = ccp(_winSize.width/2,_winSize.height/2);
    CGPoint spawn = ccpSub(moveTo,spawnPos);
    spawn = ccpMult(spawn, _speed);
    [self.physicsBody applyForce:spawn];
}

- (void)update:(CCTime)delta{
    if (_brakeOn && self.position.x >= _winSize.width/2) {
        self.physicsBody.velocity = ccp(0,0);
    }
}
@end
