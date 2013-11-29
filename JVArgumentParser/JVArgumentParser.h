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
- (void)addOptionWithName:(unichar)name variable:(BOOL *)variable;
- (void)addOptionWithLongName:(NSString *)name block:(JVOptionHandler)block;
- (void)addOptionWithLongName:(NSString *)name variable:(BOOL *)variable;
- (void)addOptionWithArgumentWithName:(unichar)name block:(JVOptionWithArgumentHandler)block;
- (void)addOptionWithArgumentWithName:(unichar)name variable:(NSString __strong **)variable;
@end