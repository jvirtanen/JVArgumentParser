#import <Foundation/Foundation.h>

#import "JVOptionHandler.h"
#import "JVOptionWithArgumentHandler.h"

@interface JVOption : NSObject
@property (readonly) id block;
@property (readonly) BOOL hasArgument;

+ (instancetype)optionWithBlock:(JVOptionHandler)block;
+ (instancetype)optionWithArgumentWithBlock:(JVOptionWithArgumentHandler)block;
- (instancetype)initWithBlock:(id)block
                     argument:(BOOL)argument;
@end