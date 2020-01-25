//
//  NIGameBoard.h
//  Goth
//
//  Created by Martin Polák on 17.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIGameRules, NIGothicCheckersRules, NIGameBoard, NIPiece, NIMove, NIFreeCell, NIQueen;

@interface NIGameBoard : NSObject <NSMutableCopying>

@property(readwrite, assign) id rules, rows;

- (int)numberOfBoardRows;
- (id)rowAt:(int)index;
- (id)cellAtX:(int)x y:(int)y;
- (id)cellAtPoint:(id)point;
- (id)setCellAtPoint:(id)point on:(id)object;
- (id)setCellAtX:(int)x y:(int)y on:(id)object;
- (id)moves;
- (id)performMove:(id)move;
- (int)colorAtPoint:(id)point;
- (id)movesFor:(int)color;

@end
