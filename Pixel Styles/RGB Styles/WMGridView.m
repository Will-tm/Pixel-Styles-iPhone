//
//  WMGridView.m
//  Apero Studio HD
//
//  Created by William Markezana on 03/04/12.
//  Copyright (c) 2012 RGB Styles. All rights reserved.
//

#import "WMGridView.h"

@implementation WMGridView

@synthesize size = _size;

- (id)initWithFrame:(CGRect)frame gridSize:(CGSize)size
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _size = size;
        [self setOpaque: NO];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{    
    CGFloat step;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath (context);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.3 alpha:1.0].CGColor);
    CGContextSetLineWidth(context, GRID_WIDTH);
    
    CGContextMoveToPoint(context, 0.0, GRID_WITH_DIV_2);
    CGContextAddLineToPoint(context, self.frame.size.width-GRID_WITH_DIV_2, GRID_WITH_DIV_2);
    CGContextAddLineToPoint(context, self.frame.size.width-GRID_WITH_DIV_2, self.frame.size.height-GRID_WITH_DIV_2);
    CGContextAddLineToPoint(context, GRID_WITH_DIV_2, self.frame.size.height-GRID_WITH_DIV_2);
    CGContextAddLineToPoint(context, GRID_WITH_DIV_2, GRID_WITH_DIV_2);
    CGContextStrokePath(context);
    
    step = self.frame.size.width / _size.width;
    for (int x = 1; x < _size.width; x++)
    {
        CGContextMoveToPoint(context, 0.0 + x * step , GRID_WITH_DIV_2);
        CGContextAddLineToPoint(context, 0.0 + x * step , self.frame.size.height-GRID_WITH_DIV_2);
        CGContextStrokePath(context);
    }
    
    step = self.frame.size.height / _size.height;
    for (int y = 1; y < _size.height; y++)
    {
        CGContextMoveToPoint(context, GRID_WITH_DIV_2, 0.0 + y * step);
        CGContextAddLineToPoint(context, self.frame.size.width-GRID_WITH_DIV_2, 0.0 + y * step);
        CGContextStrokePath(context);
    }
}

@end
