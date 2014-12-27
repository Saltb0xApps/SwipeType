//
//  ATSwipeDelegate.m
//  SwipeType
//
//  Created by Akhil Tolani on 21/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ATSwipeDelegate.h"

@implementation ATSwipeDelegate
- (void)sendEvent:(UIEvent *)event
{
	[super sendEvent:event];
    [[MainViewController sharedInstance] handleEvent:event];
    [[ATDemoViewController sharedInstance] handleEvent:event];
}

@end
