//
//  NIGameBoardRow.h
//  Goth
//
//  Created by Martin Polák on 23.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIBarrier, NIFreeCell, NIPiece;

@interface NIGameBoardRow : NSObject <NSMutableCopying>

@property(readwrite, assign) id cells;

- (id)initWithNumberOfCells:(int)number;
- (int)rowSize;
- (id)cellAt:(int)index;
- (id)setCellAt:(int)index on:(id)object;
- (id)movesOn:(id)board color:(int)color;

@end
