#import "JVOption.h"

@implementation JVOption

+ (instancetype)optionWithName:(unichar)name block:(void (^)(void))block
{
    return [[self alloc] initWithName:name block:block argument:FALSE];
}

+ (instancetype)optionWithArgumentWithName:(unichar)name block:(void (^)(NSString *))block
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