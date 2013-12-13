//
//  NSCalendar+Easy.m
//  iGuest
//
//  Created by Jayce Yang on 13-9-23.
//  Copyright (c) 2013年 FCS Shenzhen. All rights reserved.
//

#import "NSCalendar+Easy.h"

#import "Macro.h"

@implementation NSCalendar (Easy)

- (NSDateComponents *)dayComponentsFromDate:(NSDate *)date
{
    NSDateComponents *dateComponents = nil;
    @try {
        dateComponents = [self components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
    }
    @catch (NSException *exception) {
        DLog(@"%@", exception.reason);
    }
    @finally {
        return dateComponents;
    }
}

- (NSDateComponents *)timeComponentsFromDate:(NSDate *)date
{
    NSDateComponents *dateComponents = nil;
    @try {
        dateComponents = [self components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:date];
    }
    @catch (NSException *exception) {
        DLog(@"%@", exception.reason);
    }
    @finally {
        return dateComponents;
    }
}

@end
