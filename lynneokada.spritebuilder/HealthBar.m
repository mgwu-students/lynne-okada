//
//  HealthBar.m
//  lynneokada
//
//  Created by Lynne Okada on 8/5/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "HealthBar.h"

@implementation HealthBar

- (void)barLocation {
    CGSize winSize = [CCDirector sharedDirector].viewSize;
    
    CGPoint meterPosition = ccp(winSize.width/2,winSize.height/2 - 22);
    self.position = meterPosition;
}

@end
