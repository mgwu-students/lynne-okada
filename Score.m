//
//  Score.m
//  lynneokada
//
//  Created by Lynne Okada on 7/11/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Score.h"

@implementation Score


- (void)retry {
    CCScene *retry = [CCBReader loadAsScene:@"MainScene"];
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
    [[CCDirector sharedDirector] replaceScene:retry withTransition:transition];
    NSLog(@"retry");
}

@end
