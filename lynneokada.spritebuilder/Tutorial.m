//
//  Tutorial.m
//  lynneokada
//
//  Created by Lynne Okada on 8/4/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Tutorial.h"
#import "Paper.h"

@implementation Tutorial {
    CCNode  *_goNext;
    CCNode *_paper;
    CCPhysicsNode *_physicsNode;
    CGSize _winSize;
}

- (void)didLoadFromCCB {
    _winSize = [CCDirector sharedDirector].viewSize;
}

- (void)onEnter {
    [super onEnter];
    
    [self addPaper];
    //[self addRight];
}

- (void)addPaper {
    _paper = (Paper*)[CCBReader load:@"Paper"];
    [_physicsNode addChild:_paper];
    float spawnX = _winSize.width/2;
    float spawnY = _winSize.height/2 - 300;
    _paper.position = ccp(spawnX, spawnY);
}

- (void)addRight {
    _goNext = [CCBReader load:@"goNext"];
    [_physicsNode addChild:_goNext];
    float spawnX = _winSize.width/2 + _paper.contentSize.width/2;
    float spawnY = 100;
    _goNext.position = ccp(spawnX,spawnY);
}
@end

