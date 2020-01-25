//
//  NIPoint.m
//  Goth
//
//  Created by Martin Polák on 06.11.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NIPoint.h"

@implementation NIPoint

@synthesize x;
@synthesize y;

- (id)init
{
    self = [super init];
    if (self) {
        [self setX: 0];
        [self setY: 0];
    }
    
    return self;
}

- (id)lineLength:(int)length xStep:(int)xstep yStep:(int)ystep
{
    id line = [[NSMutableArray alloc] init];
    id point;
    int i;
    
    for (i = 0; i < length; i++) {
        point = [[NIPoint alloc] init];
        [point setX: [self x] + (i * xstep)];
        [point setY: [self y] + (i * ystep)];
        [line addObject: point];
    }
    return line;
}

- (BOOL)isEqualToPoint:(id)point
{
    return ([self x] == [point x] && [self y] == [point y]);
}

- (NSString *)asString
{
    NSString *string = [NSString stringWithFormat: @"%c%d", (char)itol([self x]), [self y]];
    
    return string;
}

- (void)updateTrackingAreaWithFrame:(NSRect)rect inView:(id)view
{
    
}

@end
