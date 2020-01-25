//
//  NISiliconBrain.h
//  Goth
//
//  Created by Martin Polák on 05.12.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "constants.h"

@class NIPosition, NIGameBoard, NIGameRules, NITextUI, NIMove;

@interface NISiliconBrain : NSObject

@property(readwrite, assign) id rules;
@property(readwrite, assign) BOOL paused;

- (id)positionsFrom:(id)position;
- (int)minimaxForPosition:(id)position depth:(int)depth;
- (id)bestMoveForPosition:(id)position depth:(int)depth;

@end
