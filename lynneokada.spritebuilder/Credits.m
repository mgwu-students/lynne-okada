//
//  Credits.m
//  lynneokada
//
//  Created by Lynne Okada on 8/7/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Credits.h"

@implementation Credits

- (void) back{
    [[OALSimpleAudio sharedInstance] playEffect:@"Art/back.wav"];
    CCScene *menu = [CCBReader loadAsScene:@"Menu"];
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.1f];
    [[CCDirector sharedDirector] replaceScene:menu withTransition:transition];
}
@end
