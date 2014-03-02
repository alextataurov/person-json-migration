//
//  UIColor+MoreColors.h
//  PersonJSONMigration
//
//  Created by Alex Tataurov on 20/02/14.
//  Copyright (c) 2014 Alex Tataurov. All rights reserved.
//

#import <UIKit/UIKit.h>

//RGB color macro
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface UIColor (MoreColors)

+ (UIColor *)blueTextColor;

@end