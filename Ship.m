//
//  Ship.m
//  lynneokada
//
//  Created by Lynne Okada on 7/28/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Ship.h"

@implementation Ship

- (void)sendShip {
    CGSize _winSize = [CCDirector sharedDirector].viewSize;
    CGPoint shipPos = ccp(_winSize.width/2, _winSize.height/2);
    CGPoint moveTo = ccp(_winSize.width,shipPos.y);
    CGPoint move = ccpSub(moveTo, shipPos);
    move = ccpMult(move,200);
    [self.physicsBody applyForce:move];
}

@end
