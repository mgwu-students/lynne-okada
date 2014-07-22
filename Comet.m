//
//  Comet.m
//  lynneokada
//
//  Created by Lynne Okada on 7/22/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Comet.h"

@implementation Comet

- (void)setupRandomPosition {
    CGSize winSize = [CCDirector sharedDirector].viewSize;
    CGFloat randomPointX = arc4random()%(int)winSize.width;
    CGFloat randomPointY = arc4random()%(int)winSize.height;
    
    CGPoint randomPosition = ccp(randomPointX, randomPointY);
    
    int width = winSize.width/4;
    int height = winSize.height/4;
    
    int side = arc4random() % 4;
    switch (side) {
        case 0:
            randomPosition = ccp(randomPointX, -height);
            break;
        case 1:
            randomPosition = ccp(-width,randomPointY);
            break;
        case 2:
            randomPosition = ccp(randomPointX, winSize.height+height);
            break;
        case 3:
            randomPosition = ccp(winSize.width+width, randomPointY);
            break;
        default:
            break;
    }
    self.position = randomPosition;
}

- (void)pushToCenter {
    CGSize winSize = [CCDirector sharedDirector].viewSize;
    CGFloat PointX = winSize.width/2;
    CGFloat PointY = winSize.height/2;
    
    CGPoint Position = ccp(PointX, PointY);
    CGPoint forceVector = ccpSub(Position,self.position);

    forceVector = ccpMult(ccpNormalize(forceVector),10000);
    
    [self.physicsBody applyForce:forceVector];
}
@end
