//
//  NIPosition.m
//  Goth
//
//  Created by Martin Polák on 31.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NIPosition.h"
#import "NIPiece.h"
#import "NIGameBoard.h"

@implementation NIPosition

@synthesize gameBoard, onMove, createdByMove, movesWithoutCaptures;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)togglePlayerOnMove
{
    [self setOnMove: ([self onMove] * -1)];
    return self;
}

- (id)performMove:(id)move
{
    [[self gameBoard] performMove: move];
    [self togglePlayerOnMove];
    return self;
}

- (NSString *)asString
{
    return [[self createdByMove] asString];
}

@end
