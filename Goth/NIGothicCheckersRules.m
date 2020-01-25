//
//  NIGothicCheckersRules.m
//  Goth
//
//  Created by Martin Polák on 17.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NIGothicCheckersRules.h"
#import "NIPiece.h"
#import "NIPawn.h"
#import "NIQueen.h"
#import "NIBarrier.h"
#import "NIGameBoard.h"
#import "NIGameBoardRow.h"
#import "NIPoint.h"
#import "NIMove.h"
#import "NIPosition.h"
#import "NIGameBoardRow.h"

@implementation NIGothicCheckersRules

- (id)init
{
    self = [super init];
    if (self) {
        [self setBoardSize: 10];
    }
    
    return self;
}

- (id)setInitialStateOn:(id)board
{
    [self makeBorderBarrier: board];
    [self makePawnRowOn: board rowNumber: 8 color: BLACK];
    [self makePawnRowOn: board rowNumber: 7 color: BLACK];
    [self makePawnRowOn: board rowNumber: 1 color: WHITE];
    [self makePawnRowOn: board rowNumber: 2 color: WHITE];
    return self;
}

- (id)makePawnRowOn:(id)board rowNumber:(int)rowNumber color:(int)col
{
    int i;
    id row, pawn;
    
    row = [board rowAt: rowNumber];
    for (i = 1; i < [self boardSize] - 1; i++) {
        pawn = [[NIPawn alloc] init];
        [pawn setPositionX: i y: rowNumber];
        [pawn setPieceColor: col];
        [pawn setRules: self];
        [row setCellAt: i on: pawn];
    }
    return self;
}

- (int)startingPlayer
{
    return WHITE;
}

- (id)pieceLinesFor:(id)piece on:(id)board
{
    id lines = [[NSMutableArray alloc] init];
    id position = [piece positionPoint];
    
    if ([piece isKindOfClass: [NIPawn class]]) {        
        [lines addObject: [position lineLength: 3 xStep: -1 yStep: 0]];
        [lines addObject: [position lineLength: 3 xStep: 1 yStep: 0]];
        [lines addObject: [position lineLength: 3 xStep: -1 yStep: [piece pieceColor]]];
        [lines addObject: [position lineLength: 3 xStep: 0 yStep: [piece pieceColor]]];
        [lines addObject: [position lineLength: 3 xStep: 1 yStep: [piece pieceColor]]];
        return lines;
    }
    if ([piece isKindOfClass: [NIQueen class]]) {        
        [lines addObject: [position lineLength: 9 xStep: -1 yStep: 0]];
        [lines addObject: [position lineLength: 9 xStep: 1 yStep: 0]];
        [lines addObject: [position lineLength: 9 xStep: 0 yStep: -1]];
        [lines addObject: [position lineLength: 9 xStep: 0 yStep: 1]];
        [lines addObject: [position lineLength: 9 xStep: 1 yStep: 1]];
        [lines addObject: [position lineLength: 9 xStep: -1 yStep: 1]];
        [lines addObject: [position lineLength: 9 xStep: 1 yStep: -1]];
        [lines addObject: [position lineLength: 9 xStep: -1 yStep: -1]];
        return lines;
    }
    return lines;
}

- (int)evaluatePosition:(id)position
{
    __block int result = 0;
        
    [[[position gameBoard] rows] enumerateObjectsUsingBlock:^(id row, NSUInteger idx, BOOL *stop) {
        [[row cells] enumerateObjectsUsingBlock:^(id cell, NSUInteger idx, BOOL *stop) {
            int white_pawn[8][8] = {
                { 0,  0,  0,  0,  0,  0,  0,  0},
                {-2, -2,  1,  1,  1,  1, -2, -2},
                { 3,  0,  2,  2,  2,  0,  0,  3},
                { 4,  0,  3,  3,  3,  0,  0,  4},
                { 5,  0,  0,  5,  0,  0,  0,  5},
                { 6,  0,  0,  0,  0,  0,  0,  6},
                { 7,  0,  0,  0,  0,  0,  0,  7},
                { 9,  8,  8,  8,  8,  8,  8,  9},
            };
            int black_pawn[8][8] = {
                { 9,  8,  8,  8,  8,  8,  8,  9},
                { 7,  0,  0,  0,  0,  0,  0,  7},
                { 6,  0,  0,  0,  0,  0,  0,  6},
                { 5,  0,  0,  5,  0,  0,  0,  5},
                { 4,  0,  3,  3,  3,  0,  0,  4},
                { 3,  0,  2,  2,  2,  0,  0,  3},
                {-2, -2,  1,  1,  1,  1, -2, -2},
                { 0,  0,  0,  0,  0,  0,  0,  0},
            };
            int queen[8][8] = {
                {-3, -3, -3, -3, -3, -3, -3, -3},
                {-3,  0,  0,  0,  0,  0,  0, -3},
                {-3,  0,  1,  1,  1,  0,  0, -3},
                {-3,  0,  3,  3,  3,  0,  0, -3},
                {-3,  0,  3,  3,  3,  0,  0, -3},
                {-3,  0,  1,  1,  1,  0,  0, -3},
                {-3,  0,  0,  0,  0,  0,  0, -3},
                {-3, -3, -3, -3, -3, -3, -3, -3},
            };

            if ([cell isKindOfClass: [NIPiece class]]) {
                result = result + [cell pieceValue] * [cell pieceColor];
                if ([cell isKindOfClass: [NIPawn class]]) {
                    if ([cell pieceColor] == WHITE) {
                        result = result + white_pawn[[[cell positionPoint] y] - 1][[[cell positionPoint] x] - 1];
                    }
                    if ([cell pieceColor] == BLACK) {
                        result = result - black_pawn[[[cell positionPoint] y] - 1][[[cell positionPoint] x] - 1];
                    }
                }
                if ([cell isKindOfClass: [NIQueen class]]) {
                    if ([cell pieceColor] == WHITE) {
                        result = result + queen[[[cell positionPoint] y] - 1][[[cell positionPoint] x] - 1];
                    }
                    if ([cell pieceColor] == BLACK) {
                        result = result - queen[[[cell positionPoint] y] - 1][[[cell positionPoint] x] - 1];
                    }
                }
            }
        }];
    }];
    return result * [position onMove];
}

- (BOOL)isOnChangePoint:(id)point piece:(id)piece
{
    if ([piece isKindOfClass: [NIPawn class]]) {
        if ([piece pieceColor] == WHITE && [point y] == 8) {
            return true;
        }
        if ([piece pieceColor] == BLACK && [point y] == 1) {
            return true;
        }
    }
    return false;
}

- (id)makeBorderBarrier:(id)board
{
    int i;
    id row;
    
    for (i = 0; i < [self boardSize]; i++) {
        row = [board rowAt:i];
        [row setCellAt: 0 on: [[NIBarrier alloc] init]];
        [row setCellAt: 9 on: [[NIBarrier alloc] init]];
        
    }
    [self makeTopBottomBarrier: [board rowAt: 0]];
    [self makeTopBottomBarrier: [board rowAt: 9]];
    return self;
}

- (id)makeTopBottomBarrier:(id)row
{
    int i;
    
    for (i = 0; i < [self boardSize]; i++) {
        [row setCellAt: i on: [[NIBarrier alloc] init]];
    }
    return self;
}

- (int)whoWinsOn:(id)position
{
    __block int white = 0;
    __block int black = 0;
    
    if ([position movesWithoutCaptures] > 30) {
        [[[position gameBoard] rows] enumerateObjectsUsingBlock:^(id row, NSUInteger idx, BOOL *stop) {
            [[row cells] enumerateObjectsUsingBlock:^(id cell, NSUInteger idx, BOOL *stop) {
                if ([cell isKindOfClass: [NIPiece class]] && [cell pieceColor] == WHITE) {
                    white++;
                }
                if ([cell isKindOfClass: [NIPiece class]] && [cell pieceColor] == BLACK) {
                    black++;
                }
            }];
        }];
        if (white == black) {
            return DRAW;
        }
        if (white > black) {
            return WHITE;
        } else {
            return BLACK;
        }
    }
    [[[position gameBoard] rows] enumerateObjectsUsingBlock:^(id row, NSUInteger idx, BOOL *stop) {
        [[row cells] enumerateObjectsUsingBlock:^(id cell, NSUInteger idx, BOOL *stop) {
            if ([cell isKindOfClass: [NIPiece class]] && [cell pieceColor] == WHITE) {
                white = white + [cell pieceValue];
            }
            if ([cell isKindOfClass: [NIPiece class]] && [cell pieceColor] == BLACK) {
                black = black + [cell pieceValue];
            }
        }];
    }];
    if (white == 0) {
        return BLACK;
    }
    if (black == 0) {
        return WHITE;
    }
    return CONTINUE;
}

- (BOOL)isWinningPosition:(id)position
{
    return [self whoWinsOn: position] * [position onMove] == 1;
}

- (BOOL)isLoosingPosition:(id)position
{
    return [self whoWinsOn: position] * [position onMove] == -1;
}

- (BOOL)isDrawPosition:(id)position
{
    return [self whoWinsOn: position] == DRAW;
}

@end
