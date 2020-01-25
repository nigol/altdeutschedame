//
//  GothAppDelegate.h
//  Goth
//
//  Created by Martin Polák on 17.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NIBoardComponent, NIGameControl, NIPoint, NIMove, NIOnMoveComponent, NIMovesHistory, NITextUI, NISiliconBrain;

@interface GothAppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate, NSTableViewDelegate, NSTableViewDataSource, NSWindowDelegate> {
    NSWindow *window;
    NIBoardComponent *boardView;
    NSDrawer *windowDrawer;
    NSProgressIndicator *gameIndicator;
    NIOnMoveComponent *onMove;
    NSTextField *statusBar;
    NSWindow *newGameSheet;
    NSTableView *movesTable;
    NSPopUpButton *newGameButtonWhite;
    NSPopUpButton *newGameButtonBlack;
    NSButton *newGameStarted;
    BOOL pausedGame;
    NSButton *continueGameButton;
    NSMenuItem *continueGameMenuItem;
    NSWindow *preferencesWindow;
    NSPopUpButton *preferencesButtonWhite;
    NSPopUpButton *preferencesButtonBlack;
    NSButton *showHintsCheckbox;
    NSMenuItem *bestMoveMenuItem;
    NSWindow *resultSheet;
    NSTextField *resultTextField;
    NSWindow *infoSheet;
    NSTextField *infoSheetMessage;
    BOOL canQuit;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NIBoardComponent *boardView;
@property (assign, readwrite) NIGameControl *gameControl;
- (IBAction)clickedOnBoard:(id)sender;
@property (assign) IBOutlet NSDrawer *windowDrawer;
@property (assign) IBOutlet NSProgressIndicator *gameIndicator;
- (void)clickNotSelected:(id)sender;
@property (readwrite, assign) NIMove *move;
- (void)clickSelected:(id)sender;
@property (assign) IBOutlet NIOnMoveComponent *onMove;
@property (assign) IBOutlet NSTextField *statusBar;
- (IBAction)newGame:(id)sender;
@property (assign) IBOutlet NSWindow *newGameSheet;
- (IBAction)newGameSheetHide:(id)sender;
@property (assign) IBOutlet NSTableView *movesTable;
- (void)afterMove;
- (void)setStatusMessage:(NSString *)message;
- (void)notify:(NSNotification *)notification;
@property (assign) IBOutlet NSPopUpButton *newGameButtonWhite;
@property (assign) IBOutlet NSPopUpButton *newGameButtonBlack;
- (IBAction)newGameStarted:(id)sender;
- (void)setGameParametersFrom:(NSPopUpButton *)buttonWhite with:(NSPopUpButton *)buttonBlack;
@property (readwrite, assign) BOOL pausedGame;
- (IBAction)pauseGame:(id)sender;
@property (assign) IBOutlet NSButton *continueGameButton;
- (IBAction)unpauseGame:(id)sender;
- (IBAction)undoMove:(id)sender;
- (IBAction)redoMove:(id)sender;
- (void)moveHistoryTo:(int)index;
- (BOOL)discoverSituationOn:(id)board;
@property (assign) IBOutlet NSMenuItem *continueGameMenuItem;
@property (assign) IBOutlet NSWindow *preferencesWindow;
- (IBAction)hidePreferencesWindow:(id)sender;
@property (assign) IBOutlet NSPopUpButton *preferencesButtonWhite;
@property (assign) IBOutlet NSPopUpButton *preferencesButtonBlack;
- (IBAction)setGamePreferences:(id)sender;
@property (assign) IBOutlet NSButton *showHintsCheckbox;
@property (assign) IBOutlet NSMenuItem *bestMoveMenuItem;
- (IBAction)bestMoveHint:(id)sender;
- (IBAction)saveAs:(id)sender;
- (IBAction)save:(id)sender;
- (void)writeOut;
@property (assign) IBOutlet NSWindow *infoSheet;
@property (assign) IBOutlet NSTextField *infoSheetMessage;
- (IBAction)hideInfoSheet:(id)sender;
- (IBAction)open:(id)sender;
- (void)quitAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;
@property (assign, readwrite) BOOL canQuit;

@end
