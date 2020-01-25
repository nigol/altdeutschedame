//
//  NIGameRules.h
//  Goth
//
//  Created by Martin Polák on 17.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "constants.h"

@class NIGameRules, NIPiece, NIPawn, NIQueen, NIBarrier, NIGameBoard, NIGameBoardRow, NIPoint, NIMove, NIFreeCell;
@class NIPosition;

@interface NIGameRules : NSObject

@property(readwrite, assign) int boardSize;

- (id)setInitialStateOn:(id)board;
- (id)pieceMovesFor:(id)piece on:(id)board;
- (id)captureLinesFrom:(id)lines with:(id)piece on:(id)board;
- (id)movesWithoutCapturesFrom:(id)lines with:(id)piece on:(id)board;
- (id)movesWithCapturesFrom:(id)lines with:(id)piece on:(id)board;
- (id)processPoint:(id)point start:(id)startPoint on:(id)board enemies:(id)enemies result:(id)result;
- (id)pointCaptureLinesFor:(id)point startPoint:(id)startPoint on:(id)board;
- (id)lineFromEnemy:(id)line myColor:(int)myColor on:(id)board;
- (id)lineAfterEnemy:(id)lineFromEnemy on:(id)board;
- (id)enemyPoint:(id)lineFromEnemy;
- (BOOL)isCapturePointIn:(id)line startPoint:(id)startPoint on:(id)board;
- (int)startingPlayer;
- (id)pieceLinesFor:(id)piece on:(id)board;
- (int)evaluatePosition:(id)position;
- (BOOL)isOnChangePoint:(id)point piece:(id)piece;
- (id)cutLineAtBarrier:(id)line on:(id)board;
- (int)whoWinsOn:(id)position;
- (id)cutLine:(id)line atPieceColor:(int)color on:(id)board;
- (BOOL)isWinningPosition:(id)position;
- (BOOL)isLoosingPosition:(id)position;
- (BOOL)isDrawPosition:(id)position;
- (id)cutLineAtPiece:(id)line on:(id)board;
- (id)selectMovesWithMostCaptures:(id)moves;

@end
