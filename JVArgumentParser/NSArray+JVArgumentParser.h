#import <Foundation/Foundation.h>

@interface NSArray (JVArgumentParser)
+ (instancetype) arrayWithCStrings:(const char **)cStrings
                             count:(NSUInteger)count
                          encoding:(NSStringEncoding)encoding;
@end