//
//  ShieldMeter.m
//  lynneokada
//
//  Created by Lynne Okada on 7/31/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "ShieldMeter.h"

@implementation ShieldMeter

- (void)meterPosition {
    CGSize winSize = [CCDirector sharedDirector].viewSize;
    
    CGPoint meterPosition = ccp(winSize.width/2,winSize.height/30);
    self.position = meterPosition;
}
@end
