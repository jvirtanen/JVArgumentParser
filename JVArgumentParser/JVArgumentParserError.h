#import <Foundation/Foundation.h>

extern NSString *const JVArgumentParserErrorDomain;

#define JVArgumentParserErrorUnknownOption ((NSInteger)1)

#define JVArgumentParserErrorMissingArgument ((NSInteger)2)

#define JVArgumentParserErrorSuperfluousArgument ((NSInteger)3)

NSString *JVArgumentParserErrorToString(NSInteger code);