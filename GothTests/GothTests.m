//
//  GothTests.m
//  GothTests
//
//  Created by Martin Polák on 17.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GothTests.h"
#import "NIGothicCheckersRules.h"
#import "NIGameBoard.h"
#import "NIGameBoardRow.h"

@implementation GothTests

id gameRules, gameBoard, boardRow;

- (void)setUp
{
    [super setUp];
    gameRules = [[NIGothicCheckersRules alloc] init];
    gameBoard = [[NIGameBoard alloc] init];
    boardRow = [[NIGameBoardRow alloc] initWithNumberOfCells: 10];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    [gameRules release];
    [gameBoard release];
    [boardRow release];
    
    [super tearDown];
}

- (void)testExample
{
    //STFail(@"Unit tests are not implemented yet in GothTests");
}

- (void)testBoardSize
{
    STAssertEquals(10, [gameRules boardSize], @"Board size should be 10.");
}

- (void)testKindOfRules
{
    id r = [gameBoard rules];
    STAssertTrue([r isKindOfClass: [NIGothicCheckersRules class]], @"Should be an instance of NIGothicCheckersRules.");
}

- (void)testNumberOfBoardRowCells
{
    STAssertEquals(10, [[gameBoard rowAt: 0] rowSize], @"rowSize is %d.", [[gameBoard rowAt: 0] rowSize]);
}

- (void)testNumberOfBoardRows
{
    STAssertEquals(10, [gameBoard numberOfBoardRows], @"Should be 10.");
}

- (void)printCellAtX:(int)x Y:(int)y
{
    id cell;
    char c;
    
    cell = [gameBoard cellAtX: x y: y];
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
            c = '.';
        }
    }
    printf("%c", c);
}

- (void)testPrintBoard
{
    int i, j;
    
    for (i = [gameRules boardSize] - 1; i > -1; i--) {
        printf("\n%d", i);
        for (j = 0; j < [gameRules boardSize]; j++) {
            [self printCellAtX: j Y: i];
        }
    }
    printf("\n\n");
}

- (void)testCopyBoard
{
    id bo = [gameBoard mutableCopy];
    
    [bo setCellAtX: 4 y: 4 on: [[NIBarrier alloc] init]];
    gameBoard = bo;
    [self testPrintBoard];
}

- (void)testIsCapturePossible
{
    id lines = [[NSMutableArray alloc] init];
    id point = [[NIPoint alloc] init];
    id pawn, o_pawn;
    id position;
    
    [point setX: 1];
    [point setY: 2];
    pawn = [gameBoard cellAtPoint: point];
    position = [pawn positionPoint];
    [lines addObject: [position lineLength: 3 xStep: -1 yStep: 0]];
    [lines addObject: [position lineLength: 3 xStep: 1 yStep: 0]];
    [lines addObject: [position lineLength: 3 xStep: -1 yStep: [pawn pieceColor]]];
    [lines addObject: [position lineLength: 3 xStep: 0 yStep: [pawn pieceColor]]];
    [lines addObject: [position lineLength: 3 xStep: 1 yStep: [pawn pieceColor]]];
    STAssertTrue([[gameRules captureLinesFrom: lines with: pawn on: gameBoard] count] == 0, @"Should be 0.");
    o_pawn = [[NIPawn alloc] init];
    [o_pawn setPieceColor: BLACK];
    [gameBoard setCellAtX: 1 y: 3 on: o_pawn];
    [self testPrintBoard];
    STAssertTrue([[gameRules getCaptureLinesFrom: lines with: pawn on: gameBoard] count] == 1, @"Should be 1.");
}

- (void)testPawnMovesWithoutCaptures
{
    id lines = [[NSMutableArray alloc] init];
    id point = [[NIPoint alloc] init];
    id pawn;
    id position;
    
    [point setX: 1];
    [point setY: 2];
    pawn = [gameBoard cellAtPoint: point];
    position = [pawn positionPoint];
    [lines addObject: [position lineLength: 3 xStep: -1 yStep: 0]];
    [lines addObject: [position lineLength: 3 xStep: 1 yStep: 0]];
    [lines addObject: [position lineLength: 3 xStep: -1 yStep: [pawn pieceColor]]];
    [lines addObject: [position lineLength: 3 xStep: 0 yStep: [pawn pieceColor]]];
    [lines addObject: [position lineLength: 3 xStep: 1 yStep: [pawn pieceColor]]];
    STAssertTrue([[gameRules movesWithoutCapturesFrom: lines with: pawn on: gameBoard] count] == 2, @"Should be 2.");
}

@end
