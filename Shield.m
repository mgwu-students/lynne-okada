//
//  Shield.m
//  lynneokada
//
//  Created by Lynne Okada on 7/22/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Shield.h"

@implementation Shield

- (void)location {
    CGSize winSize = [CCDirector sharedDirector].viewSize;
    float positionX = winSize.width/2;
    float positionY = winSize.height/2;
    
    self.position = ccp(positionX, positionY);
}
@end
