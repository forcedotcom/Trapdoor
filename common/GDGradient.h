//
//  GDGradient.h
//

#import <Cocoa/Cocoa.h>


@interface GDGradient : NSObject
{
    CGColorSpaceRef m_colorSpace;
    CGFunctionRef   m_shadingFunction;
    NSColor*        m_color;
    float           m_highlight[4];
    float           m_shadow[4];
}
- (NSColor *)color;
- (void)setColor:(NSColor *)color;
- (void)getGradientColorComponents:(float[4])components forFraction:(float)fraction;
- (NSColor *)gradientColorForFraction:(float)fraction;
- (void)fillRect:(NSRect)aRect;
@end
