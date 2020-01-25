//
//  NIGameBoardRow.m
//  Goth
//
//  Created by Martin Polák on 23.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NIGameBoardRow.h"
#import "NIBarrier.h"
#import "NIFreeCell.h"
#import "NIPiece.h"

@implementation NIGameBoardRow

@synthesize cells;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        [self setCells: [[NSMutableArray alloc] init]];
    }
    
    return self;
}

- (id)initWithNumberOfCells:(int)number
{
    int i;
    
    [self init];
    for (i = 0; i < number; i++) {
        [[self cells] addObject: [[NIFreeCell alloc] init]];
    }
    return self;
}

- (int)rowSize
{
    return (int)[[self cells] count];
}

- (id)cellAt:(int)index
{
    return [[self cells] objectAtIndex: index];
}

- (id)setCellAt:(int)index on:(id)object
{
    [[self cells] replaceObjectAtIndex: index withObject: object];
    return self;
}

- (id)movesOn:(id)board color:(int)color
{
    id moves = [[NSMutableArray alloc] init];
    
    [[self cells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass: [NIPiece class]] && ([obj pieceColor] == color)) {
            [moves addObjectsFromArray: [obj movesOn: board]];
        }
    }];
    return moves;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    id copy = [[NIGameBoardRow allocWithZone: zone] init];
    id cs = [[NSMutableArray alloc] init];
    
    [[self cells] enumerateObjectsUsingBlock:^(id cell, NSUInteger idx, BOOL *stop) {
        [cs addObject: [cell mutableCopy]];
    }];
    [copy setCells: cs];
    return copy;
}

@end
