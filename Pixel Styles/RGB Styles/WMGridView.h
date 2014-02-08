//
//  WMGridView.h
//  Apero Studio HD
//
//  Created by William Markezana on 03/04/12.
//  Copyright (c) 2012 RGB Styles. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define GRID_WIDTH  2.0
#define GRID_WITH_DIV_2 GRID_WIDTH/2.0

@interface WMGridView : UIView

@property (nonatomic) CGSize size;

- (id)initWithFrame:(CGRect)frame gridSize:(CGSize)size;

@end
