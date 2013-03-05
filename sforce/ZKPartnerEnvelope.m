//
//  ZKPartnerEnvelope.m
//  apexCoder
//
//  Created by Simon Fell on 6/8/07.
//  Copyright 2007 Simon Fell. All rights reserved.
//

#import "ZKPartnerEnvelope.h"

@implementation ZKPartnerEnvelope

- (id)initWithSessionHeader:(NSString *)sessionId clientId:(NSString *)clientId {
	return [self initWithSessionAndMruHeaders:sessionId mru:NO clientId:clientId];
}

- (id)initWithSessionAndMruHeaders:(NSString *)sessionId mru:(BOOL)mru clientId:(NSString *)clientId {
	self = [super init];
	[self start:@"urn:partner.soap.sforce.com"];
	[self writeSessionHeader:sessionId];
	[self writeCallOptionsHeader:clientId];
	[self writeMruHeader:mru];
	[self moveToBody];
	return self;
}

@end
