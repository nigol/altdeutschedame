//
//  NIQueen.m
//  Goth
//
//  Created by Martin Polák on 17.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NIQueen.h"

@implementation NIQueen

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        [self setPieceValue: 50];
    }
    
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    id copy = [[NIQueen allocWithZone: zone] init];
    
    [copy setPieceColor: [self pieceColor]];
    [copy setPieceValue: [self pieceValue]];
    [copy setPositionPoint: [self positionPoint]];
    [copy setRules: [self rules]];
    return copy;
}

@end
