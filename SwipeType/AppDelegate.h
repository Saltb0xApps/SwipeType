//
//  AppDelegate.h
//  SwipeType
//
//  Created by Akhil Tolani on 07/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iRate.h"

@class MainViewController;
@class ATDocumentsLibrary;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    ATDocumentsLibrary *ATDocsLib;
}
@property (strong, nonatomic) UIWindow *window;

@end
