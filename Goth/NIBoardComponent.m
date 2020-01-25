//
//  NIBoardComponent.m
//  Goth
//
//  Created by Martin Polák on 21.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NIBoardComponent.h"
#import "NIGameBoard.h"
#import "NIPiece.h"
#import "NIPawn.h"
#import "NIQueen.h"
#import "NIPoint.h"
#import "NIMove.h"

@implementation NIBoardComponent

@synthesize cellDimension, boardSize;
@synthesize gameBoard;
@synthesize selectedCell;
@synthesize hintMoves;
@synthesize clickedPoint;
@synthesize helpMoves;
@synthesize showHints;

+ (id)cellClass
{
    return [NSActionCell class];
}

- (BOOL)isEven:(int)value
{
    return ((value % 2) == 0);
}

- (NSColor *)colorForRow:(int)row column:(int)column
{
    return ((([self isEven: row] && [self isEven: column]) || (![self isEven: row] && ![self isEven: column])) ? BLACK_CELL : WHITE_CELL);
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self drawSituation];
}

- (void)awakeFromNib
{
    [[self window] setContentAspectRatio: NSMakeSize(1.0, 1.0)];
    [[self window] setAcceptsMouseMovedEvents: YES];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)setFrame:(NSRect)frameRect
{
    [super setFrame: frameRect];
    [self setCellDimension: (frameRect.size.height) / ([self boardSize] + 1)];
    if ([self selectedCell] == nil) [self setSelectedCell: [[NIPoint alloc] init]];
    if ([self clickedPoint] == nil) [self setClickedPoint: [[NIPoint alloc] init]];
    if ([self hintMoves] == nil) [self setHintMoves: [[NSMutableArray alloc] init]];
    if ([self helpMoves] == nil) [self setHelpMoves: [[NSMutableArray alloc] init]];
    [self setShowHints: NO];
}

- (void)drawCellInRect:(NSRect)rect withColor:(NSColor *)color
{
    [color set];
    [NSBezierPath fillRect: rect];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint pt = [theEvent locationInWindow];
    NSPoint ptInView = [self convertPoint: pt fromView: nil];
    [[self clickedPoint] setX: (int) ptInView.x / [self cellDimension]];
    [[self clickedPoint] setY: (int) ptInView.y / [self cellDimension]];
    [self sendAction: [self action] to: [self target]];
}

- (void)drawBackground
{
    NSRect rect;
    NSFont *font = [NSFont fontWithName: @"Courier" size: [self cellDimension] - 12];
    NSDictionary *stringAttrs = [NSDictionary dictionaryWithObject: font forKey: NSFontAttributeName];
    int i, j;
    
    [[NSColor blackColor] set];
    for (i = 1; i < [self boardSize] + 1; i++) {
        rect.origin.x = i * [self cellDimension] + [self cellDimension] / 4;
        rect.origin.y = 0;
        rect.size.width = [self cellDimension];
        rect.size.height = [self cellDimension] + 8;
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString: [NSString stringWithFormat: @"%c", itol(i)] attributes: stringAttrs];
        [attrString drawInRect: rect];
    }
    for (i = 1; i < [self boardSize] + 1; i++) {
        rect.origin.x = 6;
        rect.origin.y = i * [self cellDimension];
        rect.size.width = [self cellDimension];
        rect.size.height = [self cellDimension];
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString: [NSString stringWithFormat: @"%d", i] attributes: stringAttrs];
        [attrString drawInRect: rect];
        for (j = 1; j < [self boardSize] + 1; j++) {
            rect.origin.x = j * [self cellDimension];
            rect.origin.y = i * [self cellDimension];
            rect.size.width = [self cellDimension];
            rect.size.height = [self cellDimension];
            [self drawCellInRect: rect withColor: [self colorForRow: i column: j]];
        }
    }
}

- (void)drawPawnInRect:(NSRect)rect withColor:(NSColor *)color
{
    NSBezierPath *path1 = [[NSBezierPath alloc] init];
    
    rect.origin.x = rect.origin.x + 2;
    rect.origin.y = rect.origin.y + 2;
    rect.size.width = rect.size.width - 4;
    rect.size.height = rect.size.height - 4;
    [color set];
    [path1 appendBezierPathWithOvalInRect: rect];
    [path1 fill];
}

- (void)drawPieces
{
    NSRect rect;
    int i, j;
    
    for (i = 1; i < [self boardSize] + 1; i++) {
        for (j = 1; j < [self boardSize] + 1; j++) {
            rect.origin.x = j * [self cellDimension];
            rect.origin.y = i * [self cellDimension];
            rect.size.width = [self cellDimension];
            rect.size.height = [self cellDimension];
            [self drawPieceAtX: j Y: i in: rect];
        }
    }
}

- (void)drawPieceAtX:(int)x Y:(int)y in:(NSRect)rect
{
    id cell = [[self gameBoard] cellAtX: x y: y];
    
    if ([cell isKindOfClass: [NIPawn class]]) {
        [self drawPawnInRect: rect withColor: ([cell pieceColor] == WHITE) ? WHITE_PIECE : BLACK_PIECE];
    }
    if ([cell isKindOfClass: [NIQueen class]]) {
        [self drawQueenInRect: rect withColor: ([cell pieceColor] == WHITE) ? WHITE_PIECE : BLACK_PIECE];
    }
}

- (void)drawSituation
{
    [self drawBackground];
    [self drawPieces];
    [self drawSelectedCell];
    [self drawHintCells];
    [self drawHelpCells];
}

- (void)drawQueenInRect:(NSRect)rect withColor:(NSColor *)color
{
    NSFont *font = [NSFont fontWithName: @"Courier" size: [self cellDimension] - 30];
    NSDictionary *stringAttrs;
    if (color == WHITE_PIECE) {
        stringAttrs = [NSDictionary dictionaryWithObjectsAndKeys: font, NSFontAttributeName, BLACK_PIECE, NSForegroundColorAttributeName, nil];
    } else {
        stringAttrs = [NSDictionary dictionaryWithObjectsAndKeys: font, NSFontAttributeName, WHITE_PIECE, NSForegroundColorAttributeName, nil];
    }

    [self drawPawnInRect: rect withColor: color];
    rect.origin.x = rect.origin.x + 15;
    rect.origin.y = rect.origin.y + 15;
    rect.size.width = rect.size.width - 30;
    rect.size.height = rect.size.height - 30;
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString: @"♕" attributes: stringAttrs];
    [attrString drawInRect: rect];
}

- (void)drawSelectedCell
{
    NSRect rect;
    int dimension = [self cellDimension];
    int x = [[self selectedCell] x];
    int y = [[self selectedCell] y];
    
    if (x != 0 && y != 0) {
        rect.origin.x = x * dimension;
        rect.origin.y = y * dimension;
        rect.size.width = dimension;
        rect.size.height = dimension;
        [self drawCellInRect: rect withColor: SELECTED_CELL];
    }
}

- (void)drawHintCells
{
    if ([self showHints]) {
        [self drawCellsFromMoves: [self hintMoves] withColor: HINT_CELL];
    }
}

- (void)drawCellsFromMoves:(NSMutableArray *)moves withColor:(NSColor *)color
{
    int dimension = [self cellDimension];
    
    [moves enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSRect rect;
        int x = [[obj lastStep] x];
        int y = [[obj lastStep] y];
        
        rect.origin.x = x * dimension;
        rect.origin.y = y * dimension;
        rect.size.width = dimension;
        rect.size.height = dimension;
        [self drawCellInRect: rect withColor: color];
    }];
}

- (void)drawHelpCells
{
    NSBezierPath *path1 = [[NSBezierPath alloc] init];
    __block NSPoint point1;
    __block NSRect rect;
    int dimension = [self cellDimension];
    
    [[self helpMoves] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        int x1 = [[obj firstStep] x];
        int y1 = [[obj firstStep] y];
        int x2 = [[obj lastStep] x];
        int y2 = [[obj lastStep] y];
        
        [HELP_CELL set];
        [path1 setLineWidth: 8];
        [path1 removeAllPoints];
        point1.x = (x1 * dimension) + (dimension / 2);
        point1.y = (y1 * dimension) + (dimension / 2);
        [path1 moveToPoint: point1];
        point1.x = (x2 * dimension) + (dimension / 2);
        point1.y = (y2 * dimension) + (dimension / 2);
        [path1 lineToPoint: point1];
        [path1 stroke];
        [path1 removeAllPoints];
        rect.origin.x = x2 * dimension;
        rect.origin.y = y2 * dimension;
        rect.size.width = dimension;
        rect.size.height = dimension;
        [path1 appendBezierPathWithOvalInRect: rect];
        [path1 fill];
    }];
}
@end
