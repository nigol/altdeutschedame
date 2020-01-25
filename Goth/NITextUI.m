//
//  NITextUI.m
//  Goth
//
//  Created by Martin Polák on 19.11.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NITextUI.h"
#import "NIGameBoard.h"
#import "NIGameControl.h"
#import "NIPiece.h"
#import "NIGameRules.h"
#import "NIMove.h"
#import "NIPoint.h"
#import "NIBarrier.h"
#import "NIPawn.h"
#import "NIQueen.h"

@implementation NITextUI

@synthesize gameControl;

- (id)init
{
    self = [super init];
    if (self) {
        [self setGameControl: [[NIGameControl alloc] init]];
    }
    
    return self;
}

- (id)loop
{
    id move;
    BOOL run = true;
    
    while (run) {
        [self displayGameBoard: [[self gameControl] gameBoard]];
        [self printPlayerOnMove];
        if ([[self gameControl] isPlayerOnMoveComputer]) {
            [[self gameControl] performComputerMove];
        } else {
            @try {
                move = [self askForMove];
                [self printGivenMove: move];
                [[self gameControl] proceedWithMove: move];
            }
            @catch (NSException *exception) {
                printf("%s\n", [[exception reason] UTF8String]);
            }
            @finally {
                
            }
        }
        run = [self discoverSituationOn: [[self gameControl] gameBoard]];
    }
    return self;
}

- (id)displayGameBoard:(id)board
{
    int i, j;
    
    for (i = [board numberOfBoardRows] - 2; i > 0; i--) {
        printf("\n%d", i);
        for (j = 1; j < [board numberOfBoardRows] - 1; j++) {
            [self printCellAtX: j y: i of: board];
        }
    }
    printf("\n abcdefgh");
    printf("\n\n");
    return self;
}

- (id)printCellAtX:(int)x y:(int)y of:(id)board
{
    id cell;
    char c;
    
    cell = [board cellAtX: x y: y];
    if ([cell isKindOfClass: [NIBarrier class]]) {
        c = '#';
    } else {
        if ([cell isKindOfClass: [NIPawn class]]) {
            if ([cell pieceColor] == BLACK) {
                c = 'b';
            } else {
                c = 'w';
            }
        } else {
            if ([cell isKindOfClass: [NIQueen class]]) {
                if ([cell pieceColor] == BLACK) {
                    c = 'B';
                } else {
                    c = 'W';
                }
            } else {
                c = '.';
            }
        }
    }
    printf("%c", c);
    return self;
}

- (id)askForMove
{
    id move = [[NIMove alloc] init];
    
    [move addStep: [self askFrom]];
    [self printHintFor: [move firstStep]];
    [move addStep: [self askTo]];
    return move;
}

- (id)askFrom
{
    id point = [[NIPoint alloc] init];
    char x;
    int y;
    
    printf("From: ");
    scanf("%c%c%d", &x, &x, &y);
    [point setX: ltoi(x)];
    [point setY: y];
    return point;
}

- (id)askTo
{
    id point = [[NIPoint alloc] init];
    char x;
    int y;
    
    printf("To: ");
    scanf("%c%c%d", &x, &x, &y);
    [point setX: ltoi(x)];
    [point setY: y];
    return point;
}

- (id)printGivenMove:(id)move
{
    [[move steps] enumerateObjectsUsingBlock:^(id point, NSUInteger idx, BOOL *stop) {
        printf("%c%d ", (char)itol([point x]), [point y]);
    }];
    return self;
}

- (id)printPlayerOnMove
{
    if ([[self gameControl] playerOnMove] == WHITE) {
        printf("WHITE on move.\n");
    } else {
        printf("BLACK on move.\n");
    }
    return self;
}

- (id)printHintFor:(id)point
{
    id hint = [[self gameControl] hintFor: point];
    
    [hint enumerateObjectsUsingBlock:^(id move, NSUInteger idx, BOOL *stop) {
        [self printGivenMove: move];
        printf(" | ");
    }];
    return self;
}

- (id)setUp
{
    int input;
    
    printf("\n\n*Altdeutsche Dame*\n\nPlease select...\n");
    printf("WHITE player is: (1) Human or (2) Computer? ");
    scanf("%d", &input);
    [[self gameControl] player: WHITE is: input];
    if ([[self gameControl] isComputerPlayer: WHITE]) {
        printf("Enter WHITE player's level (1, 2 or 3): ");
        scanf("%d", &input);
        [[self gameControl] setComputerPlayerLevel: input on: WHITE];
    }
    printf("BLACK player is: (1) Human or (2) Computer? ");
    scanf("%d", &input);
    [[self gameControl] player: BLACK is: input];
    if ([[self gameControl] isComputerPlayer: BLACK]) {
        printf("Enter BLACK player's level (1, 2 or 3): ");
        scanf("%d", &input);
        [[self gameControl] setComputerPlayerLevel: input on: BLACK];
    }
    return self;
}

- (id)printAllMovesOn:(id)board
{
    id moves = [board movesFor: [gameControl playerOnMove]];
    
    [moves enumerateObjectsUsingBlock:^(id move, NSUInteger idx, BOOL *stop) {
        [self printGivenMove: move];
        printf(" | ");
    }];
    return self;
}

- (BOOL)discoverSituationOn:(id)board
{
    int result = [[self gameControl] stateOfGame: board];
    
    if (result == (WHITE)) {
        printf("WHITE player wins.\n");
        [self displayGameBoard: [[self gameControl] gameBoard]];
        return false;
    }
    if (result == (BLACK)) {
        printf("BLACK player wins.\n");
        [self displayGameBoard: [[self gameControl] gameBoard]];
        return false;
    }
    if (result == DRAW) {
        printf("Draw game.\n");
        [self displayGameBoard: [[self gameControl] gameBoard]];
        return false;
    }
    return true;
}

@end
