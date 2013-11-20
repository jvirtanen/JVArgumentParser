#import <Foundation/Foundation.h>

#import "JVOptionHandler.h"
#import "JVOptionWithArgumentHandler.h"

@interface JVOption : NSObject
@property (readonly) unichar name;
@property (readonly) id block;
@property (readonly) BOOL hasArgument;

+ (instancetype)optionWithName:(unichar)name block:(JVOptionHandler)block;
+ (instancetype)optionWithArgumentWithName:(unichar)name block:(JVOptionWithArgumentHandler)block;
- (instancetype)initWithName:(unichar)name
                       block:(id)block
                    argument:(BOOL)argument;
@end