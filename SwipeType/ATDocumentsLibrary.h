//
//  ATDocumentsLibrary.h
//  SwipeType
//
//  Created by Akhil Tolani on 17/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h> 
#import <QuartzCore/QuartzCore.h>

#import "MainViewController.h"
#import "AppDelegate.h"

#import "ADLivelyTableView.h"
#import "MCSwipeTableViewCell.h"
#import "WKVerticalScrollBar.h"

@interface ATDocumentsLibrary : UIViewController <UITableViewDataSource,UITableViewDelegate,MCSwipeTableViewCellDelegate,UIAlertViewDelegate>
{
    IBOutlet UIView *NavigationView;
    IBOutlet UILabel *NoteCounterLabel;
    IBOutlet ADLivelyTableView *DocumentsList;
    IBOutlet UIButton *AddButton;
    
    WKVerticalScrollBar *verticalScrollBar;

    NSMutableArray *DocumentsText;
}
+ (id)sharedInstance;

- (IBAction)AddDocument:(id)sender;
- (IBAction)ChangeTableAnimation:(UIButton*)sender;
- (void)handleDocumentOpenURL:(NSURL *)url;
- (IBAction)ChangeTouchDownColor:(id)sender;
@end
