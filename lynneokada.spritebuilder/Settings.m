//
//  Settings.m
//  lynneokada
//
//  Created by Lynne Okada on 8/7/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Settings.h"

@implementation Settings

- (void)back {
    [[OALSimpleAudio sharedInstance] playEffect:@"Art/back.wav"];
    CCScene *menu = [CCBReader loadAsScene:@"Menu"];
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.1f];
    [[CCDirector sharedDirector] replaceScene:menu withTransition:transition];
}

@end
