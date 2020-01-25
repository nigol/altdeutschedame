//
//  NIPiece.h
//  Goth
//
//  Created by Martin Polák on 17.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "constants.h"

@class NIGameRules, NIPoint;

@interface NIPiece : NSObject

@property(readwrite, assign) int pieceColor, pieceValue;
@property(readwrite, assign) id positionPoint;
@property(readwrite, assign) id rules;

- (id)setPositionX:(int)x y:(int)y;
- (id)movesOn:(id)board;

@end
