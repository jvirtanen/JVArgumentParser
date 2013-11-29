#import "JVOption.h"

@implementation JVOption

+ (instancetype)optionWithBlock:(JVOptionHandler)block
{
    return [[self alloc] initWithBlock:block argument:FALSE];
}

+ (instancetype)optionWithArgumentWithBlock:(JVOptionWithArgumentHandler)block
{
    return [[self alloc] initWithBlock:block argument:TRUE];
}

- (instancetype)initWithBlock:(id)block argument:(BOOL)argument
{
    _block = block;
    _hasArgument = argument;

    return self;
}
                                                           
@end