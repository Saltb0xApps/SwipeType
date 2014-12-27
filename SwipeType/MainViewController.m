//
//  MainViewController.m
//  SwipeType
//
//  Created by Akhil Tolani on 07/04/12.
//  Copyright (c) 2012 Saltb0xApps. All rights reserved.
//

#import "MainViewController.h"

//alerts like whatsapp
@implementation MainViewController

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON ) //Check for iPhone 5/iPod Touch 5G - 4 Inch Screen.

static MainViewController *sharedInstance = nil;
@synthesize delegate = _delegate;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

+ (MainViewController *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}
- (id)init
{
    self = [super init];
    return self;
}

+ (id)allocWithZone:(NSZone*)zone {
    return [[self sharedInstance] retain];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;
}
- (oneway void)release {
}
- (id)autorelease {
    return self;
}
- (void)ShowTextEditorWithText:(NSString*)text
{
    MainTextField.text = [NSString stringWithFormat:@"%@",text];
    CharacterCountLabel.text = [NSString stringWithFormat:@"%d characters",[[MainTextField text]length]];
    [self performSelector:@selector(MainTextViewBecomeFirstResponder) withObject:nil afterDelay:1];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.frame = [[UIScreen mainScreen]bounds];

    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(applicationDidBackground:)name:UIApplicationDidEnterBackgroundNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(backgrounded:) name:UIApplicationWillResignActiveNotification object:nil];

    MainTextField = [[QEDTextView alloc]initWithFrame:CGRectMake(0, NavigationView.frame.origin.y + NavigationView.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - (NavigationView.frame.origin.y + NavigationView.bounds.size.height))];
    MainTextField.delegate = self;
    MainTextField.tag = 77;
    MainTextField.backgroundColor = [UIColor whiteColor];
    MainTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    MainTextField.tintColor = [UIColor darkGrayColor];
    MainTextField.autocorrectionType = UITextAutocorrectionTypeYes;
    MainTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:MainTextField belowSubview:NavigationView];
    
    startsFromKeyboard = NO;
    
    NavigationView.layer.shadowRadius = 5;
    NavigationView.layer.shadowColor = [UIColor blackColor].CGColor;
    NavigationView.layer.shadowOpacity = 0.33;
    NavigationView.layer.shadowOffset = CGSizeMake(0, 0);
    
    pastie = [[Pastie alloc] init];
	[pastie setDelegate:self];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
}

-(void)textViewDidChange:(UITextView *)textView
{
    CharacterCountLabel.text = [NSString stringWithFormat:@"%d characters",[[MainTextField text]length]];
}

- (IBAction)Popover:(id)sender
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 150, (IS_WIDESCREEN)?175:125)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor clearColor];
    pv = [PopoverView showPopoverAtPoint:CGPointMake(PopoverButton.center.x,PopoverButton.frame.origin.y + PopoverButton.frame.size.height) inView:self.view withContentView:tableView delegate:self];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 11;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CYAN";
    StyledTableViewCell *cell = (StyledTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[[StyledTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
        [cell.textLabel setTextColor:[UIColor darkGrayColor]];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        cell.backgroundColor = [UIColor clearColor];
        [cell.textLabel setHighlightedTextColor:[UIColor whiteColor]];
        [cell setStyledTableViewCellSelectionStyle:StyledTableViewCellSelectionStyleCyan];
        [cell setDashWidth:5 dashGap:3 dashStroke:1];
    }
    if(indexPath.row == 0) {cell.textLabel.text = @"Demo";}
    else if(indexPath.row == 1) {cell.textLabel.text = @"Open In";}
    else if(indexPath.row == 2) {cell.textLabel.text = @"Email";}
    else if(indexPath.row == 3) {cell.textLabel.text = @"Google";}
    else if(indexPath.row == 4) {cell.textLabel.text = @"SMS";}
    else if(indexPath.row == 5) {cell.textLabel.text = @"Facebook";}
    else if(indexPath.row == 6) {cell.textLabel.text = @"Twitter";}
    else if(indexPath.row == 7) {cell.textLabel.text = @"Pastie";}
    else if(indexPath.row == 8) {cell.textLabel.text = @"Hide Keyboard";}
    else if(indexPath.row == 9) {cell.textLabel.text = @"Font Size +";}
    else if(indexPath.row == 10) {cell.textLabel.text = @"Font Size -";}
    else {cell.textLabel.text = @"";}
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        ATDemoViewController *controller = [[[ATDemoViewController alloc] initWithNibName:nil bundle:nil] autorelease];
        controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:controller animated:YES completion:nil];
    }
    else if (indexPath.row == 1) {[self OpenIn:nil];}
    else if (indexPath.row == 2) {[self EmailText:nil];}
    else if (indexPath.row == 3) {[self GoogleText:nil];}
    else if (indexPath.row == 4) {[self SendSMS:nil];}
    else if (indexPath.row == 5) {[self FacebookText:nil];}
    else if (indexPath.row == 6) {[self TweetText:nil];}
    else if (indexPath.row == 7) {[self Pastie:nil];}
    else if (indexPath.row == 8) {[self MainTextViewResignFirstResponder];}
    else if (indexPath.row == 9) {
        //changing bold and italic font sizes causes weird crash :(
        //MainTextField.boldFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@",MainTextField.boldFont.fontName] size:MainTextField.defaultFont.pointSize+2];
        //MainTextField.italicFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@",MainTextField.italicFont.fontName] size:MainTextField.defaultFont.pointSize+2];
        MainTextField.defaultFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@",MainTextField.defaultFont.fontName] size:MainTextField.defaultFont.pointSize+2];
    }
    else if (indexPath.row == 10){
        //MainTextField.boldFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@",MainTextField.boldFont.fontName] size:MainTextField.defaultFont.pointSize-2];
        //MainTextField.italicFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@",MainTextField.italicFont.fontName] size:MainTextField.defaultFont.pointSize-2];
        MainTextField.defaultFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@",MainTextField.defaultFont.fontName] size:MainTextField.defaultFont.pointSize-2];
    }
    else{return;}
    [pv performSelector:@selector(dismiss) withObject:nil afterDelay:0.5f];
}


-(void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newTextViewFrame = self.view.bounds;
    newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:500.0f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        MainTextField.frame = CGRectMake(MainTextField.frame.origin.x, NavigationView.frame.size.height, self.view.bounds.size.width, keyboardTop-77.5);
    }completion:nil];
}
-(void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newTextViewFrame = self.view.bounds;
    newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:500.0 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
        MainTextField.frame = CGRectMake(MainTextField.frame.origin.x, NavigationView.frame.size.height, self.view.bounds.size.width, keyboardTop-MainTextField.frame.origin.y);
    }completion:nil];
}


- (void)handleEvent:(UIEvent*)event
{
    NSSet * touchesForKeyboard = [self keyboardTouchesFromEvent:event];
    if(![touchesForKeyboard count]) return;
    [self SwipeToLetter:[[touchesForKeyboard allObjects]objectAtIndex:0]];
}
-(NSSet*)keyboardTouchesFromEvent:(UIEvent*)event
{
    NSSet *touchesForMainWindow = [event touchesForWindow:[[UIApplication sharedApplication] keyWindow]];
    NSMutableSet *touchesForKeyboard = [NSMutableSet setWithSet:[event allTouches]];
    [touchesForKeyboard minusSet:touchesForMainWindow];
    return touchesForKeyboard;
}

-(void)SwipeToLetter:(id)sender
{
    CGPoint newTouchPoint = [sender locationInView:self.view];
    
    if([sender phase] == UITouchPhaseBegan) 
    {  
        if (CGRectContainsPoint(CGRectMake(83, (IS_WIDESCREEN)?528:440, 155, 40), newTouchPoint))
        {
            NSLog(@"Touch Started At keyboard SpaceBar.");
            startsFromKeyboard = YES;
        }
    }
    
    if([sender phase] == UITouchPhaseMoved && startsFromKeyboard)
    {
        SwipeGestureDetected = YES;
    }
    
    if([sender phase] == UITouchPhaseEnded) 
    {
        CATransition *animation = [CATransition animation];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = kCATransitionFade;
        animation.duration = 0.75;
        [CharacterCountLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];
        if (CGRectContainsPoint(CGRectMake(18, (IS_WIDESCREEN)?418:330, 27, 40), newTouchPoint))
        {

            if(startsFromKeyboard)
            {
                //Select All Text
                [MainTextField selectAll:self];
                [CharacterCountLabel setText:@"Select All Text"];
                [CharacterCountLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16]];
                [self performSelector:@selector(ResetNavigationBarAlert) withObject:nil afterDelay:2];
                startsFromKeyboard = NO;
            }
        }
        else if (CGRectContainsPoint(CGRectMake(50, (IS_WIDESCREEN)?418:330, 27, 40), newTouchPoint))
        {
            if(startsFromKeyboard)
            {
                //Select Current Word
                [MainTextField select:nil];
                [CharacterCountLabel setText:@"Select Current Word"];
                [CharacterCountLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16]];
                [self performSelector:@selector(ResetNavigationBarAlert) withObject:nil afterDelay:2];
                startsFromKeyboard = NO;
            }
        }
        else if (CGRectContainsPoint(CGRectMake(114, (IS_WIDESCREEN)?471:383, 27, 40), newTouchPoint))
        {
            if(startsFromKeyboard)
            {
                //Copy selected text
                NSString *StringToCopy = [MainTextField.text substringWithRange:[MainTextField selectedRange]];
                [UIPasteboard generalPasteboard].string = StringToCopy;
                [CharacterCountLabel setText:@"Copy Selected Text"];
                [CharacterCountLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16]];
                [self performSelector:@selector(ResetNavigationBarAlert) withObject:nil afterDelay:2];
                startsFromKeyboard = NO;
            }
        }
        else if (CGRectContainsPoint(CGRectMake(82, (IS_WIDESCREEN)?471:383, 27, 40), newTouchPoint))
        {
            if(startsFromKeyboard)
            {
                //cut selected text
                [MainTextField cut:self];
                [CharacterCountLabel setText:@"Cut Selected Text"];
                [CharacterCountLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16]];
                [self performSelector:@selector(ResetNavigationBarAlert) withObject:nil afterDelay:2];
                startsFromKeyboard = NO;
            }
        }
        else if (CGRectContainsPoint(CGRectMake(146, (IS_WIDESCREEN)?471:383, 27, 40), newTouchPoint))
        {
            if(startsFromKeyboard)
            {
                //paste pasteboard text
                [[UIPasteboard generalPasteboard] containsPasteboardTypes:UIPasteboardTypeListString];
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                if (pasteboard.string != nil)
                { 
                    [MainTextField insertText:pasteboard.string];
                    [CharacterCountLabel setText:@"Paste Clipboard Text"];
                    [CharacterCountLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16]];
                    [self performSelector:@selector(ResetNavigationBarAlert) withObject:nil afterDelay:2];
                }
                startsFromKeyboard = NO;
            }
        }
        else if (CGRectContainsPoint(CGRectMake(242, (IS_WIDESCREEN)?471:383, 27, 40), newTouchPoint))
        {
            if(startsFromKeyboard)
            {
                //go to end of the text
                MainTextField.selectedRange = NSMakeRange(MainTextField.text.length, 0);
                [CharacterCountLabel setText:@"Scroll To Bottom"];
                [CharacterCountLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16]];
                [self performSelector:@selector(ResetNavigationBarAlert) withObject:nil afterDelay:2];
                startsFromKeyboard = NO;
            }
        }
        else if (CGRectContainsPoint(CGRectMake(3, (IS_WIDESCREEN)?363:275, 27, 40), newTouchPoint))
        {
            if(startsFromKeyboard)
            {
                //go to start of the text
                MainTextField.selectedRange = NSMakeRange(0, 0);
                [CharacterCountLabel setText:@"Scroll To Top"];
                [CharacterCountLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16]];
                [self performSelector:@selector(ResetNavigationBarAlert) withObject:nil afterDelay:2];
                startsFromKeyboard = NO;
            }
        }
        else if (CGRectContainsPoint(CGRectMake(178, (IS_WIDESCREEN)?418:330, 27, 40), newTouchPoint))
        {
            if(startsFromKeyboard)
            {
                //Previous Word
                if ([MainTextField.text length] != 0)
                {          
                    NSRange selectedRange = MainTextField.selectedRange;
                    NSInteger currentLocation = selectedRange.location;
                    
                    if ( currentLocation == 0 ) {
                        return;
                    }
                    
                    NSRange newRange = [MainTextField.text rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] options:NSBackwardsSearch range:NSMakeRange(0, (currentLocation - 1))];
                    if ( newRange.location != NSNotFound ) {
                        MainTextField.selectedRange = NSMakeRange((newRange.location + 1), 0);
                    } else {
                        MainTextField.selectedRange = NSMakeRange(0, 0);
                    }
                    [CharacterCountLabel setText:@"Previous Word"];
                    [CharacterCountLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16]];
                    [self performSelector:@selector(ResetNavigationBarAlert) withObject:nil afterDelay:2];
                }
                startsFromKeyboard = NO;
            }
        }
        else if (CGRectContainsPoint(CGRectMake(210, (IS_WIDESCREEN)?418:330, 27, 40), newTouchPoint))
        {
            if(startsFromKeyboard)
            {
                //Next Word
                if ([MainTextField.text length] != 0)
                {          
                    NSRange selectedRange = MainTextField.selectedRange;
                    NSInteger currentLocation = selectedRange.location + selectedRange.length;
                    NSInteger textLength = [MainTextField.text length];
                    
                    if ( currentLocation == textLength ) {return;}
                    NSRange newRange = [MainTextField.text rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] options:NSCaseInsensitiveSearch
                    range:NSMakeRange((currentLocation + 1), (textLength - 1 - currentLocation))];
                    if(newRange.location!=NSNotFound){MainTextField.selectedRange=NSMakeRange(newRange.location,0);}else{MainTextField.selectedRange=NSMakeRange(textLength,0);}
                    [CharacterCountLabel setText:@"Previous Word"];
                    [CharacterCountLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16]];
                    [self performSelector:@selector(ResetNavigationBarAlert) withObject:nil afterDelay:2];
                }
                startsFromKeyboard = NO;
            }
        }
        else if (CGRectContainsPoint(CGRectMake(242, (IS_WIDESCREEN)?418:330, 27, 40), newTouchPoint))
        {
            if(startsFromKeyboard)
            {
                //previous character
                if ([MainTextField.text length] != 0)
                {          
                    MainTextField.selectedRange = NSMakeRange(MainTextField.selectedRange.location-1, MainTextField.selectedRange.length);
                    [CharacterCountLabel setText:@"Previous Character"];
                    [CharacterCountLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16]];
                    [self performSelector:@selector(ResetNavigationBarAlert) withObject:nil afterDelay:2];
                }
                startsFromKeyboard = NO;
            }
        }
        else if (CGRectContainsPoint(CGRectMake(274, (IS_WIDESCREEN)?418:330, 27, 40), newTouchPoint))
        {
            if(startsFromKeyboard)
            {
                //next character
                if ([MainTextField.text length] != 0)
                {          
                    MainTextField.selectedRange = NSMakeRange(MainTextField.selectedRange.location+1, MainTextField.selectedRange.length);
                    [CharacterCountLabel setText:@"Next Character"];
                    [CharacterCountLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16]];
                    [self performSelector:@selector(ResetNavigationBarAlert) withObject:nil afterDelay:2];
                }
                startsFromKeyboard = NO;
            }
        }
        else if (CGRectContainsPoint(CGRectMake(50, (IS_WIDESCREEN)?471:383, 27, 40), newTouchPoint))
        {
            if(startsFromKeyboard)
            {
                //Undo
                [[MainTextField undoManager]undo];
                [CharacterCountLabel setText:@"Undo"];
                [CharacterCountLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16]];
                [self performSelector:@selector(ResetNavigationBarAlert) withObject:nil afterDelay:2];
                startsFromKeyboard = NO;
            }
        }
        else if (CGRectContainsPoint(CGRectMake(164, (IS_WIDESCREEN)?383:255, 27, 40), newTouchPoint))
        {
            if(startsFromKeyboard)
            {
                //redo
                [[MainTextField undoManager]redo];
                [CharacterCountLabel setText:@"Redo"];
                [CharacterCountLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16]];
                [self performSelector:@selector(ResetNavigationBarAlert) withObject:nil afterDelay:2];
                startsFromKeyboard = NO;
            }
        }
        else 
        {
            startsFromKeyboard = NO;
            SwipeGestureDetected = NO; 
        }
    }
}  

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if(SwipeGestureDetected)
    {
        SwipeGestureDetected = NO;
        return NO;
    }
    return YES;
}

- (IBAction)Done:(id)sender
{
    [self.delegate MainViewControllerDidFinishWithText:MainTextField.text];
}

-(void)OpenIn:(id)sender
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString * filePath = [NSString stringWithFormat:@"%@/OpenIn.txt",documentsDirectory];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        NSLog(@"Deleted Older file.");
    }
    else
        NSLog(@"File ain't there :P");
    
    NSError *error;
    BOOL succeed = [MainTextField.text writeToFile:[documentsDirectory stringByAppendingPathComponent:@"OpenIn.txt"] atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!succeed){
        UIAlertView *OpenInError = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Error Opening This Note in other apps. (This isn't SwipeType's fault)" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [OpenInError show];
    }
    else
    {
        [MainTextField resignFirstResponder];
        UIDocumentInteractionController *documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
        documentController.delegate = self;
        [documentController retain];
        [documentController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
    }
}
-(void)documentInteractionControllerDidDismissOpenInMenu: (UIDocumentInteractionController *)controller
{
    [MainTextField becomeFirstResponder];
}

- (void)GoogleText:(id)sender
{
    [MainTextField resignFirstResponder];
    NSString *query;
    if(MainTextField.selectedRange.length == 0)
    {
        query = [MainTextField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    else 
    {
        query = [[MainTextField.text substringWithRange:MainTextField.selectedRange] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.google.com/search?q=%@&ie=utf-8&oe=utf-8", query]];
    SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithURL:url];
    webViewController.barsTintColor = [UIColor brownColor];
    webViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:webViewController animated:YES completion:nil];
    [webViewController release];
}

- (void)EmailText:(id)sender
{
    if ([MFMailComposeViewController canSendMail])
    {
        [self resignFirstResponder];
        MFMailComposeViewController *controller=[[MFMailComposeViewController alloc] init];
        [controller setSubject:@""];
        [controller setMessageBody:[MainTextField text] isHTML:NO];
        controller.mailComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
        [controller release];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Your Device Cannot send an Email At the Moment." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    }
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self dismissViewControllerAnimated:YES completion:nil];
    [MainTextField becomeFirstResponder];
}

-(void)SendSMS:(id)sender
{
	MFMessageComposeViewController *controller = [[[MFMessageComposeViewController alloc] init] autorelease];
	if([MFMessageComposeViewController canSendText])
	{
        [MainTextField resignFirstResponder];
		controller.body = MainTextField.text;
		controller.messageComposeDelegate = self;
		[self presentViewController:controller animated:YES completion:nil];
	}
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)TweetText:(id)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [MainTextField resignFirstResponder];
        NSString *tweet140Text = [NSString stringWithFormat:@"%@",MainTextField.text];
        if([[MainTextField text]length] > 140)
        {
            tweet140Text = [MainTextField.text substringWithRange:NSMakeRange(0, 140)];
        }
        [composeViewController setInitialText:tweet140Text];
        [self presentViewController:composeViewController animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Your Device Cannot send a Tweet At the Moment." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)FacebookText:(id) sender
{
    SLComposeViewController *mySLComposerSheet = nil;
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        mySLComposerSheet = [[SLComposeViewController alloc] init];
        mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [mySLComposerSheet setInitialText:[NSString stringWithFormat:@"%@",MainTextField.text]];
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook" message:@"No Facebook account Linked. \n Go to Settings > Facebook & login." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)Pastie:(id)sender
{
    [self performSelector:@selector(beginSubmission)];
}
- (void)setLoadingModeEnabled:(BOOL)enabled {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:enabled];
	
	if (enabled) {
		[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	} else {
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	}
}
- (void)beginSubmission {
	[self setLoadingModeEnabled:YES];
	[pastie beginSubmissionWithText:[MainTextField text]];
    
	[self.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeIndeterminate;
	HUD.dimBackground = YES;
    HUD.delegate = self;
    HUD.labelText = @"Submitting To Pastie...";
    [MainTextField resignFirstResponder];
    [HUD show:YES];
}
- (void)submissionCompletedWithURL:(NSURL *)url {
	[self setLoadingModeEnabled:NO];
	
	[UIPasteboard generalPasteboard].string = [url absoluteString];
    
    HUD.mode = MBProgressHUDModeText;
    HUD.labelText = @"Submitted To Pastie";
    HUD.detailsLabelText = @"Link Copied To Your Clipboard";
    [HUD hide:YES afterDelay:2];
    [self performSelector:@selector(MainTextViewBecomeFirstResponder) withObject:nil afterDelay:2.5f];
}
- (void)submissionFailedWithError:(NSError *)error {
	[self setLoadingModeEnabled:NO];
	
    HUD.mode = MBProgressHUDModeText;
    HUD.labelText = @"Error Submitting To Pastie";
    HUD.detailsLabelText = @"Try Again Later";
    [HUD hide:YES afterDelay:2];
    [self performSelector:@selector(MainTextViewBecomeFirstResponder) withObject:nil afterDelay:2.5f];
}


- (void)ResetNavigationBarAlert {
    [CharacterCountLabel setText:[NSString stringWithFormat:@"%d characters",MainTextField.text.length]];
    [CharacterCountLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
}


- (void)MainTextViewBecomeFirstResponder {
    [MainTextField becomeFirstResponder];
}
- (void)MainTextViewResignFirstResponder {
    [MainTextField resignFirstResponder];
}
- (void)dealloc {
    [super dealloc];
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [MainTextField resignFirstResponder];
	[super viewWillDisappear:animated];
}
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
- (void)viewDidUnload {
    [super viewDidUnload];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if(DemoOverlay.alpha != 1)
        [self performSelector:@selector(MainTextViewBecomeFirstResponder) withObject:nil afterDelay:0];
}
- (void)backgrounded:(NSNotification *)notification {
    [MainTextField resignFirstResponder];
}
- (void)applicationDidBackground:(NSNotification *)notification {
    [MainTextField resignFirstResponder];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [MainTextField setNeedsDisplay];
}
@end
