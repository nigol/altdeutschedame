//
//  NIMove.m
//  Goth
//
//  Created by Martin Polák on 31.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NIMove.h"
#import "NIPoint.h"

@implementation NIMove

@synthesize steps, captures, changes;

- (id)init
{
    self = [super init];
    if (self) {
        [self setSteps: [[NSMutableArray alloc] init]];
        [self setCaptures: [[NSMutableArray alloc] init]];
        [self setChanges: [[NSMutableArray alloc] init]];
        // Initialization code here.
    }
    
    return self;
}

- (id)addStep:(id)point
{
    [[self steps] addObject: point];
    return self;
}
- (id)firstStep
{
    return [[self steps] objectAtIndex: 0];
}

- (id)restSteps
{
    NSRange range;
    
    range.location = 1;
    range.length = [[self steps] count] - 1;
    return [[self steps] subarrayWithRange: range];
}

- (id)lastStep
{
    return [[self steps] lastObject];
}

- (id)addCapture:(id)point
{
    [[self captures] addObject: point];
    return self;
}

- (BOOL)isStepsEqualTo:(id)stps
{
    __block BOOL result = true;
    
    [[self steps] enumerateObjectsUsingBlock:^(id point, NSUInteger idx, BOOL *stop) {
        if (![point isEqualToPoint: [stps objectAtIndex: idx]]) {
            result = false;
            *stop = YES;
        }
    }];
    return result;
}

- (BOOL)isCapturesEqualTo:(id)cptures
{
    __block BOOL result = true;
    
    [[self captures] enumerateObjectsUsingBlock:^(id point, NSUInteger idx, BOOL *stop) {
        if (![point isEqualToPoint: [cptures objectAtIndex: idx]]) {
            result = false;
            *stop = YES;
        }
    }];
    return result;
}

- (BOOL)isEqualToMove:(id)move
{
    return [self isStepsEqualTo: [move steps]];
    //return ([self isStepsEqualTo: [move steps]] && [self isCapturesEqualTo: [move captures]]);
}

- (BOOL)isCaptures
{
    return ([[self captures] count] > 0);
}

- (id)addChange:(id)point
{
    [[self changes] addObject: point];
    return self;
}

- (BOOL)isEmpty
{
    return ([[self steps] count] == 0);
}

- (NSString *)asString
{
    NSString *string = [NSString stringWithFormat: @"%@ -> %@", [[self firstStep] asString], [[self lastStep] asString]];
    
    return string;
}

- (int)capturesCount
{
    return (int) [[self captures] count];
}

@end
