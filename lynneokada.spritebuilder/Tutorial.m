//
//  Tutorial.m
//  lynneokada
//
//  Created by Lynne Okada on 8/4/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Tutorial.h"
#import "CCPhysics+ObjectiveChipmunk.h"

@implementation Tutorial {
    CCNode *_contentNode;
    CCNode *_next;
    CCNode *_page1;
    CCNode *_page2;
    CCNode *_page3;
    CCNode *_page4;
    CGSize _winSize;
    BOOL _brakeOff;
    NSArray *_pages;
    int _onPage;
    CGPoint _initialTouch;
}

- (id)init {
    if (self = [super init])
    {
        // activate touches on this scene
        self.userInteractionEnabled = TRUE;
        
        _pages = [NSArray array];
    }
    return self;
}


- (void)didLoadFromCCB {
    _winSize = [CCDirector sharedDirector].viewSize;
    _brakeOff = YES;
    _onPage = 1;
 
    _page2 = [CCBReader load:@"Page2"];
    _page3 = [CCBReader load:@"Page3"];
    _page4 = [CCBReader load:@"Page4"];
    _pages = @[@"blank",@"Page2",@"Page3",@"Page4"];
}

- (void)onEnter {
    [super onEnter];
    
    [self addPage1];
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (_page1.position.y == _winSize.height/2-30) {
        if (_onPage == 1) {
            [[OALSimpleAudio sharedInstance] playEffect:@"Art/paper.wav"];
            [self loadPage:_pages[_onPage]];
            [_page1 removeFromParent];
            _onPage++;
        } else if (_onPage == 2) {
            [[OALSimpleAudio sharedInstance] playEffect:@"Art/paper.wav"];
            [self loadPage:_pages[_onPage]];
            [_page2 removeFromParent];
            _onPage++;
        } else if (_onPage == 3) {
            [[OALSimpleAudio sharedInstance] playEffect:@"Art/paper.wav"];
            [self loadPage:_pages[_onPage]];
            [_page3 removeFromParent];
            _onPage++;
        } else if (_onPage > 3) {
            CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
            [[OALSimpleAudio sharedInstance] playEffect:@"Art/start.wav"];
            //CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
            

//            [[CCDirector sharedDirector] replaceScene:mainScene withTransition:transition];
            [[CCDirector sharedDirector] pushScene:mainScene];
        }
    }
}


- (void)addPage1 {
    _page1 = [CCBReader load:@"Page1"];
    [self addChild:_page1];
    CGFloat spawnX = _winSize.width/2;
    CGFloat spawnY = _winSize.height/2 - 400;
    CGPoint spawnPos = ccp(spawnX, spawnY);
    _page1.position = spawnPos;
    CGPoint moveTo = ccp(_winSize.width/2, _winSize.height/2-30);
    CCActionMoveTo *move = [CCActionMoveTo actionWithDuration:1.0f position:moveTo];
    [_page1 runAction:move];
}

- (void)loadPage:(NSString*)pageNumber {
    CCNode *_page = [CCBReader load:pageNumber];
    [self addChild:_page];
    CGPoint loadTo = ccp(_winSize.width/2,_winSize.height/2-30);
    _page.position = loadTo;
}

- (void)addNext {
    _next = [CCBReader load:@"Next"];
    [self addChild:_next];
    CGPoint place = ccp(_winSize.width/2+_page1.contentSize.width/2,200);
    _next.position = place;
}



- (void)back {
    [[OALSimpleAudio sharedInstance] playEffect:@"Art/back.wav"];
    CCScene *menu = [CCBReader loadAsScene:@"Menu"];
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.1f];
    [[CCDirector sharedDirector] replaceScene:menu withTransition:transition];
}
@end

