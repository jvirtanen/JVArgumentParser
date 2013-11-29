#import "JVArgumentParser.h"
#import "JVArgumentParserError.h"
#import "JVOption.h"
#import "NSArray+JVArgumentParser.h"

@interface JVArgumentParser()
- (NSArray *)failWithCode:(NSInteger)code error:(NSError **)error;
- (NSNumber *)keyForName:(unichar)name;
@end

@implementation JVArgumentParser {
    NSMutableDictionary *_options;
}

+ (instancetype)argumentParser
{
    return [[JVArgumentParser alloc] init];
}

- (instancetype)init
{
    _options = [NSMutableDictionary dictionary];

    return self;
}

- (NSArray *)parse:(NSArray *)args error:(NSError **)error
{
    NSMutableArray *arguments = [NSMutableArray array];
    JVOption *optionAwaitingArgument = nil;

    NSUInteger i;

    for (i = 0; i < args.count; i++) {
        NSString *arg = args[i];

        if (optionAwaitingArgument != nil) {
            JVOptionWithArgumentHandler block = optionAwaitingArgument.block;
            block(arg);

            optionAwaitingArgument = nil;
            continue;
        }

        if ([arg isEqualToString:@"--"]) {
            i++;
            break;
        }

        if ((arg.length > 0) && ([arg characterAtIndex:0] == '-')) {
            if (arg.length == 1) {
                [arguments addObject:arg];
                continue;
            }

            for (NSUInteger j = 1; j < arg.length; j++) {
                unichar name = [arg characterAtIndex:j];
                JVOption *option = [_options objectForKey:[self keyForName:name]];

                if (option == nil)
                    return [self failWithCode:JVArgumentParserErrorUnknownOption error:error];

                if (option.hasArgument) {
                    if (arg.length > j + 1) {
                        JVOptionWithArgumentHandler block = option.block;
                        block([arg substringFromIndex:j + 1]);
                    } else {
                        optionAwaitingArgument = option;
                    }
                    break;
                } else {
                    JVOptionHandler block = option.block;
                    block();
                }
            }
        } else {
            [arguments addObject:arg];
        }
    }

    if (optionAwaitingArgument != nil)
        return [self failWithCode:JVArgumentParserErrorMissingArgument error:error];

    while (i < args.count)
        [arguments addObject:args[i++]];

    return arguments;
}

- (NSArray *)parseArgc:(int)argc
                  argv:(const char **)argv
              encoding:(NSStringEncoding)encoding
                 error:(NSError **)error
{
    NSArray *arguments = [NSArray arrayWithCStrings:argv count:argc encoding:encoding];

    return [self parse:[arguments subarrayWithRange:NSMakeRange(1, arguments.count - 1)] error:error];
}

- (void)addOptionWithName:(unichar)name block:(JVOptionHandler)block
{
    JVOption *option = [JVOption optionWithBlock:block];

    [_options setObject:option forKey:[self keyForName:name]];
}

- (void)addOptionWithName:(unichar)name variable:(BOOL *)variable
{
    [self addOptionWithName:name block:^{
        *variable = TRUE;
    }];
}

- (void)addOptionWithArgumentWithName:(unichar)name block:(JVOptionWithArgumentHandler)block
{
    JVOption *option = [JVOption optionWithArgumentWithBlock:block];
    [_options setObject:option forKey:[self keyForName:name]];
}

- (void)addOptionWithArgumentWithName:(unichar)name variable:(NSString __strong **)variable
{
    [self addOptionWithArgumentWithName:name block:^(NSString *argument){
        *variable = argument;
    }];
}

- (NSArray *)failWithCode:(NSInteger)code error:(NSError **)error
{
    if (error != nil)
        *error = [NSError errorWithDomain:JVArgumentParserErrorDomain code:code userInfo:nil];

    return nil;
}

- (NSNumber *)keyForName:(unichar)name
{
    return [NSNumber numberWithUnsignedInteger:name];
}

@end