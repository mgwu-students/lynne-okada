//
//  StrandedAstronaut.h
//  lynneokada
//
//  Created by Lynne Okada on 7/14/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface StrandedAstronaut : CCSprite
- (void)setupRandomPosition;
- (void)pushToRandomPoint;
@property (nonatomic, assign) BOOL hasBeenOnScreen;
@property (nonatomic, assign) BOOL Attached;
@end
