//
//  GothAppDelegate.m
//  Goth
//
//  Created by Martin Polák on 17.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GothAppDelegate.h"
#import "NIBoardComponent.h"
#import "NIGameControl.h"
#import "NIPoint.h"
#import "NIMove.h"
#import "NIOnMoveComponent.h"
#import "NIMovesHistory.h"
#import "NITextUI.h"
#import "NISiliconBrain.h"

@implementation GothAppDelegate
@synthesize infoSheet;
@synthesize infoSheetMessage;
@synthesize showHintsCheckbox;
@synthesize bestMoveMenuItem;
@synthesize preferencesButtonWhite;
@synthesize preferencesButtonBlack;
@synthesize continueGameMenuItem;
@synthesize preferencesWindow;
@synthesize continueGameButton;
@synthesize newGameButtonWhite;
@synthesize newGameButtonBlack;
@synthesize movesTable;
@synthesize newGameSheet;
@synthesize onMove;
@synthesize statusBar;
@synthesize gameIndicator;
@synthesize windowDrawer;

@synthesize window;
@synthesize boardView;
@synthesize gameControl;
@synthesize move;
@synthesize pausedGame;
@synthesize canQuit;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSSize drawerSize;
    
    // Insert code here to initialize your application
    //[[[[NITextUI alloc] init] setUp] loop];
    //[NSApp terminate: self];
    [self setCanQuit: NO];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(notify:) name: @"changedOnMove" object: nil];
    [self setMove: [[NIMove alloc] init]];
    [self setGameControl: [[NIGameControl alloc] init]];
    [[self boardView] setBoardSize: [[[self gameControl] gameRules] boardSize] - 2];
    [[self boardView] setGameBoard: [[self gameControl] gameBoard]];
    drawerSize.width = 300;
    [[self windowDrawer] setContentSize: drawerSize];
    [[self windowDrawer] setMinContentSize: drawerSize];
    [[self windowDrawer] toggle: self];
    [[self boardView] setFrame: [[self boardView] frame]];
    [[self boardView] setNeedsDisplay: YES];
    [[self boardView] displayIfNeeded];
    [[self gameControl] player: 1 is: 1];
    [[self gameControl] player: -1 is: 1];
}

- (IBAction)clickedOnBoard:(id)sender {
    if ([[self gameControl] isPlayerOnMoveComputer] || [self pausedGame]) return;
    [sender setHelpMoves: [[NSMutableArray alloc] init]];
    [[self statusBar] setStringValue: @""];
    [self afterMove];
    if ([[self move] isEmpty]) {
        [self clickNotSelected: sender];
    } else {
        [self clickSelected: sender];
    }
}

- (void)clickNotSelected:(id)sender
{
    @try {
        [sender setHintMoves: [[self gameControl] hintFor: [sender clickedPoint]]];
    }
    @catch (NSException *exception) {
        return;
    }
    [[sender selectedCell] setX: [[sender clickedPoint] x]];
    [[sender selectedCell] setY: [[sender clickedPoint] y]];
    [[self move] addStep: [sender selectedCell]];
    [self setStatusMessage: [NSString stringWithFormat: @"Vybráno: %@.", [[[self move] firstStep] asString]]];
    [self afterMove];
}

- (void)clickSelected:(id)sender
{
    if ([[sender clickedPoint] isEqualToPoint: [sender selectedCell]]) {
        [[sender selectedCell] setX: 0];
        [[sender selectedCell] setY: 0];
        [sender setHintMoves: [[NSMutableArray alloc] init]];
        [self setMove: [[NIMove alloc] init]];
    } else {
        [[self move] addStep: [sender clickedPoint]];
        @try {
            [[self gameControl] proceedWithMove: [self move]];
            [[self window] setDocumentEdited: YES];
        }
        @catch (NSException *exception) {
            [sender setHelpMoves: [[self gameControl] movesForPlayerOnMove]];
            [self setStatusMessage: @"Tento tah není povolen."];
            [[sender selectedCell] setX: 0];
            [[sender selectedCell] setY: 0];
            [sender setHintMoves: [[NSMutableArray alloc] init]];
            [self setMove: [[NIMove alloc] init]];
            [self afterMove];
            return;
        }
    }
    [[sender selectedCell] setX: 0];
    [[sender selectedCell] setY: 0];
    [sender setHintMoves: [[NSMutableArray alloc] init]];
    [self setMove: [[NIMove alloc] init]];
    [self afterMove];
}

- (IBAction)newGame:(id)sender {
    [NSApp beginSheet: [self newGameSheet] modalForWindow: [self window] modalDelegate: self didEndSelector: nil contextInfo: nil];
}

- (IBAction)newGameSheetHide:(id)sender {
    [NSApp endSheet: [self newGameSheet]];
    [[self newGameSheet] orderOut: self];
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [[[self gameControl] history] numberOfRowsInTableView: tableView];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return [[[self gameControl] history] tableView: tableView objectValueForTableColumn: tableColumn row: row];
}

- (void)afterMove
{
    if ([self discoverSituationOn: [[self gameControl] gameBoard]]) {
        [[self boardView] setNeedsDisplay: YES];
        [[self boardView] displayIfNeeded];
        [[self movesTable] reloadData];
        [[[self windowDrawer] contentView] setNeedsDisplay: YES];
        [[[self windowDrawer] contentView] displayIfNeeded];
        if ([[self gameControl] isPlayerOnMoveComputer] && ![self pausedGame]) {
            [[self gameIndicator] startAnimation: self];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [queue addOperationWithBlock:^{
                [[self gameControl] performComputerMove];
                [[self window] setDocumentEdited: YES];
                [self afterMove];
            }];
        } else {
            [[self gameIndicator] stopAnimation: self];
        }
    } else {
        [self pauseGame: self];
    }
}

- (void)setStatusMessage:(NSString *)message
{
    [[self statusBar] setStringValue: message];
}

- (void)notify:(NSNotification *)notification
{
    id sender = [notification object];
    NSString *msg = [NSString stringWithFormat: @"%@ (%@) na tahu.", [sender playerOnMove] == WHITE ? @"Bílý" : @"Černý", [sender isPlayerOnMoveComputer] ? @"Počítač" : @"Člověk"];
    
    [self setStatusMessage: msg];
}

- (IBAction)newGameStarted:(id)sender {
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(notify:) name: @"changedOnMove" object: nil];
    [self setMove: [[NIMove alloc] init]];
    [self setGameControl: [[NIGameControl alloc] init]];
    [[self boardView] setBoardSize: [[[self gameControl] gameRules] boardSize] - 2];
    [[self boardView] setGameBoard: [[self gameControl] gameBoard]];
    [self setGameParametersFrom: [self newGameButtonWhite] with: [self newGameButtonBlack]];
    [[self boardView] setNeedsDisplay: YES];
    [[self boardView] displayIfNeeded];
    [self newGameSheetHide: self];
    [self unpauseGame: self];
}

- (void)setGameParametersFrom:(NSPopUpButton *)buttonWhite with:(NSPopUpButton *)buttonBlack
{
    int whiteSelected = (int)[buttonWhite indexOfSelectedItem];
    int blackSelected = (int)[buttonBlack indexOfSelectedItem];
    
    if (whiteSelected == 0) {
        [[self gameControl] player: WHITE is: HUMAN];
    } else {
        [[self gameControl] player: WHITE is: COMPUTER];
        [[self gameControl] setComputerPlayerLevel: whiteSelected on: WHITE];
    }
    if (blackSelected == 0) {
        [[self gameControl] player: BLACK is: HUMAN];
    } else {
        [[self gameControl] player: BLACK is: COMPUTER];
        [[self gameControl] setComputerPlayerLevel: blackSelected on: BLACK];
    }
    [[self preferencesButtonWhite] selectItemAtIndex: whiteSelected];
    [[self preferencesButtonBlack] selectItemAtIndex: blackSelected];
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    return YES;
}

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return NO;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    id obj = [aNotification object];
    int index = (int)[obj selectedRow];    
    
    [self pauseGame: self];
    [self moveHistoryTo: index];
}

- (IBAction)pauseGame:(id)sender {
    [self setPausedGame: YES];
    [[[self gameControl] brain] setPaused: YES];
    [[self continueGameButton] setEnabled: YES];
    [[self gameIndicator] stopAnimation: self];
    [[self movesTable] reloadData];
    [self setStatusMessage: @"Hra pozastavena."];
    [[self boardView] setNeedsDisplay: YES];
    [[self boardView] displayIfNeeded];
}

- (IBAction)unpauseGame:(id)sender {
    [self setPausedGame: NO];
    [[[self gameControl] brain] setPaused: NO];
    [[self continueGameButton] setEnabled: NO];
    [[self window] setTitle: @"Gotická dáma"];
    [self setStatusMessage: @""];
    [self afterMove];
}

- (IBAction)undoMove:(id)sender {
    NIMovesHistory *history = [[self gameControl] history];
    int index = [history selected] - 1;
    
    [self pauseGame: self];
    if (index > -1 && index < [movesTable numberOfRows]) {
        [self moveHistoryTo: index];
        NSIndexSet *is = [NSIndexSet indexSetWithIndex: [history selected]];
        [[self movesTable] selectRowIndexes: is byExtendingSelection: NO];
    }
}

- (IBAction)redoMove:(id)sender {
    NIMovesHistory *history = [[self gameControl] history];
    int index = [history selected] + 1;
    
    [self pauseGame: self];
    if (index > -1 && index < [movesTable numberOfRows]) {
        [self moveHistoryTo: index];
        NSIndexSet *is = [NSIndexSet indexSetWithIndex: [history selected]];
        [[self movesTable] selectRowIndexes: is byExtendingSelection: NO];
    }
}

- (void)moveHistoryTo:(int)index
{
    NIMovesHistory *history = [[self gameControl] history];
    
    if (index != -1) {
        [[self gameControl] stateFromPosition: [history retrievePositionAt: index]];
    }
    [[self boardView] setGameBoard: [[self gameControl] gameBoard]];
    [self afterMove];
}

- (BOOL)discoverSituationOn:(id)board
{
    int result = [[self gameControl] stateOfGame: board];
    NSString *whiteWins = @"Vyhrál BÍLÝ hráč.";
    NSString *blackWins = @"Vyhrál ČERNÝ hráč.";
    NSString *drawGame = @"Remíza.";
    
    if (result == (WHITE)) {
        [[self window] setTitle: whiteWins];
        [[self infoSheetMessage] setStringValue: whiteWins];
        [NSApp beginSheet: [self infoSheet] modalForWindow: [self window] modalDelegate: self didEndSelector: nil contextInfo: nil];
        return false;
    }
    if (result == (BLACK)) {
        [[self window] setTitle: blackWins];
        [[self infoSheetMessage] setStringValue: blackWins];
        [NSApp beginSheet: [self infoSheet] modalForWindow: [self window] modalDelegate: self didEndSelector: nil contextInfo: nil];        
        return false;
    }
    if (result == DRAW) {
        [[self window] setTitle: drawGame];
        [[self infoSheetMessage] setStringValue: drawGame];
        [NSApp beginSheet: [self infoSheet] modalForWindow: [self window] modalDelegate: self didEndSelector: nil contextInfo: nil];
        return false;
    }
    return true;
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if (menuItem == [self bestMoveMenuItem]) {
        if ([[self gameControl] isPlayerOnMoveComputer]) {
            return NO;
        } else {
            return YES;
        }
    }
    return YES;
}

- (BOOL)windowShouldClose:(id)sender
{
    [NSApp terminate: self];
    return NO;
}

- (IBAction)hidePreferencesWindow:(id)sender {
    [[self preferencesWindow] orderOut: self];
}

- (IBAction)setGamePreferences:(id)sender {
    [self setGameParametersFrom: [self preferencesButtonWhite] with: [self preferencesButtonBlack]];
    if ([[self showHintsCheckbox] state] == NSOnState) {
        [[self boardView] setShowHints: YES];
    } else {
        [[self boardView] setShowHints: NO];
    }
    [self hidePreferencesWindow: self];
    [[self window] setDocumentEdited: YES];
    [self afterMove];
}

- (void)menuWillOpen:(NSMenu *)menu
{
    [self pauseGame: self];
}

- (IBAction)bestMoveHint:(id)sender {
    [[self gameIndicator] startAnimation: self];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        NIMove *m;
        NSMutableArray *moves = [[NSMutableArray alloc] init];
        
        [self setStatusMessage: @"Výpočet nejlepšího tahu…"];
        [[self continueGameButton] setEnabled: NO];
        [[[self gameControl] brain] setPaused: NO];
        m = [[self gameControl] bestMoveWith: MAX_DEPTH];
        if ([m isEmpty]) {
            [self setStatusMessage: @""];
        } else {
            [moves addObject: m];
            [[self boardView] setHelpMoves: moves];
            [self setStatusMessage: [NSString stringWithFormat: @"Doporučení: %@.", [m asString]]];
            [self unpauseGame: self];
        }
        [self afterMove];
    }];
}

- (IBAction)saveAs:(id)sender {
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"xml"]];
    [savePanel beginSheetModalForWindow: [self window] completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            [savePanel orderOut: self];
            [[self gameControl] setFilename: [savePanel URL]];
            [self writeOut];
        }
    }];
}

- (IBAction)save:(id)sender {
    if ([[[self gameControl] filename] absoluteString] == nil) {
        [self saveAs: self];
    } else {
        [self writeOut];
    }
}

- (void)writeOut
{
    @try {
        [[self gameControl] saveGame];
        [[self window] setDocumentEdited: NO];
    }
    @catch (NSException *exception) {
        [self setStatusMessage: @"Soubor nelze uložit."];
        [[self infoSheetMessage] setStringValue: @"Soubor nelze uložit."];
        [NSApp beginSheet: [self infoSheet] modalForWindow: [self window] modalDelegate: self didEndSelector: nil contextInfo: nil];
    }
}
- (IBAction)hideInfoSheet:(id)sender {
    [NSApp endSheet: [self infoSheet]];
    [[self infoSheet] orderOut: nil];
}

- (IBAction)open:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowedFileTypes:[NSArray arrayWithObject:@"xml"]];
    [openPanel beginSheetModalForWindow: [self window] completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            [self setStatusMessage: @"Načítám hru…"];
            [[self gameIndicator] startAnimation: self];
            [openPanel orderOut: self];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [queue addOperationWithBlock:^{
                @try {
                    [[self gameControl] loadGame: [openPanel URL]];
                    if ([[self gameControl] white] == 1) {
                        [[self preferencesButtonWhite] selectItemAtIndex: 0];
                    } else {
                        [[self preferencesButtonWhite] selectItemAtIndex: [[self gameControl] white] - 2];
                    }
                    if ([[self gameControl] black] == 1) {
                        [[self preferencesButtonBlack] selectItemAtIndex: 0];
                    } else {
                        [[self preferencesButtonBlack] selectItemAtIndex: [[self gameControl] black] - 2];
                    }
                    [self setMove: [[NIMove alloc] init]];
                    [[self gameControl] setFilename: [openPanel URL]];
                    [self pauseGame: self];
                    [self afterMove];
                }
                @catch (NSException *exception) {
                    [[self gameIndicator] stopAnimation: self];
                    [self setStatusMessage: @"Soubor nelze otevřít."];
                    [[self infoSheetMessage] setStringValue: @"Soubor nelze otevřít."];
                    [NSApp beginSheet: [self infoSheet] modalForWindow: [self window] modalDelegate: self didEndSelector: nil contextInfo: nil];
                }
            }];
        }
    }];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    if ([[self window] isDocumentEdited]) {
        NSAlert *alert = [NSAlert alertWithMessageText: @"Opravdu ukončit aplikaci?" defaultButton: @"Neukončovat" alternateButton: @"Ukončit" otherButton: nil informativeTextWithFormat: @"%@", @"Rozehraná hra nebude uložena."];
            [alert beginSheetModalForWindow: [self window] modalDelegate: self didEndSelector: @selector(quitAlertDidEnd:returnCode:contextInfo:) contextInfo: nil];
        return NSTerminateLater;
    } else {
        return NSTerminateNow;
    }
}

- (void)quitAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == NSAlertDefaultReturn) {
        [NSApp replyToApplicationShouldTerminate: NO];
    }
    if (returnCode == NSAlertAlternateReturn) {
        [NSApp replyToApplicationShouldTerminate: YES];
    }
}
@end
