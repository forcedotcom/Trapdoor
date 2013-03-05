#import "StandAloneTableHeaderView.h"
#import "iTableColumnHeaderCell.h"

@implementation StandAloneTableHeaderView

// NSObject
-(id)initWithFrame:(NSRect)rect {
	[super initWithFrame:rect];
	textAttributes =  [[NSMutableDictionary dictionaryWithObjectsAndKeys:
						[NSFont titleBarFontOfSize:11.0], NSFontAttributeName,
						[NSColor blackColor], NSForegroundColorAttributeName,
						nil] retain];
	return self;
}

-(void)dealloc {
	[headerText release];
	[textAttributes release];
	[super dealloc];
}

// NSView
- (void)drawRect:(NSRect)rect {
	[super drawRect:rect];
	NSRect txtRect = NSOffsetRect(rect, 5,1);
	[headerText drawInRect:txtRect withAttributes:textAttributes];
}

// StandAloneTableHeaderView
-(void)setHeaderText:(NSString *)newValue {
	if (newValue != headerText) {
		[headerText release];
		headerText = [newValue retain];
	}
}

-(NSString *)headerText {
	return headerText;
}

- (BOOL)metalLook {
	return metalLook;
}

- (void)setMetalLook:(BOOL)newMetalLook {
	metalLook = newMetalLook;
}

@end
