//
//  NIFreeCell.m
//  Goth
//
//  Created by Martin Polák on 08.11.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NIFreeCell.h"

@implementation NIFreeCell

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
    id copy = [[NIFreeCell allocWithZone: zone] init];
    
    return copy;
}

@end
