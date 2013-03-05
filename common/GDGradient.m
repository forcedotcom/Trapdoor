// Green Dome Software
//
// Copyright (c) 2006 Timothy K. McIntosh
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or
// without modification, are permitted provided that the following
// conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright
// notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above
// copyright notice, this list of conditions and the following
// disclaimer in the documentation and/or other materials provided
// with the distribution.
// 3. Neither the name of the copyright holder nor the names of his
// contributors may be used to endorse or promote products derived
// from this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE
// COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
// LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
// ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

//
//  GDGradient.m
//
//      Wrapper class for Quartz shading functions.

#import "GDGradient.h"


static const float GDGradientHighlightMax   = 0.2222;   // 22.22%
static const float GDGradientShadowMax      = 0.4;      // 40%

static const float GDGradientHighlightEnd   = 0.6666;   // 66.66%
static const float GDGradientShadowStart    = 0.3333;   // 33.33%


@implementation GDGradient

// Function for blending one color with another (affine combination):
static void highlightColorWithFractionOfColor(float color[4], float fraction, const float highlight[4])
{
    int i;

    for (i = 0; i < 4; i++)
    {
        color[i] = fraction * highlight[i] + (1.0 - fraction) * color[i];
    }
}

// Evaluation callback for Quartz function object passed to CGShadingCreateAxial():
static void gradientShadingFunction
(
    void        *info, 
    const float *in, 
    float       *out
)
{
    GDGradient* gradient    = (GDGradient *)info;
    float       fraction    = (*in);

    // Return components:
    [gradient getGradientColorComponents: out forFraction: fraction];
}

- init 
{
    if (self = [super init])
    {
        [[[NSColor highlightColor] colorUsingColorSpaceName: NSCalibratedRGBColorSpace] getComponents: m_highlight];
        [[[NSColor shadowColor] colorUsingColorSpaceName: NSCalibratedRGBColorSpace] getComponents: m_shadow];

        // Create RGB color space object:
        m_colorSpace      = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
        
        // Create shading function object:
        m_shadingFunction = CGFunctionCreate (self,         // info
                                              1,                              // domainDimension
                                              (const float[2]) { 0, 1 },      // domain
                                              4,                              // rangeDimension
                                              (const float[8])                // range
                                              {
                                                  0, 1,
                                                  0, 1,
                                                  0, 1,
                                                  0, 1
                                              },
                                              &(const CGFunctionCallbacks)    // callbacks
                                              {
                                                  0,  // structure version
                                                  &gradientShadingFunction, 
                                                  NULL
                                              });
    }
    
    return self;
}

- (void)dealloc
{
    CGColorSpaceRelease(m_colorSpace);
    CGFunctionRelease(m_shadingFunction);
    
    [super dealloc];
}

- (NSColor *)color
{
    return m_color;
}

- (void)setColor:(NSColor *)color
{
    if (m_color != color)
    {
        color = [color colorUsingColorSpaceName: NSCalibratedRGBColorSpace];

        [m_color release];
        m_color = [color retain];
    }
}

// Note: Original implementation was written using NSColor methods, but this
//       is very slow since this method is called many times during display.
- (void)getGradientColorComponents:(float[4])components forFraction:(float)fraction
{
    NSColor*    color       = [self color];

    [color getComponents: components];

#ifndef FLAT
    // Blend shadow color, if needed:
    if (fraction >= GDGradientShadowStart)
    {
        float   shadow      = GDGradientShadowMax * GDGradientShadowMax * (fraction - GDGradientShadowStart) / (1.0 - GDGradientShadowStart);

        highlightColorWithFractionOfColor(components, shadow, m_shadow);
    }

    // Blend highlight color, if needed:
    if (fraction < GDGradientHighlightEnd)
    {
        float   highlight   = GDGradientHighlightMax - GDGradientHighlightMax * (fraction / GDGradientHighlightEnd);

        highlightColorWithFractionOfColor(components, highlight, m_highlight);
    }
#endif
}

- (NSColor *)gradientColorForFraction:(float)fraction
{
    struct
    {
        float red;
        float green;
        float blue;
        float alpha;
    }
    color;

    [self getGradientColorComponents: &color.red forFraction: fraction];

    return [NSColor colorWithCalibratedRed: color.red
                                     green: color.green
                                      blue: color.blue
                                     alpha: color.alpha];
}

- (void)fillRect:(NSRect)aRect
{
    CGShadingRef    shading;

    // Create shading object:
    shading = CGShadingCreateAxial(m_colorSpace,                    // colorspace
                                   CGPointMake(0, NSMinY(aRect)),   // start
                                   CGPointMake(0, NSMaxY(aRect)),   // end
                                   m_shadingFunction,               // function
                                   true,                            // extendStart
                                   true                             // extendEnd
                                   );

    [NSGraphicsContext saveGraphicsState];

    // Set clipping area:
    [[NSBezierPath bezierPathWithRect: aRect] addClip];

    CGContextDrawShading([[NSGraphicsContext currentContext] graphicsPort], shading);

    [NSGraphicsContext restoreGraphicsState];

    CGShadingRelease(shading);    
}

@end
