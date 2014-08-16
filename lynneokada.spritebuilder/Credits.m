//
//  Credits.m
//  lynneokada
//
//  Created by Lynne Okada on 8/7/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Credits.h"

@implementation Credits {
    CCNode *_creditsNode;
    CCNode *_thanksNode;
}

- (void) back{
    [[OALSimpleAudio sharedInstance] playEffect:@"Art/back.wav"];
    if (_creditsNode.visible == YES) {
        CCScene *menu = [CCBReader loadAsScene:@"Menu"];
        CCTransition *transition = [CCTransition transitionFadeWithDuration:0.1f];
        [[CCDirector sharedDirector] replaceScene:menu withTransition:transition];
    }
    
    if (_thanksNode.visible == YES) {
        _thanksNode.visible = NO;
        _creditsNode.visible = YES;
    }
}

- (void)more {
    [[OALSimpleAudio sharedInstance] playEffect:@"Art/select.wav"];
    _creditsNode.visible = NO;
    _thanksNode.visible = YES;
}
@end
