//
//  NITextUI.h
//  Goth
//
//  Created by Martin Polák on 19.11.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "constants.h"

@class NIGameBoard, NIGameControl, NIPiece, NIGameRules, NIMove, NIPoint, NIBarrier, NIPawn, NIQueen;

@interface NITextUI : NSObject

@property(readwrite, assign) id gameControl;

- (id)loop;
- (id)displayGameBoard:(id)board;
- (id)printCellAtX:(int)x y:(int)y of:(id)board;
- (id)askForMove;
- (id)askFrom;
- (id)askTo;
- (id)printGivenMove:(id)move;
- (id)printPlayerOnMove;
- (id)printHintFor:(id)point;
- (id)setUp;
- (id)printAllMovesOn:(id)board;
- (BOOL)discoverSituationOn:(id)board;

@end
