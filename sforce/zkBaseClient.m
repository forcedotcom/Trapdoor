//
//  zkBaseClient.m
//  apexCoder
//
//  Created by Simon Fell on 5/29/07.
//  Copyright 2007 Simon Fell. All rights reserved.
//

#import "zkBaseClient.h"
#import "zkSoapException.h"

@implementation ZKBaseClient

- (void)dealloc {
	[endpointUrl release];
	[super dealloc];
}

- (NSXMLNode *)sendRequest:(NSString *)payload {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:endpointUrl]];
	[request setHTTPMethod:@"POST"];
	[request addValue:@"text/xml; charset=UTF-8" forHTTPHeaderField:@"content-type"];	
	[request addValue:@"\"\"" forHTTPHeaderField:@"SOAPAction"];
	
	NSData *data = [payload dataUsingEncoding:NSUTF8StringEncoding];
	[request setHTTPBody:data];
	
	NSHTTPURLResponse *resp = nil;
	NSError *err = nil;
	// todo, support request compression
	// todo, support response compression
	NSData *respPayload = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&err];
	NSXMLDocument *doc = [[[NSXMLDocument alloc] initWithData:respPayload options:NSXMLNodeOptionsNone error:&err] autorelease];
	if (err != NULL) {
		@throw [NSException exceptionWithName:@"Xml error" reason:@"Unable to parse XML returned by server" userInfo:nil];
	}
	if (500 == [resp statusCode]) {
		NSXMLNode * nFaultCode = [[doc nodesForXPath:@"/soapenv:Envelope/soapenv:Body/soapenv:Fault/faultcode" error:&err] objectAtIndex:0];
		NSXMLNode * nFaultMsg  = [[doc nodesForXPath:@"/soapenv:Envelope/soapenv:Body/soapenv:Fault/faultstring" error:&err] objectAtIndex:0];
		ZKSoapException *exception = [ZKSoapException exceptionWithFaultCode:[nFaultCode stringValue] faultString:[nFaultMsg stringValue]];
		@throw exception;				
	}	
	NSXMLNode *body = [[doc nodesForXPath:@"/soapenv:Envelope/soapenv:Body" error:&err] objectAtIndex:0];
	return [[body children] objectAtIndex:0];
}

@end
