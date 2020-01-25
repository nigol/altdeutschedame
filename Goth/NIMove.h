//
//  NIMove.h
//  Goth
//
//  Created by Martin Polák on 31.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "constants.h"

@class NIPoint;

@interface NIMove : NSObject

@property(readwrite, assign) id steps, captures, changes;

- (id)addStep:(id)point;
- (id)firstStep;
- (id)restSteps;
- (id)lastStep;
- (id)addCapture:(id)point;
- (BOOL)isStepsEqualTo:(id)stps;
- (BOOL)isCapturesEqualTo:(id)cptures;
- (BOOL)isEqualToMove:(id)move;
- (BOOL)isCaptures;
- (id)addChange:(id)point;
- (BOOL)isEmpty;
- (NSString *)asString;
- (int)capturesCount;

@end
