//
//  AppDelegate.m
//  SwipeType
//
//  Created by Akhil Tolani on 07/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "MainViewController.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [_window release];
    [ATDocsLib release];
    [super dealloc];
}
+ (void)initialize
{
    [iRate sharedInstance].appStoreID = 550077134;
    [iRate sharedInstance].usesUntilPrompt = 10;
    [iRate sharedInstance].messageTitle = @"SwipeType";
    [iRate sharedInstance].daysUntilPrompt = 7;
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"FirstLaunch2.0",nil]];
    ATDocsLib = [[[ATDocumentsLibrary alloc] initWithNibName:@"ATDocumentsLibrary" bundle:nil] autorelease];
    self.window.rootViewController = ATDocsLib;
    self.window.layer.cornerRadius = 7.5;
    self.window.layer.shouldRasterize = YES;
    self.window.layer.rasterizationScale = [[UIScreen mainScreen]scale];
    self.window.clipsToBounds = YES;
    [self.window makeKeyAndVisible];

    return YES;
}
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if (url != nil && [url isFileURL]) {
        [[ATDocumentsLibrary sharedInstance] handleDocumentOpenURL:url];
    }
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FirstLaunch2.0"];
}
@end
