//
//  NIGameBoard.m
//  Goth
//
//  Created by Martin Polák on 17.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NIGameBoard.h"
#import "NIGameRules.h"
#import "NIGothicCheckersRules.h"
#import "NIGameBoardRow.h"
#import "NIPiece.h"
#import "NIMove.h"
#import "NIPoint.h"
#import "NIFreeCell.h"
#import "NIQueen.h"

@implementation NIGameBoard

@synthesize rules, rows;

- (id)init
{
    int i;
    
    self = [super init];
    if (self) {
        [self setRules: [[NIGothicCheckersRules alloc] init]];
        [self setRows: [[NSMutableArray alloc] init]];
        for (i = 0; i < [[self rules] boardSize]; i++) {
            [[self rows] addObject: [[NIGameBoardRow alloc] initWithNumberOfCells: [[self rules] boardSize]]];
        }
        [[self rules] setInitialStateOn: self];
    }
    
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    id copy = [[NIGameBoard allocWithZone: zone] init];
    id rs = [[NSMutableArray alloc] init];
    
    [copy setRules: [self rules]];
    [[self rows] enumerateObjectsUsingBlock:^(id row, NSUInteger idx, BOOL *stop) {
        [rs addObject: [row mutableCopy]];
    }];
    [copy setRows: rs];
    return copy;
}

- (int)numberOfBoardRows
{
    return (int)[[self rows] count];
}

- (id)rowAt:(int)index
{
    return [[self rows] objectAtIndex: index];
}

- (id)cellAtX:(int)x y:(int)y
{
    return [[self rowAt: y] cellAt: x];
}

- (id)setCellAtX:(int)x y:(int)y on:(id)object
{
    [[self rowAt: y] setCellAt: x on: object];
    return self;
}

- (id)moves
{
    id moves = [[NSMutableArray alloc] init];
    id captureMoves = [[NSMutableArray alloc] init];;
    
    [[self rows] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [moves addObjectsFromArray: [obj movesOn: self]];
    }];
    [moves enumerateObjectsUsingBlock:^(id move, NSUInteger idx, BOOL *stop) {
        if ([move isCaptures]) {
            [captureMoves addObject: move];
        }
    }];
    if ([captureMoves count] == 0) {
        return moves;
    } else {
        return captureMoves;
    }
}

- (id)cellAtPoint:(id)point
{
    return [self cellAtX: [point x] y: [point y]];
}

- (id)setCellAtPoint:(id)point on:(id)object
{
    [[self rowAt: [point y]] setCellAt: [point x] on: object];
    return self;
}

- (id)performMove:(id)move
{
    id obj = [self cellAtPoint: [move firstStep]];
    
    if ([obj isKindOfClass: [NIPiece class]]) {
        [self setCellAtPoint: [move firstStep] on: [[NIFreeCell alloc] init]];
        [obj setPositionPoint: [move lastStep]];
        [self setCellAtPoint: [move lastStep] on: obj];
    }
    [[move captures] enumerateObjectsUsingBlock:^(id point, NSUInteger idx, BOOL *stop) {
        [self setCellAtPoint: point on: [[NIFreeCell alloc] init]];
    }];
    [[move changes] enumerateObjectsUsingBlock:^(id point, NSUInteger idx, BOOL *stop) {
        id queen = [[NIQueen alloc] init];
        
        [queen setPieceColor: [obj pieceColor]];
        [queen setPositionPoint: point];
        [queen setRules: [obj rules]];
        [self setCellAtPoint: point on: queen];
    }];
    return self;
}

- (int)colorAtPoint:(id)point
{
    id cell = [self cellAtPoint: point];
    
    if ([cell isKindOfClass: [NIPiece class]]) {
        return [cell pieceColor];
    } else {
        return 0;
    }
}

- (id)movesFor:(int)color
{
    __block id moves = [[NSMutableArray alloc] init];
    __block id captureMoves = [[NSMutableArray alloc] init];
    __block id capMov = [[NSMutableArray alloc] init];
    __block int maxCaptures = 0;
    
    [[self rows] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id mvs = [obj movesOn: self color: color];
        
        [mvs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isCaptures]) {
                [captureMoves addObject: obj];
                if ([obj capturesCount] > maxCaptures) {
                    maxCaptures = [obj capturesCount];
                }
            } else {
                [moves addObject: obj];
            }
        }];
    }];
    if ([captureMoves count] == 0) {
        return moves;
    } else {
        [captureMoves enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj capturesCount] == maxCaptures) {
                [capMov addObject: obj];
            }
        }];
        return capMov;
    }
}

@end
