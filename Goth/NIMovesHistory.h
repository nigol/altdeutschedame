//
//  NIMovesHistory.h
//  Goth
//
//  Created by Martin Polák on 25.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "constants.h"

@class NIPosition;

@interface NIMovesHistory : NSObject <NSTableViewDataSource>

@property(readwrite, assign) NSMutableArray *history;
@property(readwrite, assign) int selected;

- (void)add:(NIPosition *)position;
- (NIPosition *)retrievePositionAt:(int)index;

@end
