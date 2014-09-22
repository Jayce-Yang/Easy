//
//  NSSet+Easy.h
//  Easy
//
//  Created by Jayce Yang on 13-10-22.
//  Copyright (c) 2013年 Easy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSSet (Easy)

//sortDescriptorWithObjectID
- (NSArray *)sortedArrayUsingIndexOfWSDL;
- (NSArray *)sortedArrayUsingKeyPath:(NSString *)path;
- (NSArray *)sortedArrayUsingKeyPath:(NSString *)path ascending:(BOOL)ascending;

@end
