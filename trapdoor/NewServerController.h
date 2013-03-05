//
//  NewServerController.h
//  trapdoor
//
//  Created by Simon Fell on 4/28/07.
//  Copyright 2007 Simon Fell. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol NewServerAdded
- (void)newServerAdded:(NSString *)server;
@end

@interface NewServerController : NSObject {
	IBOutlet	NSWindow 	*newServerWindow;
	
	NSString 				*newServer;
	NSObject<NewServerAdded>*target;
}

- (void)showAddServer:(NSWindow *)parentWindow finishedTarget:(NSObject<NewServerAdded> *)t;

- (IBAction)addServer:(id)sender;
- (IBAction)cancelAddServer:(id)sender;

- (NSString *)newServer;
- (void)setNewServer:(NSString *)s;

@end
