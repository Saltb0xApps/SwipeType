//
//  ATDemoViewController.h
//  SwipeType
//
//  Created by Akhil Tolani on 03/11/13.
//
//

#import <UIKit/UIKit.h>

@interface ATDemoViewController : UIViewController <UITextViewDelegate, UIAlertViewDelegate>
{
    IBOutlet UITextView *DemoTextField;
    IBOutlet UIView *NavigationView;
    
    BOOL startsFromKeyboard;
    BOOL SwipeGestureDetected;
}

+ (id)sharedInstance;
- (void)SwipeToLetter:(id)sender;
- (void)handleEvent:(UIEvent*)event;

- (IBAction)Done:(id)sender;
@end
