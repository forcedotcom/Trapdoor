//
//  ZKPartnerEnvelope.h
//  apexCoder
//
//  Created by Simon Fell on 6/8/07.
//  Copyright 2007 Simon Fell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZKEnvelope.h"

@interface ZKPartnerEnvelope : ZKEnvelope {
}

- (id)initWithSessionHeader:(NSString *)sessionId clientId:(NSString *)clientId;
- (id)initWithSessionAndMruHeaders:(NSString *)sessionId mru:(BOOL)mru clientId:(NSString *)clientId;

@end
