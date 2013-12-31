#import "JVArgumentParser.h"
#import "JVArgumentParserError.h"
#import "JVAwaitingArgument.h"
#import "JVOption.h"
#import "NSArray+JVArgumentParser.h"

@interface JVArgumentParser()
- (NSArray *)failWithCode:(NSInteger)code
                  context:(NSString *)context
                    error:(NSError **)error;
- (NSNumber *)keyForName:(unichar)name;
@end

@implementation JVArgumentParser {
    NSMutableDictionary *_options;
    NSMutableDictionary *_longOptions;
}

+ (instancetype)argumentParser
{
    return [[JVArgumentParser alloc] init];
}

- (instancetype)init
{
    _options = [NSMutableDictionary dictionary];
    _longOptions = [NSMutableDictionary dictionary];

    return self;
}

- (void)addOptionWithName:(unichar)name
              description:(NSString *)description
                    block:(JVOptionHandler)block
{
    JVOption *option = [JVOption optionWithBlock:block];

    [_options setObject:option forKey:[self keyForName:name]];
}

- (void)addOptionWithName:(unichar)name
              description:(NSString *)description
                    value:(BOOL *)value
{
    [self addOptionWithName:name description:description block:^{
        *value = TRUE;
    }];
}

- (void)addOptionWithLongName:(NSString *)longName
                  description:(NSString *)description
                        block:(JVOptionHandler)block
{
    JVOption *option = [JVOption optionWithBlock:block];

    [_longOptions setObject:option forKey:longName];
}

- (void)addOptionWithLongName:(NSString *)longName
                  description:(NSString *)description
                        value:(BOOL *)value
{
    [self addOptionWithLongName:longName description:description block:^{
        *value = TRUE;
    }];
}

- (void)addOptionWithName:(unichar)name
                 longName:(NSString *)longName
              description:(NSString *)description
                    block:(JVOptionHandler)block
{
    [self addOptionWithName:name description:description block:block];
    [self addOptionWithLongName:longName description:description block:block];
}

- (void)addOptionWithName:(unichar)name
                 longName:(NSString *)longName
              description:(NSString *)description
                    value:(BOOL *)value
{
    [self addOptionWithName:name description:description value:value];
    [self addOptionWithLongName:longName description:description value:value];
}

- (void)addOptionWithArgumentWithName:(unichar)name
                          description:(NSString *)description
                                block:(JVOptionWithArgumentHandler)block
{
    JVOption *option = [JVOption optionWithArgumentWithBlock:block];
    [_options setObject:option forKey:[self keyForName:name]];
}

- (void)addOptionWithArgumentWithName:(unichar)name
                          description:(NSString *)description
                                value:(NSString __strong **)value
{
    [self addOptionWithArgumentWithName:name
                            description:description
                                  block:^(NSString *argument){
        *value = argument;
    }];
}

- (void)addOptionWithArgumentWithLongName:(NSString *)longName
                              description:(NSString *)description
                                    block:(JVOptionWithArgumentHandler)block
{
    JVOption *option = [JVOption optionWithArgumentWithBlock:block];
    [_longOptions setObject:option forKey:longName];
}

- (void)addOptionWithArgumentWithLongName:(NSString *)longName
                              description:(NSString *)description
                                    value:(NSString __strong **)value
{
    [self addOptionWithArgumentWithLongName:longName
                                description:description
                                      block:^(NSString *argument){
        *value = argument;
    }];
}

- (void)addOptionWithArgumentWithName:(unichar)name
                             longName:(NSString *)longName
                          description:(NSString *)description
                                block:(JVOptionWithArgumentHandler)block
{
    [self addOptionWithArgumentWithName:name
                            description:description
                                  block:block];
    [self addOptionWithArgumentWithLongName:longName
                                description:description
                                      block:block];
}

- (void)addOptionWithArgumentWithName:(unichar)name
                             longName:(NSString *)longName
                          description:(NSString *)description
                                value:(NSString __strong **)value
{
    [self addOptionWithArgumentWithName:name
                            description:description
                                  value:value];
    [self addOptionWithArgumentWithLongName:longName
                                description:description
                                      value:value];
}

- (NSArray *)parse:(NSArray *)args
             error:(NSError **)error
{
    NSMutableArray *arguments = [NSMutableArray array];
    JVAwaitingArgument *awaitingArgument = nil;

    NSUInteger i;

    for (i = 0; i < args.count; i++) {
        NSString *arg = args[i];

        if (awaitingArgument != nil) {
            JVOptionWithArgumentHandler block = awaitingArgument.option.block;
            block(arg);

            awaitingArgument = nil;
            continue;
        }

        if ([arg isEqualToString:@"--"]) {
            i++;
            break;
        }

        if ([arg isEqualToString:@"-"]) {
            [arguments addObject:arg];
            continue;
        }

        if ([arg hasPrefix:@"--"]) {
            NSUInteger equalsIndex = [arg rangeOfString:@"="].location;
            if (equalsIndex != NSNotFound) {
                NSString *name = [arg substringWithRange:NSMakeRange(2, equalsIndex - 2)];
                JVOption *option = [_longOptions objectForKey:name];

                if (option == nil)
                    return [self failWithCode:JVArgumentParserErrorUnknownOption
                                      context:arg
                                        error:error];

                if (!option.hasArgument)
                    return [self failWithCode:JVArgumentParserErrorSuperfluousArgument
                                      context:arg
                                        error:error];

                if (equalsIndex == arg.length - 1)
                    return [self failWithCode:JVArgumentParserErrorMissingArgument
                                      context:arg
                                        error:error];

                JVOptionWithArgumentHandler block = option.block;
                block([arg substringFromIndex:equalsIndex + 1]);
            }
            else {
                NSString *name = [arg substringFromIndex:2];
                JVOption *option = [_longOptions objectForKey:name];

                if (option == nil)
                    return [self failWithCode:JVArgumentParserErrorUnknownOption
                                      context:arg
                                        error:error];

                if (option.hasArgument) {
                    awaitingArgument = [JVAwaitingArgument awaitingArgumentWithContext:arg
                                                                                option:option];
                } else {
                    JVOptionHandler block = option.block;
                    block();
                }
            }
        }
        else if ([arg hasPrefix:@"-"]) {
            for (NSUInteger j = 1; j < arg.length; j++) {
                unichar name = [arg characterAtIndex:j];
                JVOption *option = [_options objectForKey:[self keyForName:name]];

                if (option == nil)
                    return [self failWithCode:JVArgumentParserErrorUnknownOption
                                      context:arg
                                        error:error];

                if (option.hasArgument) {
                    if (arg.length > j + 1) {
                        JVOptionWithArgumentHandler block = option.block;
                        block([arg substringFromIndex:j + 1]);
                    } else {
                        awaitingArgument = [JVAwaitingArgument awaitingArgumentWithContext:arg
                                                                                    option:option];
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

    if (awaitingArgument != nil)
        return [self failWithCode:JVArgumentParserErrorMissingArgument
                          context:awaitingArgument.context
                            error:error];

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

- (NSArray *)failWithCode:(NSInteger)code
                  context:(NSString *)context
                    error:(NSError **)error
{
    if (error != nil) {
        NSString *message = JVArgumentParserErrorToString(code);
        NSString *localizedDescription = [NSString stringWithFormat:@"%@: %@", message, context];
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: localizedDescription};

        *error = [NSError errorWithDomain:JVArgumentParserErrorDomain
                                     code:code
                                 userInfo:userInfo];
    }

    return nil;
}

- (NSNumber *)keyForName:(unichar)name
{
    return [NSNumber numberWithUnsignedInteger:name];
}

@end