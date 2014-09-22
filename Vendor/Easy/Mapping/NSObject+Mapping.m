//  NSObject+Mapping.h
//  Easy
//
//  Created by Jayce Yang on 13-10-16.
//  Copyright (c) 2013年 Easy. All rights reserved.
//

#import <objc/runtime.h>

#import "NSObject+Mapping.h"

static char ClassNamesInArrayKey;
static char SourceKeyPathMappingKey;
static char TargetKeyPathMappingKey;
//static char PropertyIndexKey;
//static char DateFormatKey;

NSString * const DefaultDateFormat = @"yyyy-MM-dd'T'HH:mm:ss.sssZ";
NSString * const DefaultDateFormatCompatible = @"yyyy-MM-dd HH:mm:ss";

@interface NSObject (MappingPrivate)

@property (strong, nonatomic) NSMutableDictionary *classNamesInArray;
@property (strong, nonatomic) NSMutableDictionary *sourcekeyPathMapping;
@property (strong, nonatomic) NSMutableDictionary *targetKeyPathMapping;
//@property (copy, nonatomic) NSNumber *propertyIndex;



@end

@implementation NSObject (MappingPrivate)

- (NSMutableDictionary *)classNamesInArray
{
    return objc_getAssociatedObject(self, &ClassNamesInArrayKey);
}

- (void)setClassNamesInArray:(NSMutableDictionary *)classNamesInArray
{
    [self willChangeValueForKey:@"classNamesInArray"];
    objc_setAssociatedObject(self, &ClassNamesInArrayKey, classNamesInArray, OBJC_ASSOCIATION_RETAIN);
    [self didChangeValueForKey:@"classNamesInArray"];
}

- (NSMutableDictionary *)sourcekeyPathMapping
{
    return objc_getAssociatedObject(self, &SourceKeyPathMappingKey);
}

- (void)setSourcekeyPathMapping:(NSMutableDictionary *)sourcekeyPathMapping
{
    [self willChangeValueForKey:@"sourcekeyPathMapping"];
    objc_setAssociatedObject(self, &SourceKeyPathMappingKey, sourcekeyPathMapping, OBJC_ASSOCIATION_RETAIN);
    [self didChangeValueForKey:@"sourcekeyPathMapping"];
}

- (NSMutableDictionary *)targetKeyPathMapping
{
    return objc_getAssociatedObject(self, &TargetKeyPathMappingKey);
}

- (void)setTargetKeyPathMapping:(NSMutableDictionary *)targetKeyPathMapping
{
    [self willChangeValueForKey:@"targetKeyPathMapping"];
    objc_setAssociatedObject(self, &TargetKeyPathMappingKey, targetKeyPathMapping, OBJC_ASSOCIATION_RETAIN);
    [self didChangeValueForKey:@"targetKeyPathMapping"];
}

//- (NSString *)propertyIndex
//{
//    return objc_getAssociatedObject(self, &PropertyIndexKey);
//}
//
//- (void)setPropertyIndex:(NSString *)propertyIndex
//{
//    [self willChangeValueForKey:@"propertyIndex"];
//    objc_setAssociatedObject(self, &PropertyIndexKey, propertyIndex, OBJC_ASSOCIATION_COPY_NONATOMIC);
//    [self didChangeValueForKey:@"propertyIndex"];
//}

//- (NSString *)dateFormat
//{
//    return objc_getAssociatedObject(self, &DateFormatKey);
//}
//
//- (void)setDateFormat:(NSString *)dateFormat
//{
//    [self willChangeValueForKey:@"dateFormat"];
//    objc_setAssociatedObject(self, &DateFormatKey, dateFormat, OBJC_ASSOCIATION_COPY_NONATOMIC);
//    [self didChangeValueForKey:@"dateFormat"];
//}

@end

@interface NSString (MappingPrivate)

- (BOOL)stringType;
- (BOOL)numberType;
- (BOOL)dateType;
- (BOOL)dictionaryType;
- (BOOL)arrayType;
- (BOOL)JSONType;

@end

@implementation NSString (MappingPrivate)

- (NSDate *)dateValue
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone defaultTimeZone];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.dateFormat = DefaultDateFormat;
    NSDate *date = [dateFormatter dateFromString:self];
    if (date == nil) {
        dateFormatter.dateFormat = DefaultDateFormatCompatible;
        date = [dateFormatter dateFromString:self];
    }
    return date;
}

- (NSNumber *)numberValue
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [numberFormatter numberFromString:self];
}

- (BOOL)stringType
{
    return ([self isEqualToString:@"T@\"NSString\""]);
}

- (BOOL)numberType
{
    return ([self isEqualToString:@"T@\"NSNumber\""]);
}

- (BOOL)dateType
{
    return ([self isEqualToString:@"T@\"NSDate\""]);
}

- (BOOL)dictionaryType
{
    return ([self isEqualToString:@"T@\"NSDictionary\""]);
}

- (BOOL)arrayType
{
    return ([self isEqualToString:@"T@\"NSArray\""]);
}

- (BOOL)JSONType
{
    return ([self stringType] || [self numberType]);
}

@end

@interface NSDate (MappingPrivate)

//- (NSString *)stringValue;

@end

@implementation NSDate (MappingPrivate)

- (NSString *)stringValue
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone defaultTimeZone];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.dateFormat = DefaultDateFormat;
    return [dateFormatter stringFromDate:self];
}

@end

@interface NSArray (Mapping)

- (NSArray *)makeObjectsDictionaryValue;

@end

@implementation NSArray (Mapping)

- (NSArray *)makeObjectsDictionaryValue
{
    NSMutableArray *result = [NSMutableArray array];
    
    @try {
        for (NSUInteger counter = 0; counter < self.count; counter ++) {
            @autoreleasepool {
                id object = [self objectAtIndex:counter];
                
                if ([object isKindOfClass:[NSArray class]]) {
                    [result addObject:[object makeObjectsDictionaryValue]];
                } else if ([object isKindOfClass:[NSDate class]]){
                    [result addObject:[object stringValue]];
                } else if ([object isKindOfClass:[NSString class]]){
                    [result addObject:[NSString stringWithFormat:@"\"%@\"", object]];
                } else if ([object isKindOfClass:[NSNumber class]]) {
                    [result addObject:object];
                } else {
                    [result addObject:[object dictionaryValue]];
                }
            }
        }
    }
    @catch (NSException *exception) {
//        NSLog(@"%@", exception.reason);
    }
    @finally {
        return result;
    }
}

@end


@implementation NSObject (Mapping)

+ (NSSortDescriptor *)sortDescriptorForPropertyIndex
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"propertyIndex" ascending:YES];
    
    return sortDescriptor;
}

- (NSDictionary *)dictionaryValue
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    for (NSUInteger counter = 0; counter < count; counter ++) {
        @autoreleasepool {
            
            NSString *propertyName = [NSString stringWithUTF8String:property_getName(properties[counter])];
//            propertyName.propertyIndex = [NSNumber numberWithInteger:counter];
            id value = [self valueForKey:propertyName];
//            NSLog(@"%@:\t%@", key, NSStringFromClass([value class]));
            
            NSString *targetKey = [[self targetKeyPathMapping] objectForKey:propertyName];
            if (targetKey.length > 0) {
                propertyName = targetKey;
            }
            
            if ([value isKindOfClass:[NSArray class]]) {
                [dictionary setValue:[value makeObjectsDictionaryValue] forKey:propertyName];
            } else if ([value isKindOfClass:[NSDictionary class]]){
                [dictionary setValue:value forKey:propertyName];
            } else if ([value isKindOfClass:[NSDate class]]){
                [dictionary setValue:[value stringValue] forKey:propertyName];
            } else if ([value isKindOfClass:[NSString class]]){
                [dictionary setValue:value forKey:propertyName];
            }  else if ([value isKindOfClass:[NSNumber class]]) {
                [dictionary setValue:value forKey:propertyName];
            } else if ([value isKindOfClass:[NSData class]]){
                [dictionary setValue:[[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding] forKey:propertyName];
            } else if ([value isKindOfClass:[NSNull class]]){
                [dictionary setValue:nil forKey:propertyName];
            } else {
                [dictionary setValue:[value dictionaryValue] forKey:propertyName];
            }
        }
    }
    
    free(properties);
    
    return [NSDictionary dictionaryWithDictionary:dictionary];
}

- (NSData *)JSONData
{
    NSDictionary *dictionary = [self dictionaryValue];
    return [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
}

- (NSString *)JSONString
{
    NSDictionary *dictionary = [self dictionaryValue];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (void)setClass:(Class)aClass ofObjectsInArrayForKeyPath:(NSString *)path
{
    if (self.classNamesInArray == nil) {
        self.classNamesInArray = [NSMutableDictionary dictionary];
    }
    
    [self.classNamesInArray setValue:NSStringFromClass(aClass) forKey:path];
}

- (void)makePropertyNamesMappingForKey:(NSString *)key sourceKey:(NSString *)sourceKey
{
    if (self.sourcekeyPathMapping == nil) {
        self.sourcekeyPathMapping = [NSMutableDictionary dictionary];
    }
    
    [self.sourcekeyPathMapping setValue:sourceKey forKey:key];
}

- (void)makePropertyNamesMappingForKey:(NSString *)key targetKey:(NSString *)targetKey
{
    if (self.targetKeyPathMapping == nil) {
        self.targetKeyPathMapping = [NSMutableDictionary dictionary];
    }
    
    [self.targetKeyPathMapping setValue:targetKey forKey:key];
}

- (id)valueOfClass:(Class)aClass forJSONDictionary:(NSDictionary *)dictionary
{
    if (aClass) {
        id result = [[aClass alloc] init];
        
        @try {
            NSDictionary *properties = [result propertyDictionary];
            
            for (NSString *propertyName in [properties allKeys]) {
                
                @autoreleasepool {
                    
                    NSString *sourceKey = [[result sourcekeyPathMapping] objectForKey:propertyName];
                    if (sourceKey.length == 0) {
                        sourceKey = propertyName;
                    }
                    
                    id object = [dictionary objectForKey:sourceKey];
                    if (!object) {
                        continue;
                    }
                    
                    objc_property_t property = class_getProperty(aClass, [propertyName UTF8String]);
                    NSString *attribute = [result attributeFromProperty:property];
                    
                    // string
                    if ([attribute stringType]) {
                        if (object != [NSNull null]) {
                            if ([object isKindOfClass:[NSNumber class]]) {
                                [result setValue:[object stringValue] forKey:propertyName];
                            } else {
                                [result setValue:object forKey:propertyName];
                            }
                        } else {
                            [result setValue:nil forKey:propertyName];
                        }
                    }
                    
                    // number
                    else if ([attribute numberType]) {
                        if (object != [NSNull null]) {
                            if ([object isKindOfClass:[NSString class]]) {
                                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                                [numberFormatter setNumberStyle:NSNumberFormatterNoStyle];
                                [result setValue:[numberFormatter numberFromString:object] forKey:propertyName];
                            } else {
                                [result setValue:object forKey:propertyName];
                            }
                        } else {
                            [result setValue:nil forKey:propertyName];
                        }
                    }
                    
                    // date
                    else if ([attribute dateType]) {
                        [result setValue:[object dateValue] forKey:propertyName];
                    }
                    
                    // dictionary
                    else if ([attribute dictionaryType]) {
                        if ([object isKindOfClass:[NSDictionary class]]) {
                            [result setValue:object forKey:propertyName];
                        }
                    }
                    
                    // array
                    else if ([attribute arrayType]) {
                        NSString *propertyType = [[result classNamesInArray] objectForKey:propertyName];
                        [result setValue:[self valueOfClass:NSClassFromString(propertyType) forJSONArray:object] forKey:propertyName];
                    }
                    
                    // custom class
                    else {
                        NSString *propertyType = [result classOfPropertyNamed:propertyName];
                        [result setValue:[self valueOfClass:NSClassFromString(propertyType) forJSONDictionary:object] forKey:propertyName];
                    }
                }
            }
        }
        @catch (NSException *exception) {
//            NSLog(@"%@", exception.reason);
        }
        @finally {
            return result;
        }
    } else {
        return nil;
    }
}

- (NSArray *)valueOfClass:(Class)aClass forJSONArray:(NSArray *)array
{
    if (aClass) {
        // Set Up
        NSMutableArray *result = [NSMutableArray array];
        
        @try {
            // Create objects
            NSUInteger count = [array count];
            for (NSUInteger counter = 0; counter < count; counter ++) {
                
                @autoreleasepool {
                    
                    id object = [array objectAtIndex:counter];
                    
                    if ([aClass isSubclassOfClass:[NSString class]]) {
                        if ([object isKindOfClass:[NSString class]]) {
                            [result addObject:object];
                        } else if ([aClass isSubclassOfClass:[NSNumber class]]) {
                            [result addObject:[object stringValue]];
                        }
                    } else if ([aClass isSubclassOfClass:[NSNumber class]]) {
                        if ([object isKindOfClass:[NSNumber class]]) {
                            [result addObject:object];
                        } else if ([aClass isSubclassOfClass:[NSString class]]) {
                            [result addObject:[object numberValue]];
                        }
                    } else if ([aClass isSubclassOfClass:[NSDate class]]) {
                        if ([object isKindOfClass:[NSString class]]) {
                            [result addObject:[object dateValue]];
                        }
                    } else if ([aClass isSubclassOfClass:[NSDictionary class]]) {
                        if ([object isKindOfClass:[NSDictionary class]]) {
                            [result addObject:object];
                        }
                    } else if ([aClass isSubclassOfClass:[NSArray class]]) {
                        if ([object isKindOfClass:[NSArray class]]) {
                            [result addObject:[self valueOfClass:aClass forJSONArray:object]];
                        }
                    } else {
                        if ([object isKindOfClass:[NSDictionary class]]) {
                            [result addObject:[self valueOfClass:aClass forJSONDictionary:object]];
                        }
                    }
                }
            }
        }
        @catch (NSException *exception) {
//            NSLog(@"%@", exception.reason);
        }
        @finally {
            // This is now an Array of objects
            return [NSArray arrayWithArray:result];
        }
    } else {
        return nil;
    }
}

#pragma mark - Dictionary to Object

- (NSString *)classOfPropertyNamed:(NSString *)propName
{
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    for (unsigned xx = 0; xx < count; xx++) {
        @autoreleasepool {
            if ([[NSString stringWithUTF8String:property_getName(properties[xx])] isEqualToString:propName]) {
                NSString *className = [NSString stringWithFormat:@"%s", getPropertyType(properties[xx])];
                free(properties);
                return className;
            }
        }
    }
    
    return nil;
}


static const char * getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            // it's a primitive type
            return (const char *)[[NSData dataWithBytes:(attribute + 1) length:strlen(attribute) - 1] bytes];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            // it's an ObjC id type:
            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            // it's another ObjC object type:
            return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
        }
    }
    return "";
}

- (NSDictionary *)propertyDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    for (unsigned i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
//        key.propertyIndex = [NSNumber numberWithInt:i];
        [dict setObject:key forKey:key];
    }
    
    free(properties);
    
    // Add all superclass properties as well, until it hits NSObject
    NSString *superClassName = NSStringFromClass([self superclass]);
    if (![superClassName isEqualToString:NSStringFromClass([NSObject class])]) {
        for (NSString *property in [[[self superclass] propertyDictionary] allKeys]) {
            @autoreleasepool {
                [dict setObject:property forKey:property];
            }
        }
    }
    
    return dict;
}

- (NSString *)attributeFromProperty:(objc_property_t)property
{
    if (property) {
        return [[NSString stringWithUTF8String:property_getAttributes(property)] componentsSeparatedByString:@","][0];
    } else {
        return nil;
    }
}

@end
