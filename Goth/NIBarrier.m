//
//  NIBarrier.m
//  Goth
//
//  Created by Martin Polák on 23.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NIBarrier.h"

@implementation NIBarrier

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    id copy = [[NIBarrier allocWithZone: zone] init];
    
    return copy;
}

@end
