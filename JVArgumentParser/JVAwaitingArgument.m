#import "JVAwaitingArgument.h"

@implementation JVAwaitingArgument

+ (instancetype)awaitingArgumentWithContext:(NSString *)context
                                     option:(JVOption *)option
{
    return [[JVAwaitingArgument alloc] initWithContext:context
                                                option:option];
}

- (instancetype)initWithContext:(NSString *)context
                         option:(JVOption *)option
{
    _context = context;
    _option = option;

    return self;
}

@end