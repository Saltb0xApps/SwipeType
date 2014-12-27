//
//  ATDocumentsLibrary.m
//  SwipeType
//
//  Created by Akhil Tolani on 17/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ATDocumentsLibrary.h"

@implementation ATDocumentsLibrary

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON ) //Check for iPhone 5/iPod Touch 5G - 4 Inch Screen.

static ATDocumentsLibrary *sharedInstance = nil;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(SaveText)name:UIApplicationWillResignActiveNotification object:nil];
    
    NavigationView.layer.shadowRadius = 5;
    NavigationView.layer.shadowColor = [UIColor blackColor].CGColor;
    NavigationView.layer.shadowOpacity = 0.33;
    NavigationView.layer.shadowOffset = CGSizeMake(0, 0);
    
    AddButton.clipsToBounds = YES;
    AddButton.layer.cornerRadius = AddButton.frame.size.width/2;
    
    [DocumentsList setDataSource:self];
    [DocumentsList setDelegate:self];
    [DocumentsList setEditing:YES animated:NO];
    [DocumentsList setAllowsSelectionDuringEditing:YES];
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"TableViewAnimation"] == 1){DocumentsList.initialCellTransformBlock = ADLivelyTransformFade;}
    else if([[NSUserDefaults standardUserDefaults] integerForKey:@"TableViewAnimation"] == 2){DocumentsList.initialCellTransformBlock = ADLivelyTransformFlip;}
    else if([[NSUserDefaults standardUserDefaults] integerForKey:@"TableViewAnimation"] == 3){DocumentsList.initialCellTransformBlock = ADLivelyTransformFan;}
    else if([[NSUserDefaults standardUserDefaults] integerForKey:@"TableViewAnimation"] == 4){DocumentsList.initialCellTransformBlock = ADLivelyTransformWave;}
    else if([[NSUserDefaults standardUserDefaults] integerForKey:@"TableViewAnimation"] == 5){DocumentsList.initialCellTransformBlock = ADLivelyTransformTilt;}
    else {[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"TableViewAnimation"]; DocumentsList.initialCellTransformBlock = ADLivelyTransformFade;}

    
    verticalScrollBar = [[WKVerticalScrollBar alloc] initWithFrame:CGRectZero];
    [verticalScrollBar setFrame:DocumentsList.frame];
    [verticalScrollBar setScrollView:DocumentsList];
    verticalScrollBar.handleCornerRadius = 0;
    verticalScrollBar.handleWidth = 5;
    verticalScrollBar.handleSelectedCornerRadius = 0;
    verticalScrollBar.handleSelectedWidth = 10;
    verticalScrollBar.handleHitWidth = 15;
    [verticalScrollBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight ];
    [self.view addSubview:verticalScrollBar];
    [self.view bringSubviewToFront:verticalScrollBar];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *TextPath = [NSString stringWithFormat:@"%@/DocumentsText.plist", documentsDirectory];
    if([NSMutableArray arrayWithContentsOfFile:TextPath] != nil)
    {
        DocumentsText = [[NSMutableArray alloc] initWithContentsOfFile:TextPath];
        [DocumentsList reloadData];
        [self UpdateNoteCounter];
    }
    else 
    {
        DocumentsText = [[NSMutableArray alloc]init];
    }
    
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"FirstLaunch2.0"])
    {
        [DocumentsText addObject:[NSString stringWithFormat:@"Welcome to SwipeType 2.0, type more efficiently by performing actions like cut, copy, paste, select all, undo, redo, scroll to top or bottom and much more by swiping on your keyboard! to get started Press the ▼ button above and select 'Demo' from the popup."]];
        [DocumentsList beginUpdates];
        [DocumentsList insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [DocumentsList endUpdates];
        [self UpdateNoteCounter];
    }

    UIImageView *splashScreen;
    if(IS_WIDESCREEN)
        splashScreen = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default-568h@2x.png"]];
    else
        splashScreen = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
    splashScreen.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.view addSubview:splashScreen];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{splashScreen.alpha = 0.0;} completion:(void (^)(BOOL)) ^{[splashScreen removeFromSuperview];}];
}

/*UITableView Delegates*/
-(int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}
- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MainViewController *controller = [[[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil] autorelease];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:controller animated:YES completion:nil];
    
    if([NSStringFromClass([[DocumentsText objectAtIndex:indexPath.row] class]) isEqualToString:@"__NSCFString"]) //check if not NSAttributedString
    {
        [[MainViewController sharedInstance]ShowTextEditorWithText:[DocumentsText objectAtIndex:indexPath.row]];
    }
    else
    {
        [[MainViewController sharedInstance]ShowTextEditorWithText:[NSString stringWithFormat:@"%@",[DocumentsText objectAtIndex:indexPath.row]]]; //if not nsstring, convert.
    }
}
- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return DocumentsText.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CYAN";
    MCSwipeTableViewCell *cell = (MCSwipeTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[[MCSwipeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier]autorelease];
        [cell.textLabel setTextColor:[UIColor colorWithWhite:0.1 alpha:1]];
        [cell.detailTextLabel setTextColor:[UIColor grayColor]];
        
        [cell.textLabel setFont:[UIFont fontWithName:@"Avenir-Book" size:16]];
        [cell.detailTextLabel setFont:[UIFont fontWithName:@"Avenir-LightOblique" size:12]];
        
        [cell.textLabel setHighlightedTextColor:[UIColor whiteColor]];
        [cell.detailTextLabel setHighlightedTextColor:[UIColor whiteColor]];
        CGRect test = CGRectMake(cell.textLabel.frame.origin.x + 50, cell.textLabel.frame.origin.y, cell.textLabel.frame.size.width-50, cell.textLabel.frame.size.height);
        [cell.textLabel setFrame:test];
        [cell setShowsReorderControl:YES];

        UIView *FlatBlue = [[UIView alloc]initWithFrame:cell.frame];
        FlatBlue.backgroundColor = [UIColor colorWithRed:24.0/255.0 green:144.0/255.0 blue:194.0/255.0 alpha:1];
        cell.selectedBackgroundView = FlatBlue;
        
        StyledTableViewCellBackgroundView2 *DashSeperator = [[StyledTableViewCellBackgroundView2 alloc]initWithFrame:FlatBlue.frame];
        DashSeperator.dashGap = 0;
        DashSeperator.dashWidth = 5;
        DashSeperator.dashStroke = 0;
        cell.backgroundView = DashSeperator;
        
        [cell setDelegate:self];
        [cell setFirstStateIconName:@"cross.png"
         firstColor:[UIColor colorWithRed:232.0 / 255.0 green:61.0 / 255.0 blue:14.0 / 255.0 alpha:1.0]
         secondStateIconName:@"cross.png"
         secondColor:[UIColor colorWithRed:232.0 / 255.0 green:61.0 / 255.0 blue:14.0 / 255.0 alpha:1.0]
         thirdIconName:nil
         thirdColor:nil
         fourthIconName:nil
         fourthColor:nil];
        
        if(indexPath.row%2 == 0)
            cell.backgroundColor = [UIColor whiteColor];
        else
            cell.backgroundColor = [UIColor clearColor];
    }
    
    if([NSStringFromClass([[DocumentsText objectAtIndex:indexPath.row] class]) isEqualToString:@"__NSCFString"]) //simple check to avoid crash for NSAttributedStrings and other weird stuff
    {
        cell.textLabel.text = [DocumentsText objectAtIndex:indexPath.row];
    }
    else
    {
        [[MainViewController sharedInstance]ShowTextEditorWithText:[NSString stringWithFormat:@"%@",[DocumentsText objectAtIndex:indexPath.row]]]; //if not nsstring, convert.
    }
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d words",[self wordCount:[DocumentsText objectAtIndex:indexPath.row]]];
	return cell;
}
- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didEndSwipingSwipingWithState:(MCSwipeTableViewCellState)state mode:(MCSwipeTableViewCellMode)mode
{
    cell.textLabel.alpha = 1;
    cell.detailTextLabel.alpha = 1;
    UIAlertView *Confirm = [[UIAlertView alloc]initWithTitle:@"Confirm" message:[NSString stringWithFormat:@"Are you sure you want to delete this note %d",[DocumentsList indexPathForCell:cell].row+1] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    Confirm.tag = 0102;
    [Confirm show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 0102)
    {
        if(buttonIndex == 1)
        {
            NSUInteger index = [[self getNumbersFromString:alertView.message]integerValue]-1; //lol way :P
            [DocumentsText removeObjectAtIndex:index];
            [DocumentsList beginUpdates];
            [DocumentsList deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
            [DocumentsList endUpdates];
            [self UpdateNoteCounter];
        }
    }
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSString *item = [[DocumentsText objectAtIndex:fromIndexPath.row] retain];
    [DocumentsText removeObject:item];
    [DocumentsText insertObject:item atIndex:toIndexPath.row];
    [item release];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (IBAction)ChangeTableAnimation:(UIButton*)sender
{
    CABasicAnimation *fullRotation;
    fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    fullRotation.fromValue = [NSNumber numberWithFloat:0];
    fullRotation.toValue = [NSNumber numberWithFloat:((360*M_PI)/180)];
    fullRotation.duration = 0.5f;
    [sender.layer addAnimation:fullRotation forKey:@"360"];
    
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"TableViewAnimation"] == 1){
        DocumentsList.initialCellTransformBlock = ADLivelyTransformFlip;
        [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"TableViewAnimation"];
    }
    else if([[NSUserDefaults standardUserDefaults] integerForKey:@"TableViewAnimation"] == 2){
        DocumentsList.initialCellTransformBlock = ADLivelyTransformFan;
        [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"TableViewAnimation"];
    }
    else if([[NSUserDefaults standardUserDefaults] integerForKey:@"TableViewAnimation"] == 3){
        DocumentsList.initialCellTransformBlock = ADLivelyTransformWave;
        [[NSUserDefaults standardUserDefaults] setInteger:4 forKey:@"TableViewAnimation"];
    }
    else if([[NSUserDefaults standardUserDefaults] integerForKey:@"TableViewAnimation"] == 4){
        DocumentsList.initialCellTransformBlock = ADLivelyTransformTilt;
        [[NSUserDefaults standardUserDefaults] setInteger:5 forKey:@"TableViewAnimation"];
    }
    else if([[NSUserDefaults standardUserDefaults] integerForKey:@"TableViewAnimation"] == 5){
        DocumentsList.initialCellTransformBlock = ADLivelyTransformFade;
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"TableViewAnimation"];
    }
}

/*Data Handling*/
- (void)SaveText
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *TextPath = [documentsDirectory stringByAppendingString:@"/DocumentsText.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:TextPath]){
        NSDictionary *emptyDic = [NSDictionary dictionary];
        [emptyDic writeToFile:TextPath atomically:YES];
    }
    if(![DocumentsText writeToFile:TextPath atomically:YES])
    {
        NSLog(@"fail :P");
    }
    
    NSLog(@"Saved Documents");
}
- (IBAction)AddDocument:(id)sender
{
    AddButton.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1];
    [DocumentsText addObject:[NSString stringWithFormat:@"New Note"]];
    [DocumentsList beginUpdates];
    [DocumentsList insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:DocumentsText.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [DocumentsList endUpdates];
    [self UpdateNoteCounter];
}
- (void)handleDocumentOpenURL:(NSURL *)url {
    NSString* content = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    [DocumentsText addObject:[NSString stringWithFormat:@"%@",content]];
    [DocumentsList beginUpdates];
    [DocumentsList insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [DocumentsList endUpdates];
    [self UpdateNoteCounter];
}


- (void)MainViewControllerDidFinishWithText:(NSString*)text;
{
    [DocumentsText replaceObjectAtIndex:DocumentsList.indexPathForSelectedRow.row withObject:text];
    [DocumentsList reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)UpdateNoteCounter
{
    if(DocumentsText.count == 0)
    {
        NoteCounterLabel.text=[NSString stringWithFormat:@"No Notes"];
    }
    else if(DocumentsText.count == 1)
    {
        NoteCounterLabel.text=[NSString stringWithFormat:@"1 Note"];
    }
    else
    {
        NoteCounterLabel.text=[NSString stringWithFormat:@"%d Notes",DocumentsText.count];
    }
}

/*useless stuff*/
- (void)viewDidUnload
{
    [super viewDidUnload];
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
+ (ATDocumentsLibrary *)sharedInstance {
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
- (oneway void)release {}
- (id)autorelease {
    return self;
}
-(IBAction)ChangeTouchDownColor:(id)sender
{
    AddButton.backgroundColor = [UIColor colorWithRed:24.0/255.0 green:144.0/255.0 blue:194.0/255.0 alpha:1];
}
-(NSString*)getNumbersFromString:(NSString*)String{
    NSArray* Array = [String componentsSeparatedByCharactersInSet:
                      [[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    NSString* returnString = [Array componentsJoinedByString:@""];
    
    return (returnString);
}
-(NSUInteger)wordCount:(NSString*)string {
    __block NSUInteger wordCount = 0;
    [string enumerateSubstringsInRange:NSMakeRange(0, string.length) options:NSStringEnumerationByWords usingBlock:^(NSString *character, NSRange substringRange, NSRange enclosingRange, BOOL *stop){wordCount++;}];
    return wordCount;
}

@end
