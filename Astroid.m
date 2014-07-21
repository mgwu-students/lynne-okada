//
//  Astroid.m
//  lynneokada
//
//  Created by Lynne Okada on 7/11/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Astroid.h"

@implementation Astroid {
    CCNode *_astroid;
}

- (id)init {
    if (self = [super init]) {
        _hasBeenOnScreen = NO;
    }
    return self;
}

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

- (void)pushToRandomPoint {
    CGSize winSize = [CCDirector sharedDirector].viewSize;
    CGFloat randomPointX = arc4random()%(int)winSize.width;
    CGFloat randomPointY = arc4random()%(int)winSize.height;
    
    CGPoint randomPosition = ccp(randomPointX, randomPointY);
    CGPoint forceVector = ccpSub(randomPosition,self.position);
    
    int speed = arc4random()%1000;
    forceVector = ccpMult(ccpNormalize(forceVector),1000.0+speed);
    //NSLog(@"self%f,%f,random%f,%f,force%f,%f",self.position.x,self.position.y,randomPointX,randomPointY,forceVector.x,forceVector.y);
    [self.physicsBody applyForce:forceVector];
}
@end