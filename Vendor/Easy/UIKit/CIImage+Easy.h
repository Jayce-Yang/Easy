//
//  CIImage+Easy.h
//  Sales
//
//  Created by Jayce Yang on 14-8-28.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface CIImage (Easy)

+ (CIImage *)QRCodeImageFromString:(NSString *)string;

- (UIImage *)nonInterpolatedUIImageWitiScale:(CGFloat)scale;

@end
