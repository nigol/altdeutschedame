//
//  NIGameControl.h
//  Goth
//
//  Created by Martin Polák on 19.11.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "constants.h"

@class NIGothicCheckersRules, NIGameRules, NIGameBoard, NIMove, NIPiece, NIPoint, NISiliconBrain;
@class NIPosition, NIMovesHistory;

@interface NIGameControl : NSObject {
}

@property(readwrite, assign) id gameRules, gameBoard, brain, history;
@property(readwrite, assign) int playerOnMove, white, black, movesWithoutCaptures;
@property(readwrite, assign) NSURL *filename;

- (id)togglePlayerOnMove;
- (id)proceedWithMove:(id)move;
- (id)hintFor:(id)point;
- (id)player:(int)player is:(int)compOrHuman;
- (BOOL)isComputerPlayer:(int)player;
- (BOOL)isPlayerOnMoveComputer;
- (id)performComputerMove;
- (BOOL)stateOfGame:(id)board;
- (id)setComputerPlayerLevel:(int)level on:(int)player;
- (id)addToHistory:(id)move;
- (id)stateAsPosition;
- (NSMutableArray *)movesForPlayerOnMove;
- (void)stateFromPosition:(NIPosition *)position;
- (id)bestMoveWith:(int)depth;
- (void)saveGame;
- (BOOL)writeToFile:(NSURL *)filename;
- (NSData *)createXMLData;
- (NSXMLElement *)createMoveNode:(NIMove *)move;
- (NSXMLElement *)createPointNode:(NIPoint *)point;
- (void)loadGame:(NSURL *)url;
- (void)parseLoadedGame:(NSXMLDocument *)xmlDoc;
- (void)parseMovesHistory:(NSArray *)his withBackPosition:(NIPosition *)bakPos andBackHistory:(NIMovesHistory *)bakHis;
- (void)togglePlayerOnMoveWithNotify:(BOOL)notify;
- (void)proceedWithMove:(id)move doNotify:(BOOL)notify;

@end
