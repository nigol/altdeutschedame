//
//  NIGameRules.m
//  Goth
//
//  Created by Martin Polák on 17.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NIGameRules.h"
#import "NIPiece.h"
#import "NIPawn.h"
#import "NIQueen.h"
#import "NIBarrier.h"
#import "NIGameBoard.h"
#import "NIGameBoardRow.h"
#import "NIPoint.h"
#import "NIMove.h"
#import "NIFreeCell.h"
#import "NIPosition.h"

@implementation NIGameRules

@synthesize boardSize;

- (id)init
{    
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (id)setInitialStateOn:(id)board
{
    [NSException raise: @"Not implemented" format: @"Should be implemented."];
    return self;
}

- (id)pieceMovesFor:(id)piece on:(id)board
{
    id moves = [[NSMutableArray alloc] init];
    id lines = [self pieceLinesFor: piece on: board];
    id captureLines = [[NSMutableArray alloc] init];
    
    captureLines = [self captureLinesFrom: lines with: piece on: board];
    if ([captureLines count] == 0) {
        return [self movesWithoutCapturesFrom: lines with: piece on: board];
    } else {
        return [self movesWithCapturesFrom: captureLines with: piece on: board];
    }
    return moves;
}

- (id)captureLinesFrom:(id)lines with:(id)piece on:(id)board
{
    __block id result = [[NSMutableArray alloc] init];
    
    [lines enumerateObjectsUsingBlock:^(id line, NSUInteger idx, BOOL *stop) {
        __block id cuttedLineAtBarrier = [self cutLineAtBarrier: line on: board];
        __block id cuttedLine = [self cutLine: cuttedLineAtBarrier atPieceColor: [piece pieceColor] on: board];
        
        [cuttedLine enumerateObjectsUsingBlock:^(id point, NSUInteger idx, BOOL *stop) {
            id obj = [board cellAtPoint: point];
            
            if ([line lastObject] != point && [obj isKindOfClass: [NIPiece class]] && [obj pieceColor] != [piece pieceColor] && [[board cellAtPoint: [line objectAtIndex: idx + 1]] isKindOfClass: [NIPiece class]]) {
                *stop = YES;
            }
            if ([line lastObject] != point && [obj isKindOfClass: [NIPiece class]] && [obj pieceColor] != [piece pieceColor] && [[board cellAtPoint: [line objectAtIndex: idx + 1]] isKindOfClass: [NIFreeCell class]]) {
                [result addObject: cuttedLine];
                *stop = YES;
            }
        }];
    }];
    return result;
}

- (id)movesWithoutCapturesFrom:(id)lines with:(id)piece on:(id)board
{
    __block id result = [[NSMutableArray alloc] init];
    
    [lines enumerateObjectsUsingBlock:^(id line, NSUInteger idx, BOOL *stop) {
        id start = [line objectAtIndex: 0];
        NSRange range;
        
        range.location = 1;
        range.length = [line count] - 2;
        [[line subarrayWithRange: range] enumerateObjectsUsingBlock:^(id point, NSUInteger idx, BOOL *stop) {
            id obj = [board cellAtPoint: point];
            id move = [[NIMove alloc] init];
            
            if ([obj isKindOfClass: [NIBarrier class]] || ([obj isKindOfClass: [NIPiece class]])) *stop = YES;
            if ([obj isKindOfClass: [NIFreeCell class]]) {
                [move addStep: start];
                [move addStep: point];
                if ([self isOnChangePoint: point piece: piece]) {
                    [move addChange: point];
                }
                [result addObject: move];
            }
        }];
    }];
    return result;
}

- (id)movesWithCapturesFrom:(id)lines with:(id)piece on:(id)board
{
    id result = [[NSMutableArray alloc] init];
    
    result = [self processPoint: [piece positionPoint] start: [piece positionPoint] on: [board mutableCopy] enemies: [[NSMutableArray alloc] init] result: result];
    return [self selectMovesWithMostCaptures: result];
}

- (id)processPoint:(id)point start:(id)startPoint on:(id)board enemies:(id)enemies result:(id)result
{
    id captureLines = [self pointCaptureLinesFor: point startPoint: startPoint on: board];
    
    if ([captureLines count] != 0) {
        [captureLines enumerateObjectsUsingBlock:^(id line, NSUInteger idx, BOOL *stop) {
            __block id es = [[NSMutableArray alloc] init];
            [es addObjectsFromArray: enemies];
            __block id lineFromEnemy = [self lineFromEnemy: line myColor: [board colorAtPoint: point] on: board];
            __block id lineAfterEnemy = [self lineAfterEnemy: lineFromEnemy on: board];
            id enemy = [self enemyPoint: lineFromEnemy];
            
            [board setCellAtPoint: enemy on: [[NIFreeCell alloc] init]];
            if ([self isCapturePointIn: lineAfterEnemy startPoint: startPoint on: board]) {
                [lineAfterEnemy enumerateObjectsUsingBlock:^(id pt, NSUInteger idx, BOOL *stop) {
                    [es addObject: enemy];
                    [board setCellAtPoint: enemy on: [[NIFreeCell alloc] init]];
                    [self processPoint: pt start: startPoint on: board enemies: es result: result];
                }];
            } else {
                [es addObject: enemy];
                [lineAfterEnemy enumerateObjectsUsingBlock:^(id pt, NSUInteger idx, BOOL *stop) {
                    id move = [[NIMove alloc] init];
                    
                    [move addStep: startPoint];
                    [move addStep: pt];
                    [move setCaptures: es];
                    if ([self isOnChangePoint: pt piece: [board cellAtPoint: startPoint]]) {
                        [move addChange: pt];
                    }
                    [result addObject: move];
                }];
            }
        }];
    }
    return result;
}

- (id)pointCaptureLinesFor:(id)point startPoint:(id)startPoint on:(id)board
{
    if ([[board cellAtPoint: point] isKindOfClass: [NIBarrier class]]) {
        return [[NSMutableArray alloc] init];
    } else {
        id cell = [board cellAtPoint: startPoint];
        
        [cell setPositionPoint: point];
        [board setCellAtPoint: point on: cell];
        if ([cell isKindOfClass: [NIPiece class]]) {
            return [self captureLinesFrom: [self pieceLinesFor: cell on: board] with: cell on: board];
        }
    }
    return [[NSMutableArray alloc] init];
}

- (id)lineFromEnemy:(id)line myColor:(int)myColor on:(id)board
{
    __block NSRange range;
    
    range.location = 1;
    range.length = [line count] - 2;
    [line enumerateObjectsUsingBlock:^(id point, NSUInteger idx, BOOL *stop) {
        if ((myColor * [board colorAtPoint: point]) == -1) {
            range.location = idx;
            range.length = [line count] - idx;
            *stop = YES;
        }
    }];
    return [line subarrayWithRange: range];
}

- (id)lineAfterEnemy:(id)lineFromEnemy on:(id)board
{
    NSRange range;
    
    range.location = 1;
    range.length = [lineFromEnemy count] - 1;
    return [self cutLineAtPiece: [lineFromEnemy subarrayWithRange: range] on: board];
}

- (id)enemyPoint:(id)lineFromEnemy
{
    return [lineFromEnemy objectAtIndex: 0];
}

- (BOOL)isCapturePointIn:(id)line startPoint:(id)startPoint on:(id)board
{
    __block BOOL result = false;
    
    [line enumerateObjectsUsingBlock:^(id point, NSUInteger idx, BOOL *stop) {
        if ([[self pointCaptureLinesFor: point startPoint: startPoint on: board] count] != 0) {
            result = true;
            *stop = YES;
        }
    }];
    return result;
}

- (id)pieceLinesFor:(id)piece on:(id)board
{
    [NSException raise: @"Not implemented" format: @"Should be implemented."];
    return self;
}

- (int)startingPlayer
{
    [NSException raise: @"Not implemented" format: @"Should be implemented."];
    return 0;
}

- (int)evaluatePosition:(id)position
{
    [NSException raise: @"Not implemented" format: @"Should be implemented."];
    return 0;
}

- (BOOL)isOnChangePoint:(id)point piece:(id)piece
{
    [NSException raise: @"Not implemented" format: @"Should be implemented."];
    return false;
}

- (id)cutLineAtBarrier:(id)line on:(id)board
{
    __block NSRange range;
    
    range.location = 0;
    range.length = [line count];
    [line enumerateObjectsUsingBlock:^(id point, NSUInteger idx, BOOL *stop) {
        if ([[board cellAtPoint: point] isKindOfClass: [NIBarrier class]]) {
            range.length = idx;
            *stop = YES;
        }
    }];
    return [line subarrayWithRange: range];
}

- (int)whoWinsOn:(id)position
{
    [NSException raise: @"Not implemented" format: @"Should be implemented."];
    return 0;
}

- (id)cutLine:(id)line atPieceColor:(int)color on:(id)board
{
    __block NSRange range;
    
    range.location = 0;
    range.length = [line count];
    [line enumerateObjectsUsingBlock:^(id point, NSUInteger idx, BOOL *stop) {
        id cell = [board cellAtPoint: point];
        if (idx != 0 && [cell isKindOfClass: [NIPiece class]] && [cell pieceColor] == color) {
            range.length = idx;
            *stop = YES;
        }
    }];
    return [line subarrayWithRange: range];
}

- (BOOL)isWinningPosition:(id)position
{
    [NSException raise: @"Not implemented" format: @"Should be implemented."];
    return false;
}

- (BOOL)isLoosingPosition:(id)position
{
    [NSException raise: @"Not implemented" format: @"Should be implemented."];
    return false;
}

- (BOOL)isDrawPosition:(id)position
{
    [NSException raise: @"Not implemented" format: @"Should be implemented."];
    return false;
}

- (id)cutLineAtPiece:(id)line on:(id)board
{
    __block NSRange range;
    
    range.location = 0;
    range.length = [line count];
    [line enumerateObjectsUsingBlock:^(id point, NSUInteger idx, BOOL *stop) {
        if ([[board cellAtPoint: point] isKindOfClass: [NIPiece class]]) {
            range.length = idx;
            *stop = YES;
        }
    }];
    return [line subarrayWithRange: range];
}

- (id)selectMovesWithMostCaptures:(id)moves
{
    __block id result = [[NSMutableArray alloc] init];
    __block int mostCaptures = 0;
    
    [moves enumerateObjectsUsingBlock:^(id move, NSUInteger idx, BOOL *stop) {
        if ([[move captures] count] > mostCaptures) {
            mostCaptures = (int) [[move captures] count];
        }
    }];
    [moves enumerateObjectsUsingBlock:^(id move, NSUInteger idx, BOOL *stop) {
        if ([[move captures] count] == mostCaptures) {
            [result addObject: move];
        }
    }];
    return result;
}

@end
