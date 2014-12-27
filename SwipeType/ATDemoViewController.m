//
//  ATDemoViewController.m
//  SwipeType
//
//  Created by Akhil Tolani on 03/11/13.
//
//

#import "ATDemoViewController.h"

static ATDemoViewController *sharedInstance = nil;

@implementation ATDemoViewController

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON ) //Check for iPhone 5/iPod Touch 5G - 4 Inch Screen.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1];
        DemoTextField.delegate = self;
        DemoTextField.keyboardAppearance = UIKeyboardAppearanceDark;
        DemoTextField.autocorrectionType = UITextAutocorrectionTypeYes;
        DemoTextField.textColor = [UIColor blackColor];
        DemoTextField.textAlignment = NSTextAlignmentCenter;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"\n\n\n1.Place your finger on the spacebar\n\n2.Slide your finger to 'A' key\n\n3.Release your finger"];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Arial" size:18.0] range:NSMakeRange(0,attributedString.length)];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributedString length])];
        DemoTextField.attributedText = attributedString;
        [DemoTextField becomeFirstResponder];
        
        NavigationView.layer.shadowRadius = 5;
        NavigationView.layer.shadowColor = [UIColor blackColor].CGColor;
        NavigationView.layer.shadowOpacity = 0.33;
        NavigationView.layer.shadowOffset = CGSizeMake(0, 0);
        
        UIButton *ShortcutsButton = [UIButton buttonWithType:UIButtonTypeSystem];
        ShortcutsButton.frame = CGRectMake(0, NavigationView.frame.size.height + 10/*top indent*/, self.view.bounds.size.width, 40);
        [ShortcutsButton addTarget:self action:@selector(ShortcutsList) forControlEvents:UIControlEventTouchUpInside];
        [ShortcutsButton setTitle:@"List of keyboard shortcuts" forState:UIControlStateNormal];
        [self.view addSubview:ShortcutsButton];
    }
    return self;
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return NO;
}
- (void)ShortcutsList
{
    UIAlertView *HelpAlert=[[UIAlertView alloc]initWithTitle:@"All Keyboard Shortcuts" message:@"Swipe from spacebar to the following keys to perform the respective action\n\nA - Select All Text\nS - Select Current Word\nC - Copy selected Text\nX - Cut Selected Text\nV - Paste Clipboard Text\nH - Previous Word\nJ - Next Word\nK - Previous Character\nL - Next Character\nM - Scroll to bottom\nQ - Scroll to top\nZ - undo\nY - redo" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Okay",nil];
    HelpAlert.tag = 003;
    [HelpAlert show];
    [HelpAlert release];
}
-(void)Success
{
    UIAlertView *HelpAlert=[[UIAlertView alloc]initWithTitle:@"Perfect!" message:@"You just performed 'select all' keyboard shortcut." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Okay",nil];
    HelpAlert.tag = 004;
    [HelpAlert show];
    [HelpAlert release];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 004)
    {
        [self ShortcutsList];
    }
    if(alertView.tag == 003)
    {
        [self Done:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}
- (IBAction)Done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
+ (ATDemoViewController *)sharedInstance {
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

- (void)handleEvent:(UIEvent*)event
{
    NSSet * touchesForKeyboard = [self keyboardTouchesFromEvent:event];
    if(![touchesForKeyboard count])
        return;
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
        if (CGRectContainsPoint(CGRectMake(83, (IS_WIDESCREEN)?528:420, 155, 40), newTouchPoint))
        {
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"\n\n\n1.Place your finger on the spacebar\n\n2.Slide your finger to 'A' key\n\n3.Release your finger"];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
            [paragraphStyle setAlignment:NSTextAlignmentCenter];
            [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributedString length])];
            [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Arial" size:18.0] range:NSMakeRange(0,attributedString.length)];
            [attributedString addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(3, 35)];
            DemoTextField.attributedText = attributedString;
            startsFromKeyboard = YES;
        }
    }
    
    if([sender phase] == UITouchPhaseMoved && startsFromKeyboard)
    {
        SwipeGestureDetected = YES;
        if (CGRectContainsPoint(CGRectMake(18, (IS_WIDESCREEN)?418:310, 27, 40), newTouchPoint))
        {
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"\n\n\n1.Place your finger on the spacebar\n\n2.Slide your finger to 'A' key\n\n3.Release your finger"];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
            [paragraphStyle setAlignment:NSTextAlignmentCenter];
            [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributedString length])];
            [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Arial" size:18.0] range:NSMakeRange(0,attributedString.length)];
            [attributedString addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(3, 35)];
            [attributedString addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(40, 30)];
            DemoTextField.attributedText = attributedString;
        }
    }
    
    if([sender phase] == UITouchPhaseEnded)
    {
        if (CGRectContainsPoint(CGRectMake(18, (IS_WIDESCREEN)?418:310, 27, 40), newTouchPoint))
        {
            
            if(startsFromKeyboard)
            {
                //Select All Text
                [DemoTextField selectAll:self];
                startsFromKeyboard = NO;
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"\n\n\n1.Place your finger on the spacebar\n\n2.Slide your finger to 'A' key\n\n3.Release your finger"];
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
                [paragraphStyle setAlignment:NSTextAlignmentCenter];
                [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributedString length])];
                [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Arial" size:18.0] range:NSMakeRange(0,attributedString.length)];
                [attributedString addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(3, 35)];
                [attributedString addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(40, 30)];
                [attributedString addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(72, 21)];
                DemoTextField.attributedText = attributedString;
                [DemoTextField resignFirstResponder];
                [self Success];
                //Done demo successfully
            }
        }
        else //failed
        {
            startsFromKeyboard = NO;
            SwipeGestureDetected = NO;
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"\n\n\n1.Place your finger on the spacebar\n\n2.Slide your finger to 'A' key\n\n3.Release your finger"];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
            [paragraphStyle setAlignment:NSTextAlignmentCenter];
            [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributedString length])];
            [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Arial" size:18.0] range:NSMakeRange(0,attributedString.length)];
            DemoTextField.attributedText = attributedString;
            startsFromKeyboard = YES;
        }
    }
}
@end
