//
//  NIBoardComponent.h
//  Goth
//
//  Created by Martin Polák on 21.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "constants.h"

@class NIGameBoard, NIPiece, NIPawn, NIQueen, NIPoint, NIMove;

@interface NIBoardComponent : NSControl

@property (readwrite, assign) int cellDimension, boardSize;
@property (readwrite, assign) NIGameBoard *gameBoard;
@property (readwrite, assign) NIPoint *selectedCell;
@property (readwrite, assign) NSMutableArray *hintMoves;
@property (readwrite, assign) NIPoint *clickedPoint;
@property (readwrite, assign) NSMutableArray *helpMoves;
@property (readwrite, assign) BOOL showHints;

+ (id)cellClass;
- (BOOL)isEven:(int)value;
- (NSColor *)colorForRow:(int)row column:(int)column;
- (void)drawCellInRect:(NSRect)rect withColor:(NSColor *)color;
- (void)drawBackground;
- (void)drawPawnInRect:(NSRect)rect withColor:(NSColor *)color;
- (void)drawPieces;
- (void)drawPieceAtX:(int)x Y:(int)y in:(NSRect)rect;
- (void)drawSituation;
- (void)drawQueenInRect:(NSRect)rect withColor:(NSColor *)color;
- (void)drawSelectedCell;
- (void)drawHintCells;
- (void)drawCellsFromMoves:(NSMutableArray *)moves withColor:(NSColor *)color;
- (void)drawHelpCells;

@end
