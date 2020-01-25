//
//  NIOnMoveComponent.m
//  Goth
//
//  Created by Martin Polák on 29.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NIOnMoveComponent.h"
#import "NIBoardComponent.h"
#import "NIPiece.h"
#import "NIGameControl.h"

@implementation NIOnMoveComponent

@synthesize whoIsOnMove;
@synthesize isComputer;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setWhoIsOnMove: WHITE];
    }
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(notify:) name: @"changedOnMove" object: nil];
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSBezierPath *path1 = [[NSBezierPath alloc] init];
    
    if ([self whoIsOnMove] == WHITE) {
        [WHITE_PIECE set];
    } else {
        [BLACK_PIECE set];
    }
    [path1 appendBezierPathWithOvalInRect: dirtyRect];
    [path1 fill];
    [self drawSign: dirtyRect];
}

- (void)awakeFromNib
{
    [[self window] setContentAspectRatio: NSMakeSize(1.0, 1.0)];
}

- (void)notify:(NSNotification *)notification
{
    id sender = [notification object];
    
    [self setWhoIsOnMove: (int) [sender playerOnMove]];
    [self setIsComputer: [sender isPlayerOnMoveComputer]];
    [self setNeedsDisplay: YES];
    [self displayIfNeeded];
}

- (void)drawSign:(NSRect)rect
{
    NSFont *font = [NSFont fontWithName: @"Courier" size: 12];
    NSDictionary *stringAttrs = [NSDictionary dictionaryWithObjectsAndKeys: font, NSFontAttributeName, QUEEN, NSForegroundColorAttributeName, nil];
    NSAttributedString *attrString;
    
    rect.origin.x = rect.origin.x + rect.size.width / 4;
    rect.origin.y = rect.origin.y - 6 + rect.size.width / 4;
    rect.size.width = rect.size.width / 2;
    rect.size.height = rect.size.height / 2;
    if ([self isComputer]) {
        attrString = [[NSAttributedString alloc] initWithString: @"Poč." attributes: stringAttrs];
    } else {
        attrString = [[NSAttributedString alloc] initWithString: @"Člo." attributes: stringAttrs];
    }
    [attrString drawInRect: rect];
}

@end
