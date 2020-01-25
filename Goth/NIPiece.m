//
//  NIPiece.m
//  Goth
//
//  Created by Martin Polák on 17.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NIPiece.h"
#import "NIGameRules.h"
#import "NIPoint.h"

@implementation NIPiece

@synthesize positionPoint;
@synthesize pieceColor, pieceValue;
@synthesize rules;

- (id)init
{
    self = [super init];
    if (self) {
        [self setPositionPoint: [[NIPoint alloc] init]];
        // Initialization code here.
    }
    
    return self;
}

- (id)setPositionX:(int)x y:(int)y
{
    id pos = [[NIPoint alloc] init];
    
    [pos setX: x];
    [pos setY: y];
    [self setPositionPoint: pos];
    return self;
}

- (id)movesOn:(id)board
{
    return [[self rules] pieceMovesFor: self on: board];
}

@end
