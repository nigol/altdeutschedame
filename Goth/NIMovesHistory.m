//
//  NIMovesHistory.m
//  Goth
//
//  Created by Martin Polák on 25.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NIMovesHistory.h"
#import "NIPosition.h"

@implementation NIMovesHistory

@synthesize history;
@synthesize selected;

- (id)init
{
    self = [super init];
    if (self) {
        [self setHistory: [[NSMutableArray alloc] init]];
        [self setSelected: 0];
    }    
    return self;
}

- (void)add:(NIPosition *)position
{
    if ([self selected] == [[self history] count]) {
        [self setSelected: [self selected] + 1];
    } else {
        NSRange range;
        
        range.location = [self selected] + 1;
        range.length = ([[self history] count] - 1) - [self selected];
        [[self history] removeObjectsInRange: range];
        [self setSelected: (int)[[self history] count]];
    }
    [[self history] addObject: position];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [[self history] count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([[[tableColumn headerCell] title] isEqualToString: @"#"]) return [NSString stringWithFormat:@"%lu.", ++row];
    if ([[[tableColumn headerCell] title] isEqualToString: @"Kdo"]) return [[[self history] objectAtIndex: row] onMove] == BLACK ? @"Bílý" : @"Černý";
    return [[[self history] objectAtIndex: row] asString];
}

- (NIPosition *)retrievePositionAt:(int)index
{
    [self setSelected: index];
    return [[self history] objectAtIndex: index];
}

@end
