//
//  NIPoint.h
//  Goth
//
//  Created by Martin Polák on 06.11.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "constants.h"

@interface NIPoint : NSObject

@property(readwrite, assign) int x, y;

- (id)lineLength:(int)length xStep:(int)xstep yStep:(int)ystep;
- (BOOL)isEqualToPoint:(id)point;
- (NSString *)asString;

@end
