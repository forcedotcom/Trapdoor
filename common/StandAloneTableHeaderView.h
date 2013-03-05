/* StandAloneTableHeaderView */

#import <Cocoa/Cocoa.h>

@interface StandAloneTableHeaderView : NSTableHeaderView {
	NSString 		*headerText;
	NSDictionary 	*textAttributes;
	BOOL			metalLook;
}

-(void)setHeaderText:(NSString *)newValue;
-(NSString *)headerText;
- (BOOL)metalLook;
- (void)setMetalLook:(BOOL)newMetalLook;

@end
