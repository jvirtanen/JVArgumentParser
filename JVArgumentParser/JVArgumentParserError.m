#import "JVArgumentParserError.h"

NSString *const JVArgumentParserErrorDomain = @"JVArgumentParser";

NSString *JVArgumentParserErrorToString(NSInteger code)
{
    switch (code) {
        case JVArgumentParserErrorUnknownOption:
            return @"Unknown option";

        case JVArgumentParserErrorMissingArgument:
            return @"Missing argument";

        case JVArgumentParserErrorSuperfluousArgument:
            return @"Superfluous argument";
    }

    return nil;
}