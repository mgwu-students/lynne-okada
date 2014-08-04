//
//  StrandedAstronaut.m
//  lynneokada
//
//  Created by Lynne Okada on 7/14/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "StrandedAstronaut.h"

@implementation StrandedAstronaut{
    CCNode *_strandedAstronaut;
}

- (id)init {
    if (self = [super init]) {
        _attached = NO;
    }
    return self;
}

- (void)setupRandomPosition {
    CGSize winSize = [CCDirector sharedDirector].viewSize;
    CGFloat randomPointX = arc4random()%(int)winSize.width;
    CGFloat randomPointY = arc4random()%(int)winSize.height;
    
    CGPoint randomPosition = ccp(randomPointX, randomPointY);
    
    //int width = winSize.width/4;
    //int height = winSize.height/4;
    
    int side = arc4random() % 4;
    switch (side) {
        case 0:
            randomPosition = ccp(randomPointX, -self.contentSize.height/2);
            break;
        case 1:
            randomPosition = ccp(-self.contentSize.width/2,randomPointY);
            break;
        case 2:
            randomPosition = ccp(randomPointX, winSize.height+self.contentSize.height/2);
            break;
        case 3:
            randomPosition = ccp(winSize.width + self.contentSize.width/2, randomPointY);
            break;
        default:
            break;
    }
    self.position = randomPosition;
}

- (void)pushToRandomPoint {
    CGSize winSize = [CCDirector sharedDirector].viewSize;
    CGFloat randomPointX = arc4random()%(int)winSize.width;
    CGFloat randomPointY = arc4random()%(int)winSize.height;
    
    CGPoint randomPosition = ccp(randomPointX, randomPointY);
    CGPoint forceVector = ccpSub(randomPosition,self.position);
    
    int speed = arc4random()%50;
    forceVector = ccpMult(ccpNormalize(forceVector),1000.0+speed);
    //NSLog(@"self%f,%f,random%f,%f,force%f,%f",self.position.x,self.position.y,randomPointX,randomPointY,forceVector.x,forceVector.y);
    [self.physicsBody applyForce:forceVector];
}
@end
