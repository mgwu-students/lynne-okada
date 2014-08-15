//
//  Menu.m
//  lynneokada
//
//  Created by Lynne Okada on 7/10/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Menu.h"

@implementation Menu

- (void)didLoadFromCCB {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"backgroundMusic"]) {
        [[OALSimpleAudio sharedInstance] playBgWithLoop:TRUE];
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"backgroundMusic"];
    }
}

-(void)start {
    CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
    [[OALSimpleAudio sharedInstance] playEffect:@"Art/start.wav"];
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
    [[CCDirector sharedDirector] replaceScene:mainScene withTransition:transition];
    
//    CCScene *training = [CCBReader loadAsScene:@"Tutorial"];
//    [[OALSimpleAudio sharedInstance] playEffect:@"Art/start.wav"];
//    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
//    [[CCDirector sharedDirector] replaceScene:training withTransition:transition];
}

- (void)settings {
    CCScene *settings = [CCBReader loadAsScene:@"Settings"];
    [[OALSimpleAudio sharedInstance] playEffect:@"Art/select.wav"];
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.1f];
    [[CCDirector sharedDirector] replaceScene:settings withTransition:transition];
}

- (void)credits {
    CCScene *credits = [CCBReader loadAsScene:@"Credits"];
    [[OALSimpleAudio sharedInstance] playEffect:@"Art/select.wav"];
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.1f];
    [[CCDirector sharedDirector] replaceScene:credits withTransition:transition];
}

- (void)tutorial {
    CCScene *tutorial = [CCBReader loadAsScene:@"Tutorial"];
    [[OALSimpleAudio sharedInstance] playEffect:@"Art/select.wav"];
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.1f];
    [[CCDirector sharedDirector] replaceScene:tutorial withTransition:transition];
}
@end
