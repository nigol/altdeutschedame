//
//  NIPosition.h
//  Goth
//
//  Created by Martin Polák on 31.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIPiece, NIGameBoard;

@interface NIPosition : NSObject

@property(readwrite, assign) id gameBoard, createdByMove;
@property(readwrite, assign) int onMove, movesWithoutCaptures;

- (id)togglePlayerOnMove;
- (id)performMove:(id)move;
- (NSString *)asString;

@end
