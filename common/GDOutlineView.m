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
// GDOutlineView.m
//
//
//      Implements a "source list" outline view using GDSourceListCell.
//
//      The rows in the outline view are scaled according to the font size
//      used by the data cell of the outline column and the property
//      rowHeightToFontHeightRatio (default: 1.25).
//
//      GDSourceListCell scales the icons to the height of the rows, up to
//      the limit specified by the maxIconScale property (default: 1.0).

#import "GDOutlineView.h"
#import "GDGradient.h"


static NSString* const kOutlineCellFontKeyPath  = @"outlineTableColumn.dataCell.font";

@interface GDOutlineView (PrivateMethods)
- (void)adjustRowHeight;
- (void)windowKeyStatusDidChange:(NSNotification *)note;
@end


@implementation GDOutlineView (PrivateMethods)

// Adjusts row height according to font of outline column & selected ratio:
- (void)adjustRowHeight
{
    float fontSize = [[[[self outlineTableColumn] dataCell] font] pointSize];

    [self setRowHeight: floor([self rowHeightToFontHeightRatio] * fontSize)];
}

- (void)windowKeyStatusDidChange:(NSNotification *)note
{
    [self setNeedsDisplay];
}

@end


@implementation GDOutlineView

- (void)setUsesSaturatedSelectedColor:(BOOL)useSaturatedSelectedColor
{
    if (m_usesSaturatedSelectedColor != useSaturatedSelectedColor)
    {
        m_usesSaturatedSelectedColor = useSaturatedSelectedColor;

        [self setNeedsDisplay];
    }
}

- (BOOL)usesSaturatedSelectedColor
{
    return m_usesSaturatedSelectedColor;
}

- (void)setUsesSelectedControlColorWheneverWindowIsKey:(BOOL)useSelectedControlColorWheneverWindowIsKey
{
    if (m_usesSelectedControlColorWheneverWindowIsKey != useSelectedControlColorWheneverWindowIsKey)
    {
        if (useSelectedControlColorWheneverWindowIsKey)
        {
            // Start listening for changes to key window status:
            [[NSNotificationCenter defaultCenter] addObserver: self
                                                     selector: @selector(windowKeyStatusDidChange:)
                                                         name: NSWindowDidBecomeKeyNotification
                                                       object: [self window]];
            [[NSNotificationCenter defaultCenter] addObserver: self
                                                     selector: @selector(windowKeyStatusDidChange:)
                                                         name: NSWindowDidResignKeyNotification
                                                       object: [self window]];
        }
        else
        {
            // Stop listening for changes to key window status:
            [[NSNotificationCenter defaultCenter] removeObserver: self
                                                            name: NSWindowDidBecomeKeyNotification
                                                          object: [self window]];
            [[NSNotificationCenter defaultCenter] removeObserver: self
                                                            name: NSWindowDidResignKeyNotification
                                                          object: [self window]];
        }

        m_usesSelectedControlColorWheneverWindowIsKey = useSelectedControlColorWheneverWindowIsKey;

        [self setNeedsDisplay];
    }
}

- (BOOL)usesSelectedControlColorWheneverWindowIsKey
{
    return m_usesSelectedControlColorWheneverWindowIsKey;
}

// Determines the appropriate gradient color based on the current window state:
- (NSColor *)gradientColor
{
    NSColor*        color;
    BOOL            shouldUseSelectedControlColor = [[self window] isKeyWindow];

    if (![self usesSelectedControlColorWheneverWindowIsKey])
    {
        NSResponder*    r  = [[self window] firstResponder];

        // Only use selected control color when the control is selected:
        shouldUseSelectedControlColor =
            shouldUseSelectedControlColor &&
            [r isKindOfClass: [NSView class]] &&
            [(NSView*)r isDescendantOf: self];
    }

    if (shouldUseSelectedControlColor)
    {
        color = [NSColor alternateSelectedControlColor];

        if ([self usesSaturatedSelectedColor])
        {
            // Modify color as follows:
            //
            //   Saturation:    increase 10%
            //   Brightness:    increase 6.5%
            //
            // (Experimentally determined by comparing results to Finder's source list)

            color = [color colorUsingColorSpaceName: NSCalibratedRGBColorSpace];

            color = [NSColor colorWithCalibratedHue: [color hueComponent]
                                         saturation: [color saturationComponent] * 1.1
                                         brightness: [color brightnessComponent] * 1.065
                                              alpha: [color alphaComponent]];
        }
    }
    else
    {
        color = [NSColor disabledControlTextColor];
    }

    return color;
}

- (NSImage *)iconForRow:(int)rowIndex
{
    NSImage*    icon        = nil;
    id          delegate    = [self delegate];

    // Check delegate first:
    if ([delegate respondsToSelector: @selector(outlineView:iconOfItem:)])
    {
        icon = [[self delegate] outlineView: self iconOfItem: [self itemAtRow: rowIndex]];
    }

    // Then check dataSource:
    if (icon == nil)
    {
        icon = [[self dataSource] outlineView: self iconOfItem: [self itemAtRow: rowIndex]];
    }

    return icon;
}

- (float)maxIconScale
{
    return m_maxIconScale;
}

- (void)setMaxIconScale:(float)scale
{
    m_maxIconScale = scale;
    [self setNeedsDisplay];
}

- (float)rowHeightToFontHeightRatio
{
    return m_rowHeightToFontHeightRatio;
}

- (void)setRowHeightToFontHeightRatio:(float)ratio
{
    if (ratio < 1.375)
    {
        ratio = 1.375;
    }
    m_rowHeightToFontHeightRatio = ratio;
    [self adjustRowHeight];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // Watch for font updates:
    if (context == (void *)kOutlineCellFontKeyPath)
    {
        [self adjustRowHeight];
    }
}

// ----------------------------------------------------------------------------
#pragma mark Superclass Methods:
// ----------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder: decoder])
    {
        m_gradient = [[GDGradient alloc] init];

        [self setUsesSaturatedSelectedColor: YES];
//        [self setRowHeightToFontHeightRatio: 1.375]; // Finder small icons
        [self setRowHeightToFontHeightRatio: 2.0 + 2.0/3.0]; // Finder large icons
        [self setMaxIconScale: 1.0];

        // Monitor outline column font size for changes:
        [self addObserver: self
               forKeyPath: kOutlineCellFontKeyPath
                  options: NSKeyValueObservingOptionNew
                  context: kOutlineCellFontKeyPath];

        // Replace the NSTextFieldCell of the outline column with a
        // GDSourceListCell that is initialized with the same attributes:
        NSData*         archiverData    = [NSArchiver archivedDataWithRootObject: [[self outlineTableColumn] dataCell]];
        NSUnarchiver*   unarchiver      = [[[NSUnarchiver alloc] initForReadingWithData: archiverData] autorelease];

        [unarchiver decodeClassName: @"NSTextFieldCell" asClassName: @"GDSourceListCell"];

        [[self outlineTableColumn] setDataCell: [unarchiver decodeObject]];
    }

    return self;
}

- (void)dealloc
{
    [self removeObserver: self forKeyPath: kOutlineCellFontKeyPath];

    // Causes KVO for window key status to stop, if it is active:
    [self setUsesSelectedControlColorWheneverWindowIsKey: NO];

    [m_gradient release];

    [super dealloc];
}

// Column selection is not implemented:
- (BOOL)allowsColumnSelection
{
    return NO;
}

// Override private method of NSTableView, returning nil so that
// [NSOutlineView -drawRow:clipRect:] does not draw the normal highlight:
- (id)_highlightColorForCell:(NSCell *)cell
{
    return nil;
}

- (void)highlightSelectionInClipRect:(NSRect)clipRect
{
    NSRange     visibleRowIndexes   = [self rowsInRect: clipRect];
    NSIndexSet* selectedRowIndexes  = [self selectedRowIndexes];
    int         row;
    int         endRow;

    [m_gradient setColor: [self gradientColor]];

    // Iterate over visible rows:
    for (row = visibleRowIndexes.location, endRow = row + visibleRowIndexes.length; row < endRow ; row++)
    {
        // If row is selected, draw the gradient:
        if ([selectedRowIndexes containsIndex: row])
        {
            NSRect          rowRect     = [self rectOfRow: row];

            // Fill the rest:
            [m_gradient fillRect: rowRect];

            // Draw upper border:
            NSRect          borderRect  =
            {
                .origin = rowRect.origin,
                .size = NSMakeSize(NSWidth(rowRect), 1.0)
            };

            [[m_gradient gradientColorForFraction: 0.5] set];
            NSRectFill(borderRect);            
        }
    }
}

@end
