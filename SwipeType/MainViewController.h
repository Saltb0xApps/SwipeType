//
//  MainViewController.h
//  SwipeType
//
//  Created by Akhil Tolani on 07/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import <MessageUI/MessageUI.h>
#import <Twitter/Twitter.h>

#import "MBProgressHUD.h"
#import "SVModalWebViewController.h"
#import "ATDocumentsLibrary.h"
#import "WKVerticalScrollBar.h"
#import "Pastie.h"
#import "QEDTextView.h"
#import "PopoverView.h"
#import "ATDemoViewController.h"
#import "StyledTableViewCell.h"

@protocol MainViewControllerDelegate
- (void)MainViewControllerDidFinishWithText:(NSString*)text;
@end

@interface MainViewController:UIViewController <PastieDelegate,MFMailComposeViewControllerDelegate,UITextViewDelegate,MBProgressHUDDelegate,MFMessageComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate, UITableViewDataSource, UITableViewDelegate, PopoverViewDelegate>
{    
    MBProgressHUD *HUD;
    Pastie *pastie;
    PopoverView *pv;

    BOOL startsFromKeyboard;
    BOOL SwipeGestureDetected;
    
    UIView *DemoOverlay;
    UILabel *MainLabel;
    UIImageView *FingerImage;
    NSMutableArray *DropboxFiles;
    NSString *TextToShow;
    
    IBOutlet UIView *MainView;
    IBOutlet UIView *NavigationView;
    IBOutlet UILabel *CharacterCountLabel;
    IBOutlet UIButton *ExitButton;
    IBOutlet UIButton *PopoverButton;
    IBOutlet QEDTextView *MainTextField;
}

- (void)Pastie:(id)sender;
- (void)EmailText:(id)sender;
- (void)TweetText:(id)sender;
- (void)FacebookText:(id) sender;
- (void)GoogleText:(id)sender;
- (void)OpenIn:(id)sender;
- (void)SendSMS:(id)sender;

- (IBAction)Done:(id)sender;
- (IBAction)Popover:(id)sender;

+ (id)sharedInstance;
- (void)SwipeToLetter:(id)sender;
- (void)handleEvent:(UIEvent*)event;
- (void)ShowTextEditorWithText:(NSString*)text;

@property (assign, nonatomic) id <MainViewControllerDelegate> delegate;

@end
