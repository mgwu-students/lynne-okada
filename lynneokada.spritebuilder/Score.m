//
//  Score.m
//  lynneokada
//
//  Created by Lynne Okada on 7/11/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Score.h"

@implementation Score {
    NSInteger _points;
    NSInteger _highscore;
    NSInteger _dead;
    
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_highscoreLabel;
    CCLabelTTF *_deadLabel;
    CCLabelTTF *_new;
    
//    CCNode *_parallaxContainer;
//    CCParallaxNode *_parallaxBackground;
}

-(void) didLoadFromCCB{
    [self loadScore];
    [self loadHighscore];
    [self loadDeadScore];
    
    if (_points > _highscore) {
        _new.visible = YES;
        _highscore = _points;
        [self saveHighscore];
    }
    _scoreLabel.string = [NSString stringWithFormat:@"%d", _points];
    _highscoreLabel.string = [NSString stringWithFormat:@"%d", _highscore];
    _deadLabel.string = [NSString stringWithFormat:@"%d", _dead];
    
//    _parallaxBackground = [CCParallaxNode node];
//    [_parallaxContainer addChild:_parallaxBackground];
}

//- (void)update:(CCTime)delta {
//    _parallaxBackground.position = ccp(_parallaxBackground.position.x - (10 * delta), _parallaxBackground.position.y);
//}

- (void)retry {
    CCScene *retry = [CCBReader loadAsScene:@"MainScene"];
    [[OALSimpleAudio sharedInstance] playEffect:@"Art/start.wav"];
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
    [[CCDirector sharedDirector] replaceScene:retry withTransition:transition];
    NSLog(@"retry");
}

- (void)loadScore {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    _points = [prefs integerForKey:@"score"];
}

- (void)loadHighscore {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    _highscore = [prefs integerForKey:@"highscore"];
}

- (void)saveHighscore {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:_highscore forKey:@"highscore"];
    [prefs synchronize];
}

- (void)loadDeadScore {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    _dead = [prefs integerForKey:@"dead"];
}

- (void)menu {
    CCScene *menu = [CCBReader loadAsScene:@"Menu"];
    [[OALSimpleAudio sharedInstance] playEffect:@"Art/back.wav"];
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
    [[CCDirector sharedDirector] replaceScene:menu withTransition:transition];
}
@end
