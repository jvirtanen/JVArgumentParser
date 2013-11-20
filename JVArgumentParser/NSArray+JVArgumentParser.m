#import "NSArray+JVArgumentParser.h"

@implementation NSArray (JVArgumentParser)

+ (instancetype) arrayWithCStrings:(const char **)cStrings
                             count:(NSUInteger)count
                          encoding:(NSStringEncoding)encoding
{
    NSMutableArray *array = [NSMutableArray array];

    for (unsigned int i = 0; i < count; i++)
        [array addObject:[NSString stringWithCString:cStrings[i] encoding:encoding]];

    return array;
}

@end