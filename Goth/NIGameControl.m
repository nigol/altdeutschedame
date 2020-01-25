//
//  NIGameControl.m
//  Goth
//
//  Created by Martin Polák on 19.11.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NIGameControl.h"
#import "NIGameRules.h"
#import "NIGothicCheckersRules.h"
#import "NIGameBoard.h"
#import "NIMove.h"
#import "NIPiece.h"
#import "NIPoint.h"
#import "NISiliconBrain.h"
#import "NIPosition.h"
#import "NIMovesHistory.h"

@implementation NIGameControl

@synthesize gameBoard, gameRules, playerOnMove, white, black, brain, history, movesWithoutCaptures;
@synthesize filename;

- (id)init
{
    id b;
    
    
    self = [super init];
    if (self) {
        [self setGameBoard: [[NIGameBoard alloc] init]];
        [self setGameRules: [[NIGothicCheckersRules alloc] init]];
        [self setPlayerOnMove: [[self gameRules] startingPlayer]];
        b = [[NISiliconBrain alloc] init];
        [b setRules: [self gameRules]];
        [self setBrain: b];
        [self setHistory: [[NIMovesHistory alloc] init]];
        [self setMovesWithoutCaptures: 1];
    }
    return self;
}

- (id)togglePlayerOnMove
{
    [self togglePlayerOnMoveWithNotify: YES];
    return self;
}

- (id)proceedWithMove:(id)move
{
    [self proceedWithMove: move doNotify: YES];
    return self;
}

- (id)hintFor:(id)point
{
    id object = [[self gameBoard] cellAtPoint: point];
    
    if ([object isKindOfClass: [NIPiece class]] && [object pieceColor] == [self playerOnMove]) {
        return [object movesOn: [self gameBoard]];
    } else {
        [NSException raise: @"Illegal move" format: @"You must play only with your pieces."];
        return self;
    }
}

- (id)player:(int)player is:(int)compOrHuman
{
    if (player == WHITE) {
        [self setWhite: compOrHuman];
    } else {
        [self setBlack: compOrHuman];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName: @"changedOnMove" object: self];
    return self;
}

- (BOOL)isComputerPlayer:(int)player
{
    if (player == WHITE) {
        return ([self white] != HUMAN);
    } else {
        return ([self black] != HUMAN);
    }
}

- (BOOL)isPlayerOnMoveComputer
{
    return [self isComputerPlayer: [self playerOnMove]];
}

- (id)performComputerMove
{
    id moveToPerform;
    
    if ([self playerOnMove] == WHITE) {
        moveToPerform = [self bestMoveWith: [self white] - COMPUTER];
        if ([moveToPerform isEmpty]) {
            if (![[self brain] paused]) [self togglePlayerOnMove];
            return self;
        } else {
            [[self gameBoard] performMove: moveToPerform];
        }
    } else {
        moveToPerform = [self bestMoveWith: [self black] - COMPUTER];
        if ([moveToPerform isEmpty]) {
            if (![[self brain] paused]) [self togglePlayerOnMove];
            return self;
        } else {
            [[self gameBoard] performMove: moveToPerform];
        }
    }
    [self togglePlayerOnMove];
    [self addToHistory: moveToPerform];
    return self;
}

- (BOOL)stateOfGame:(id)board
{
    id pos = [self stateAsPosition];
    
    return [[self gameRules] whoWinsOn: pos];
}

- (id)setComputerPlayerLevel:(int)level on:(int)player
{
    if (player == WHITE) {
        [self setWhite: [self white] + level];
    } else {
        [self setBlack: [self black] + level];
    }
    return self;
}

- (id)addToHistory:(id)move
{
    if ([[move captures] count] == 0) {
        [self setMovesWithoutCaptures: [self movesWithoutCaptures] + 1];
    } else {
        [self setMovesWithoutCaptures: 1];
    }
    id pos = [self stateAsPosition];
    [pos setCreatedByMove: move];
    [[self history] add: pos];
    return self;
}

- (id)stateAsPosition
{
    id pos = [[NIPosition alloc] init];
    
    [pos setGameBoard: [[self gameBoard] mutableCopy]];
    [pos setOnMove: [self playerOnMove]];
    [pos setMovesWithoutCaptures: [self movesWithoutCaptures]];
    return pos;
}

- (NSMutableArray *)movesForPlayerOnMove
{
    return [[self gameBoard] movesFor: [self playerOnMove]];
}

- (void)stateFromPosition:(NIPosition *)position
{
    [self setGameBoard: [[position gameBoard] mutableCopy]];
    [self setPlayerOnMove: [position onMove]];
    [self setMovesWithoutCaptures: [position movesWithoutCaptures]];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"changedOnMove" object: self];
}

- (id)bestMoveWith:(int)depth
{
    return [[self brain] bestMoveForPosition: [self stateAsPosition] depth: depth];
}

- (void)saveGame
{
    if (![self writeToFile: [self filename]]) {
        [NSException raise: @"Saving error" format: @"Error writing file."];
    }
}

- (BOOL)writeToFile:(NSURL *)URL
{
    if (![[self createXMLData] writeToURL: URL atomically:YES]) {
        return NO;
    }
    return YES;
}

- (NSData *)createXMLData
{
    NSXMLElement *root = [[NSXMLElement alloc] initWithName: XML_ROOT];
    NSXMLElement *w = [[NSXMLElement alloc] initWithName: XML_WHITE stringValue: [NSString stringWithFormat: @"%d", [self white]]];
    NSXMLElement *b = [[NSXMLElement alloc] initWithName: XML_BLACK stringValue: [NSString stringWithFormat: @"%d", [self black]]];
    NSXMLElement *his = [[NSXMLElement alloc] initWithName: XML_HISTORY];
    NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithRootElement: root];
    
    [xmlDoc setVersion: XML_VERSION];
    [xmlDoc setCharacterEncoding: XML_ENCODING];
    [root addChild: w];
    [root addChild: b];
    [root addChild: his];
    [[[self history] history] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [his addChild: [self createMoveNode: [obj createdByMove]]];
    }];
    return [xmlDoc XMLDataWithOptions: NSXMLNodePrettyPrint];
}

- (NSXMLElement *)createMoveNode:(NIMove *)move
{
    NSXMLElement *mv = [[NSXMLElement alloc] initWithName: XML_MOVE];
    NSXMLElement *first = [[NSXMLElement alloc] initWithName: XML_FIRST_STEP];
    [first addChild: [self createPointNode: [move firstStep]]];
    [mv addChild: first];
    NSXMLElement *last = [[NSXMLElement alloc] initWithName: XML_LAST_STEP];
    [last addChild: [self createPointNode: [move lastStep]]];
    [mv addChild: last];
    return  mv;
}

- (NSXMLElement *)createPointNode:(NIPoint *)point
{
    NSXMLElement *pt = [[NSXMLElement alloc] initWithName: XML_POINT];
    NSXMLElement *x = [[NSXMLElement alloc] initWithName: XML_X stringValue: [NSString stringWithFormat: @"%d", [point x]]];
    [pt addChild: x];
    NSXMLElement *y = [[NSXMLElement alloc] initWithName: XML_Y stringValue: [NSString stringWithFormat: @"%d", [point y]]];
    [pt addChild: y];
    return  pt;
}

- (void)loadGame:(NSURL *)url
{
    NSXMLDocument *xmlDoc;
    NSError *err = nil;
    
    xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL: url options: (NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA) error: &err];
    if (xmlDoc == nil) {
        [NSException raise: @"Loading error" format: @"Error reading file."];
    }
    @try {
        [self parseLoadedGame: xmlDoc];
    }
    @catch (NSException *exception) {
        @throw;
    }
}

- (void)parseLoadedGame:(NSXMLDocument *)xmlDoc
{
    NIPosition *backupPosition = [self stateAsPosition];
    NIMovesHistory *backupHistory = [self history];
    
    [[self gameBoard] init];
    [self setPlayerOnMove: [[self gameRules] startingPlayer]];
    [self setHistory: [[NIMovesHistory alloc] init]];
    [self setMovesWithoutCaptures: 1];
    NSXMLNode *root = [xmlDoc rootElement];
    if (![[root name] isEqualToString: XML_ROOT]) {
        [self stateFromPosition: backupPosition];
        [self setHistory: backupHistory];
        [NSException raise: @"Loading error" format: @"Error reading file."];
    }
    [[root children] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([[obj name] isEqualToString: XML_WHITE]) {
            [self setWhite: [[obj stringValue] intValue]];            
        }
        if ([[obj name] isEqualToString: XML_BLACK]) {
            [self setBlack: [[obj stringValue] intValue]];            
        }
        if ([[obj name] isEqualToString: XML_HISTORY]) {
            @try {
                [self parseMovesHistory: [obj children] withBackPosition: backupPosition andBackHistory:backupHistory];
            }
            @catch (NSException *exception) {
                @throw;
            }
        }
    }];
}

- (void)setWhite:(int)w
{
    if (w < 1 || w > 5) {
        white = 1;
    } else {
        white = w;
    }
}

- (void)setBlack:(int)b
{
    if (b < 1 || b > 5) {
        black = 1;
    } else {
        black = b;
    }
}

- (void)parseMovesHistory:(NSArray *)his withBackPosition:(NIPosition *)bakPos andBackHistory:(NIMovesHistory *)bakHis
{    
    [his enumerateObjectsUsingBlock:^(id m, NSUInteger idx, BOOL *stop) {
        NIMove *mov = [[NIMove alloc] init];
        __block NSXMLNode *pt;
        NIPoint *fStep = [[NIPoint alloc] init];
        NIPoint *lStep = [[NIPoint alloc] init];
        if (![[m name] isEqualToString: XML_MOVE]) {
            [self stateFromPosition: bakPos];
            [self setHistory: bakHis];
            [NSException raise: @"Loading error" format: @"Error reading file."];
        }
        [[m children] enumerateObjectsUsingBlock:^(id s, NSUInteger idx, BOOL *stop) {
            if ([[s name] isEqualToString: XML_FIRST_STEP]) {
                pt = [s nextNode];
                [[pt children] enumerateObjectsUsingBlock:^(id c, NSUInteger idx, BOOL *stop) {
                    if ([[c name] isEqualToString: XML_X]) {
                        [fStep setX: [[c stringValue] intValue]];            
                    }
                    if ([[c name] isEqualToString: XML_Y]) {
                        [fStep setY: [[c stringValue] intValue]];            
                    }
                }];
            }
            if ([[s name] isEqualToString: XML_LAST_STEP]) {
                pt = [s nextNode];
                [[pt children] enumerateObjectsUsingBlock:^(id c, NSUInteger idx, BOOL *stop) {
                    if ([[c name] isEqualToString: XML_X]) {
                        [lStep setX: [[c stringValue] intValue]];            
                    }
                    if ([[c name] isEqualToString: XML_Y]) {
                        [lStep setY: [[c stringValue] intValue]];            
                    }
                }];
            }
        }];
        [mov addStep: fStep];
        [mov addStep: lStep];
        @try {
            [self proceedWithMove: mov doNotify: NO];
        }
        @catch (NSException *exception) {
            @throw;
        }
    }];
}

- (void)togglePlayerOnMoveWithNotify:(BOOL)notify
{
    [self setPlayerOnMove: ([self playerOnMove] * -1)];
    if (notify) {
        [[NSNotificationCenter defaultCenter] postNotificationName: @"changedOnMove" object: self];
    }
}

- (void)proceedWithMove:(id)move doNotify:(BOOL)notify
{
    __block BOOL isAllowed = false;
    __block id moveToPerform;
    
    [[self movesForPlayerOnMove] enumerateObjectsUsingBlock:^(id mv, NSUInteger idx, BOOL *stop) {
        if ([mv isEqualToMove: move]) {
            [self hintFor: [move firstStep]];
            moveToPerform = mv;
            isAllowed = true;
            *stop = YES;
        }
    }];
    if (isAllowed) {
        [[self gameBoard] performMove: moveToPerform];
        [self togglePlayerOnMoveWithNotify: notify];
    } else {
        [NSException raise: @"Illegal move" format: @"This move is not allowed."];
    }
    [self addToHistory: moveToPerform];
}

@end