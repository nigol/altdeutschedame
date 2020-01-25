//
//  constants.h
//  Goth
//
//  Created by Martin Polák on 26.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Goth_constants_h
#define Goth_constants_h

#define WHITE 1
#define BLACK -1
#define WHITE_CELL [NSColor lightGrayColor]
#define BLACK_CELL [NSColor darkGrayColor]
#define WHITE_PIECE [NSColor whiteColor]
#define BLACK_PIECE [NSColor blackColor]
#define QUEEN [NSColor lightGrayColor]
#define SELECTED_CELL [NSColor colorWithCalibratedRed: 1 green: 1 blue: 0 alpha: 0.4]
#define HINT_CELL [NSColor colorWithCalibratedRed: 0 green: 1 blue: 0.2 alpha: 0.4]
#define HELP_CELL [NSColor colorWithCalibratedRed: 0 green: 0 blue: 1 alpha: 0.3]
#define COVER_BOARD [NSColor colorWithCalibratedWhite: 1 alpha: 0.2]
#define BOARD_MESSAGE [NSColor colorWithCalibratedRed: 0 green: 0 blue: 1 alpha: 0.7]
#define ltoi(x) ((x) - (('a') - (1)))
#define itol(x) ((x) + (('a') - (1)))
#define DRAW 2
#define CONTINUE 0
#define COMPUTER 2
#define HUMAN 1
#define INF 10000
#define MAXIMUM 999
#define TOO_MUCH 990
#define MAX_DEPTH 3
#define XML_ROOT @"altdeutschedamme-savegame"
#define XML_WHITE @"white"
#define XML_BLACK @"black"
#define XML_HISTORY @"history"
#define XML_VERSION @"1.0"
#define XML_ENCODING @"UTF-8"
#define XML_MOVE @"move"
#define XML_FIRST_STEP @"first-step"
#define XML_LAST_STEP @"last-step"
#define XML_POINT @"point"
#define XML_X @"x"
#define XML_Y @"y"

#endif
