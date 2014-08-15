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
    [self addNext];
}

- (void)next {
    [self loadPage:_pages[_onPage]];
     _onPage++;
}

- (void)update:(CCTime)delta{
    if (_brakeOff && _page1.position.y >= _winSize.height/2-40) {
        //kill applied force
        _page1.physicsBody.velocity = ccp(0,0);
        //_brakeOff = NO;
        
        //reposition ship to center
        _page1.position = ccp(_winSize.width/2,_winSize.height/2-40);
    }
    [self loadPage:_pages[1]];
}

- (void)addPage1 {
    _page1 = [CCBReader load:@"Tutorial1"];
    [self addChild:_page1];
    CGFloat spawnX = _winSize.width/2;
    CGFloat spawnY = _winSize.height/2 - 400;
    CGPoint spawnPos = ccp(spawnX, spawnY);
    _page1.position = spawnPos;
    CGPoint moveTo = ccp(_winSize.width/2, _winSize.height-10);
    CCActionMoveTo *move = [CCActionMoveTo actionWithDuration:1.0f position:moveTo];
    [_page1 runAction:move];
}

- (void)loadPage:(NSString*)pageNumber {
    CCNode *_page = [CCBReader load:pageNumber];
    [self addChild:_page];
    CGPoint loadTo = ccp(_winSize.width/2,_winSize.height-70);
    _page.position = loadTo;
}

- (void)addNext {
    _next = [CCBReader load:@"Next"];
    [self addChild:_next];
    CGPoint place = ccp(_winSize.width/2+_page1.contentSize.width/2,200);
    _next.position = place;
}
@end

