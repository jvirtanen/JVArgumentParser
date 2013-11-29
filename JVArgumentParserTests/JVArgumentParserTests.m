#import <XCTest/XCTest.h>

#import "JVArgumentParser.h"

@interface JVArgumentParserTests : XCTestCase
@end

@implementation JVArgumentParserTests {
    JVArgumentParser *parser;
}

- (void)setUp
{
    [super setUp];

    parser = [JVArgumentParser argumentParser];
}

- (void)testOption
{
    __block BOOL a = FALSE;

    [parser addOptionWithName:'a' block:^{
        a = TRUE;
    }];

    NSArray *arguments = [parser parse:@[@"-a"] error:nil];

    XCTAssertEqualObjects(arguments, @[], @"There should be no arguments");
    XCTAssertTrue(a, @"Option '-a' should be parsed");
}

- (void)testOptionWithArgument
{
    __block NSString *a = nil;

    [parser addOptionWithArgumentWithName:'a' block:^(NSString *argument){
        a = argument;
    }];

    NSArray *arguments = [parser parse:@[@"-a", @"foo"] error:nil];

    XCTAssertEqualObjects(arguments, @[], @"There should be no arguments");
    XCTAssertEqualObjects(a, @"foo", @"Option '-a' should be parsed");
}

- (void)testOptionWithArgumentWithoutOptionalSpaceInBetween
{
    __block NSString *a = nil;

    [parser addOptionWithArgumentWithName:'a' block:^(NSString *argument){
        a = argument;
    }];

    NSArray *arguments = [parser parse:@[@"-afoo"] error:nil];

    XCTAssertEqualObjects(arguments, @[], @"There should be no arguments");
    XCTAssertEqualObjects(a, @"foo", @"Option '-a' should be parsed");
}

- (void)testOptionGroup
{
    __block BOOL a = FALSE;
    __block BOOL b = FALSE;
    __block BOOL c = FALSE;

    [parser addOptionWithName:'a' block:^{
        a = TRUE;
    }];

    [parser addOptionWithName:'b' block:^{
        b = TRUE;
    }];

    [parser addOptionWithName:'c' block:^{
        c = TRUE;
    }];

    NSArray *arguments = [parser parse:@[@"-ab"] error:nil];

    XCTAssertEqualObjects(arguments, @[], @"There should be no arguments");
    XCTAssertTrue(a, @"Option '-a' should be parsed");
    XCTAssertTrue(b, @"Option '-b' should be parsed");
    XCTAssertFalse(c, @"Option '-c' should not be parsed");
}

- (void)testOptionGroupTerminatedByOptionWithArgument
{
    __block BOOL a = FALSE;
    __block BOOL b = FALSE;
    __block NSString *c = nil;

    [parser addOptionWithName:'a' block:^{
        a = TRUE;
    }];

    [parser addOptionWithName:'b' block:^{
        b = TRUE;
    }];

    [parser addOptionWithArgumentWithName:'c' block:^(NSString *argument){
        c = argument;
    }];

    NSArray *arguments = [parser parse:@[@"-abc", @"foo"] error:nil];

    XCTAssertEqualObjects(arguments, @[], @"There should be no arguments");
    XCTAssertTrue(a, @"Option '-a' should be parsed");
    XCTAssertTrue(b, @"Option '-b' should be parsed");
    XCTAssertEqualObjects(c, @"foo", @"Option '-c' should be parsed");
}

- (void)testOptionGroupTerminatedByOptionWithArgumentWithoutOptionalSpaceInBetween
{
    __block BOOL a = FALSE;
    __block BOOL b = FALSE;
    __block NSString *c = nil;

    [parser addOptionWithName:'a' block:^{
        a = TRUE;
    }];

    [parser addOptionWithName:'b' block:^{
        b = TRUE;
    }];

    [parser addOptionWithArgumentWithName:'c' block:^(NSString *argument){
        c = argument;
    }];

    NSArray *arguments = [parser parse:@[@"-abcfoo"] error:nil];

    XCTAssertEqualObjects(arguments, @[], @"There should be no arguments");
    XCTAssertTrue(a, @"Option '-a' should be parsed");
    XCTAssertTrue(b, @"Option '-b' should be parsed");
    XCTAssertEqualObjects(c, @"foo", @"Option '-c' should be parsed");
}

- (void)testOptionGroupWithOptionWithArgument
{
    __block BOOL a = FALSE;
    __block NSString *b = nil;
    __block BOOL c = FALSE;

    [parser addOptionWithName:'a' block:^{
        a = TRUE;
    }];

    [parser addOptionWithArgumentWithName:'b' block:^(NSString *argument) {
        b = argument;
    }];

    [parser addOptionWithName:'c' block:^{
        c = TRUE;
    }];

    NSArray *arguments = [parser parse:@[@"-abc"] error:nil];

    XCTAssertEqualObjects(arguments, @[], @"There should be no arguments");
    XCTAssertTrue(a, @"Option '-a' should be parsed");
    XCTAssertEqualObjects(b, @"c", @"Option '-b' should be parsed");
    XCTAssertFalse(c, @"Option '-c' should not be parsed");
}

- (void)testEndOfOptions
{
    __block BOOL a = FALSE;
    __block BOOL b = FALSE;

    [parser addOptionWithName:'a' block:^{
        a = TRUE;
    }];

    [parser addOptionWithName:'b' block:^{
        b = TRUE;
    }];

    NSArray *arguments = [parser parse:@[@"-a", @"--", @"-b"] error:nil];

    XCTAssertEqualObjects(arguments, @[@"-b"], @"There should be arguments");
    XCTAssertTrue(a, @"Option '-a' should be parsed");
    XCTAssertFalse(b, @"Option '-b' should not be parsed");
}

- (void)testParsing
{
    __block NSString *d = nil;
    __block NSString *f = nil;

    [parser addOptionWithArgumentWithName:'d' block:^(NSString *argument){
        d = argument;
    }];

    [parser addOptionWithArgumentWithName:'f' block:^(NSString *argument){
        f = argument;
    }];

    NSArray *arguments = [parser parse:@[@"-f", @"1,3", @"-d", @",", @"foo.csv"] error:nil];

    XCTAssertEqualObjects(arguments, @[@"foo.csv"], @"There should be arguments");
    XCTAssertEqualObjects(d, @",", @"Option '-d' should be parsed");
    XCTAssertEqualObjects(f, @"1,3", @"Option '-f' should be parsed");
}

- (void)testParsingArgcArgv
{
    __block NSString *d = nil;
    __block NSString *f = nil;

    [parser addOptionWithArgumentWithName:'d' block:^(NSString *argument){
        d = argument;
    }];

    [parser addOptionWithArgumentWithName:'f' block:^(NSString *argument){
        f = argument;
    }];

    int argc = 6;
    const char *argv[] = { "/usr/bin/cut", "-f", "1,3", "-d", ",", "foo.csv" };

    NSArray *arguments = [parser parseArgc:argc argv:argv encoding:NSUTF8StringEncoding error:nil];

    XCTAssertEqualObjects(arguments, @[@"foo.csv"], @"There should be arguments");
    XCTAssertEqualObjects(d, @",", @"Option '-d' should be parsed");
    XCTAssertEqualObjects(f, @"1,3", @"Option '-f' should be parsed");
}

- (void)testMissingOptionArgument
{
    NSError *error = nil;

    [parser addOptionWithArgumentWithName:'a' block:^(NSString *argument){
    }];

    NSArray *arguments = [parser parse:@[@"-a"] error:&error];

    XCTAssertNil(arguments, @"There should be no arguments");
    XCTAssertNotNil(error, @"There should be an error");
    XCTAssertEqualObjects(error.domain, JVArgumentParserErrorDomain, @"Wrong error domain");
    XCTAssertEqual(error.code, JVArgumentParserErrorMissingArgument, @"Wrong error code");
}

- (void)testMissingOptionArgumentBetweenOptions
{
    __block NSString *a = nil;
    __block BOOL b = FALSE;

    [parser addOptionWithArgumentWithName:'a' block:^(NSString *argument){
        a = argument;
    }];

    [parser addOptionWithName:'b' block:^{
        b = TRUE;
    }];

    NSArray *arguments = [parser parse:@[@"-a", @"-b"] error:nil];

    XCTAssertEqualObjects(arguments, @[], @"There should be no arguments");
    XCTAssertEqualObjects(a, @"-b", @"Option '-a' should be parsed");
    XCTAssertFalse(b, @"Option '-b' should not be parsed");
}

- (void)testUnknownOption
{
    NSError *error = nil;

    NSArray *arguments = [parser parse:@[@"-a"] error:&error];

    XCTAssertNil(arguments, @"There should be no arguments");
    XCTAssertNotNil(error, @"There should be an error");
    XCTAssertEqualObjects(error.domain, JVArgumentParserErrorDomain, @"Unknown error domain");
    XCTAssertEqual(error.code, JVArgumentParserErrorUnknownOption, @"Unknown error code");
}

- (void)testUnknownOptionInGroup
{
    NSError *error = nil;

    [parser addOptionWithName:'a' block:^{
    }];

    NSArray *arguments = [parser parse:@[@"-ab"] error:&error];

    XCTAssertNil(arguments, @"There should be no arguments");
    XCTAssertNotNil(error, @"There should be an error");
    XCTAssertEqualObjects(error.domain, JVArgumentParserErrorDomain, @"Unknown error domain");
    XCTAssertEqual(error.code, JVArgumentParserErrorUnknownOption, @"Unknown error code");
}

@end