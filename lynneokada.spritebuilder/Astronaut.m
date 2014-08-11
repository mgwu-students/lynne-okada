//
//  Astronaut.m
//  lynneokada
//
//  Created by Lynne Okada on 7/11/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Astronaut.h"

@implementation Astronaut

- (void)startPosition {
    //position astronaut to little above the ship(center of screen)
    float startX = [CCDirector sharedDirector].viewSize.width/2;
    float startY = [CCDirector sharedDirector].viewSize.height/2 + 20;
    self.position = ccp(startX,startY);
}

@end