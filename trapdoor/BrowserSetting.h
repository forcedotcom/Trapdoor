//
//  BrowserSetting.h
//  trapdoor
//
//  Created by Simon Fell on 4/21/07.
//  Copyright 2007 Simon Fell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Credential.h"

@class Browser;

@interface Credential (BrowserSetting) 
- (Browser *)browser;
- (void)setBrowser:(Browser *)b;
@end
