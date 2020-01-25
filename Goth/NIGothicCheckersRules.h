//
//  NIGothicCheckersRules.h
//  Goth
//
//  Created by Martin Polák on 17.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NIGameRules.h"

@class NIGameRules, NIPosition, NIGameBoardRow;

@interface NIGothicCheckersRules : NIGameRules

- (id)makePawnRowOn:(id)board rowNumber:(int)rowNumber color:(int)col;
- (id)makeBorderBarrier:(id)board;
- (id)makeTopBottomBarrier:(id)row;

@end
