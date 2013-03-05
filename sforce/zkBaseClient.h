//
//  zkBaseClient.h
//  apexCoder
//
//  Created by Simon Fell on 5/29/07.
//  Copyright 2007 Simon Fell. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ZKBaseClient : NSObject {
	NSString	*endpointUrl;
}

- (NSXMLNode *)sendRequest:(NSString *)payload;

@end
