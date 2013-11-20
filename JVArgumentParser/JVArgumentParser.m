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

    for (NSUInteger i = 0; i < args.count; i++) {
        NSString *arg = args[i];

        if (optionAwaitingArgument != nil) {
            JVOptionWithArgumentHandler block = optionAwaitingArgument.block;
            block(arg);

            optionAwaitingArgument = nil;
            continue;
        }

        if ((arg.length > 0) && ([arg characterAtIndex:0] == '-')) {
            if (optionAwaitingArgument != nil)
                return [self failWithCode:JVArgumentParserErrorMissingArgument error:error];

            if (arg.length == 1) {
                [arguments addObject:arg];
                continue;
            }

            unichar name = [arg characterAtIndex:1];
            JVOption *option = [_options objectForKey:[self keyForName:name]];

            if (option == nil)
                return [self failWithCode:JVArgumentParserErrorUnknownOption error:error];

            if (arg.length > 2)
                return [self failWithCode:JVArgumentParserErrorUnknownOption error:error];

            if (option.hasArgument) {
                optionAwaitingArgument = option;
            } else {
                JVOptionHandler block = option.block;
                block();
            }
        } else {
            [arguments addObject:arg];
        }
    }

    if (optionAwaitingArgument != nil)
        return [self failWithCode:JVArgumentParserErrorMissingArgument error:error];

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
    JVOption *option = [JVOption optionWithName:name block:block];

    [_options setObject:option forKey:[self keyForName:name]];
}

- (void)addOptionWithArgumentWithName:(unichar)name block:(JVOptionWithArgumentHandler)block
{
    JVOption *option = [JVOption optionWithArgumentWithName:name block:block];
    [_options setObject:option forKey:[self keyForName:name]];
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