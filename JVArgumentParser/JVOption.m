#import "JVOption.h"

@implementation JVOption

+ (instancetype)optionWithName:(unichar)name block:(JVOptionHandler)block
{
    return [[self alloc] initWithName:name block:block argument:FALSE];
}

+ (instancetype)optionWithArgumentWithName:(unichar)name block:(JVOptionWithArgumentHandler)block
{
    return [[self alloc] initWithName:name block:block argument:TRUE];
}

- (instancetype)initWithName:(unichar)name block:(id)block argument:(BOOL)argument
{
    _name = name;
    _block = block;
    _hasArgument = argument;

    return self;
}
                                                           
@end