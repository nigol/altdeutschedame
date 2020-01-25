//
//  NIOnMoveComponent.h
//  Goth
//
//  Created by Martin Polák on 29.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NIGameControl;

@interface NIOnMoveComponent : NSView

@property (assign, readwrite) int whoIsOnMove;
@property (assign, readwrite) BOOL isComputer;

- (void)notify:(NSNotification *)notification;
- (void)drawSign:(NSRect)rect;

@end
