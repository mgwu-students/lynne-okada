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
    CCNode *_paper;
    CCNode *_contentNode;
    CCNode *_page1;
    CCNode *_page2;
    CCNode *_page3;
    CCNode *_page4;
    CGSize _winSize;
    BOOL _brakeOff;
    NSArray *_pages;
    int _onPage;
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
    _onPage = 0;
    
    _page1 = [CCBReader load:@"Page1"];
    _page2 = [CCBReader load:@"Page2"];
    _page3 = [CCBReader load:@"Page3"];
    _page4 = [CCBReader load:@"Page4"];
    _pages = @[_page1,_page2,_page3,_page4];
}

- (void)onEnter {
    [super onEnter];
    
    [self addPaper];
    
}

- (void)update:(CCTime)delta{
    if (_brakeOff && _paper.position.y >= _winSize.height/2-40) {
        //kill applied force
        _paper.physicsBody.velocity = ccp(0,0);
        //_brakeOff = NO;
        
        //reposition ship to center
        _paper.position = ccp(_winSize.width/2,_winSize.height/2-40);
    }
}

- (void)addPaper {
    _paper = [CCBReader load:@"Tutorial1"];
    [self addChild:_paper];
    float spawnX = _winSize.width/2;
    float spawnY = _winSize.height/2 - 400;
    CGPoint spawnPos = ccp(spawnX, spawnY);
    _paper.position = spawnPos;
    CGPoint moveTo = ccp(_winSize.width/2, _winSize.height-10);
    CCActionMoveTo *move = [CCActionMoveTo actionWithDuration:1.0f position:moveTo];
    [_paper runAction:move];
}

- (void)next {
    _onPage++;
}
@end

