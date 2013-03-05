//
//  StyledWindowStyles.m
//  AppExplorer
//
//  Created by Simon Fell on 1/21/07.
//  Copyright 2007 Simon Fell. All rights reserved.
//

#import "StyledWindowStyles.h"


@implementation StyledWindowStyles

+ (void)styleLikeItunes:(StyledWindow *)aWindow {
	[aWindow setTopBorder:28.0];
	[aWindow setBottomBorder:28.0];
	[aWindow setBorderStartColor:[NSColor lightGrayColor]];
	[aWindow setBorderEndColor:[NSColor grayColor]];
	[aWindow setBorderEdgeColor:[NSColor colorWithDeviceWhite:0.25 alpha:1.0]];
	[aWindow setBgColor:[NSColor controlBackgroundColor]];
	[aWindow setBackgroundColor:[aWindow styledBackground]];
}

@end
