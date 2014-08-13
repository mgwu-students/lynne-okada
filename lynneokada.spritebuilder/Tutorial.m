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
    CCNode  *_goNext;
    CCNode *_paper;
    CCPhysicsNode *_physicsNode;
    CGSize _winSize;
    BOOL _brakeOff;
    NSMutableArray *_pages;
}

- (void)didLoadFromCCB {
    _physicsNode.collisionDelegate = self;
    _winSize = [CCDirector sharedDirector].viewSize;
    _brakeOff = YES;
}

- (void)onEnter {
    [super onEnter];
    
    [self addPaper];
    
}

- (void)update:(CCTime)delta{
    if (_brakeOff && _paper.position.y >= _winSize.height/2-40) {
        //kill applied force
        _paper.physicsBody.velocity = ccp(0,0);
        [self addRight];
        //_brakeOff = NO;
        
        //reposition ship to center
        _paper.position = ccp(_winSize.width/2,_winSize.height/2-40);
    }
}

- (void)addPaper {
    _paper = [CCBReader load:@"Paper"];
    [_physicsNode addChild:_paper];
    float spawnX = _winSize.width/2;
    float spawnY = _winSize.height/2 - 400;
    CGPoint spawnPos = ccp(spawnX, spawnY);
    _paper.position = spawnPos;
    
    CGPoint moveTo = ccp(_winSize.width/2, _winSize.height-10);
    CGPoint push = ccpSub(moveTo, spawnPos);
    push = ccpMult(push, 1000 * 5);
    [_paper.physicsBody applyForce:push];
}

- (void)addRight {
    _goNext = [CCBReader load:@"Next"];
    [self addChild:_goNext];
    float spawnX = _winSize.width/2 + _paper.contentSize.height/2 + 3;
    float spawnY = _winSize.height - 53;
    _goNext.position  = ccp(spawnX,spawnY);
}

@end

