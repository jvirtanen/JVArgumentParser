#import <Foundation/Foundation.h>

#import "JVArgumentParserError.h"
#import "JVOptionHandler.h"
#import "JVOptionWithArgumentHandler.h"

@interface JVArgumentParser : NSObject
+ (instancetype)argumentParser;
- (NSArray *)parse:(NSArray *)args error:(NSError **)error;
- (NSArray *)parseArgc:(int)argc
                  argv:(const char **)argv
              encoding:(NSStringEncoding)encoding
                 error:(NSError **)error;
- (void)addOptionWithName:(unichar)name block:(JVOptionHandler)block;
- (void)addOptionWithArgumentWithName:(unichar)name block:(JVOptionWithArgumentHandler)block;
@end