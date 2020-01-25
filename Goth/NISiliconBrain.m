//
//  NISiliconBrain.m
//  Goth
//
//  Created by Martin Polák on 05.12.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NISiliconBrain.h"
#import "NIGameBoard.h"
#import "NIPosition.h"
#import "NIGameRules.h"
#import "NITextUI.h"
#import "NIMove.h"

@implementation NISiliconBrain

@synthesize rules;
@synthesize paused;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        [self setPaused: NO];
    }
    
    return self;
}

- (id)positionsFrom:(id)position
{
    __block id result = [[NSMutableArray alloc] init];
        
    [[[position gameBoard] movesFor: [position onMove]] enumerateObjectsUsingBlock:^(id move, NSUInteger idx, BOOL *stop) {
        id pos = [[NIPosition alloc] init];
        
        [pos setGameBoard: [[position gameBoard] mutableCopy]];
        [[pos gameBoard] performMove: move];
        [pos setCreatedByMove: move];
        [pos setOnMove: ([position onMove] * -1)];
        if ([[move captures] count] == 0) {
            [pos setMovesWithoutCaptures: [pos movesWithoutCaptures] + 1];
        } else {
            [pos setMovesWithoutCaptures: 0];
        }
        [result addObject: pos];
    }];
    return result;
}

- (int)minimaxForPosition:(id)position depth:(int)depth
{
    __block int evaluated = -MAXIMUM;
    
    if ([[self rules] isWinningPosition: position]) {
        return MAXIMUM;
    }
    if ([[self rules] isLoosingPosition: position]) {
        return -MAXIMUM;
    }
    if ([[self rules] isDrawPosition: position]) {
        return 0;
    }
    if (depth == 0) {
        return ([[self rules] evaluatePosition: position]);
    } else {
        [[self positionsFrom: position] enumerateObjectsUsingBlock:^(id pos, NSUInteger idx, BOOL *stop) {
            if ([self paused]) {
                [NSException raise: @"Game paused" format: @"Game was paused."];
            } else {
                evaluated = MAX(evaluated, (-1 * [self minimaxForPosition: pos depth: (depth - 1)]));
            }
        }];
    }
    if (evaluated > TOO_MUCH) {
        evaluated--;
    }
    if (evaluated < -TOO_MUCH) {
        evaluated++;
    }
    return evaluated;
}

- (id)bestMoveForPosition:(id)position depth:(int)depth
{
    __block int bestEvaluation = -MAXIMUM;
    __block id bestMove;
    
    [[self positionsFrom: position] enumerateObjectsUsingBlock:^(id pos, NSUInteger idx, BOOL *stop) {
        int evaluation;
        
        @try {
            evaluation = (-1 * [self minimaxForPosition: pos depth: (depth - 1)]);
        }
        @catch (NSException *exception) {
            bestMove = [[NIMove alloc] init];
            *stop = YES;
        }
        if (evaluation > bestEvaluation) {
            bestEvaluation = evaluation;
            bestMove = [pos createdByMove];
        }
    }];
    return bestMove;
}

@end
