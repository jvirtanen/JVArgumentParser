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
    BOOL a = FALSE;

    [parser addOptionWithName:'a' variable:&a];

    NSArray *arguments = [parser parse:@[@"-a"] error:nil];

    XCTAssertEqualObjects(arguments, @[], @"There should be no arguments");
    XCTAssertTrue(a, @"Option '-a' should be parsed");
}

- (void)testLongOption
{
    BOOL foo = FALSE;

    [parser addOptionWithLongName:@"foo" variable:&foo];

    NSArray *arguments = [parser parse:@[@"--foo"] error:nil];

    XCTAssertEqualObjects(arguments, @[], @"There should be no arguments");
    XCTAssertTrue(foo, @"Option '--foo' should be parsed");
}

- (void)testOptionWithArgument
{
    NSString *a = nil;

    [parser addOptionWithArgumentWithName:'a' variable:&a];

    NSArray *arguments = [parser parse:@[@"-a", @"foo"] error:nil];

    XCTAssertEqualObjects(arguments, @[], @"There should be no arguments");
    XCTAssertEqualObjects(a, @"foo", @"Option '-a' should be parsed");
}

- (void)testOptionWithArgumentWithoutOptionalSpaceInBetween
{
    NSString *a = nil;

    [parser addOptionWithArgumentWithName:'a' variable:&a];

    NSArray *arguments = [parser parse:@[@"-afoo"] error:nil];

    XCTAssertEqualObjects(arguments, @[], @"There should be no arguments");
    XCTAssertEqualObjects(a, @"foo", @"Option '-a' should be parsed");
}

- (void)testLongOptionWithArgument
{
    NSString *foo = nil;

    [parser addOptionWithArgumentWithLongName:@"foo" variable:&foo];

    NSArray *arguments = [parser parse:@[@"--foo", @"bar"] error:nil];

    XCTAssertEqualObjects(arguments, @[], @"There should be no arguments");
    XCTAssertEqualObjects(foo, @"bar", @"Option '--foo' should be parsed");
}

- (void)testOptionGroup
{
    BOOL a = FALSE;
    BOOL b = FALSE;
    BOOL c = FALSE;

    [parser addOptionWithName:'a' variable:&a];
    [parser addOptionWithName:'b' variable:&b];
    [parser addOptionWithName:'c' variable:&c];

    NSArray *arguments = [parser parse:@[@"-ab"] error:nil];

    XCTAssertEqualObjects(arguments, @[], @"There should be no arguments");
    XCTAssertTrue(a, @"Option '-a' should be parsed");
    XCTAssertTrue(b, @"Option '-b' should be parsed");
    XCTAssertFalse(c, @"Option '-c' should not be parsed");
}

- (void)testOptionGroupTerminatedByOptionWithArgument
{
    BOOL a = FALSE;
    BOOL b = FALSE;
    NSString *c = nil;

    [parser addOptionWithName:'a' variable:&a];
    [parser addOptionWithName:'b' variable:&b];
    [parser addOptionWithArgumentWithName:'c' variable:&c];

    NSArray *arguments = [parser parse:@[@"-abc", @"foo"] error:nil];

    XCTAssertEqualObjects(arguments, @[], @"There should be no arguments");
    XCTAssertTrue(a, @"Option '-a' should be parsed");
    XCTAssertTrue(b, @"Option '-b' should be parsed");
    XCTAssertEqualObjects(c, @"foo", @"Option '-c' should be parsed");
}

- (void)testOptionGroupTerminatedByOptionWithArgumentWithoutOptionalSpaceInBetween
{
    BOOL a = FALSE;
    BOOL b = FALSE;
    NSString *c = nil;

    [parser addOptionWithName:'a' variable:&a];
    [parser addOptionWithName:'b' variable:&b];
    [parser addOptionWithArgumentWithName:'c' variable:&c];

    NSArray *arguments = [parser parse:@[@"-abcfoo"] error:nil];

    XCTAssertEqualObjects(arguments, @[], @"There should be no arguments");
    XCTAssertTrue(a, @"Option '-a' should be parsed");
    XCTAssertTrue(b, @"Option '-b' should be parsed");
    XCTAssertEqualObjects(c, @"foo", @"Option '-c' should be parsed");
}

- (void)testOptionGroupWithOptionWithArgument
{
    BOOL a = FALSE;
    NSString *b = nil;
    BOOL c = FALSE;

    [parser addOptionWithName:'a' variable:&a];
    [parser addOptionWithArgumentWithName:'b' variable:&b];
    [parser addOptionWithName:'c' variable:&c];

    NSArray *arguments = [parser parse:@[@"-abc"] error:nil];

    XCTAssertEqualObjects(arguments, @[], @"There should be no arguments");
    XCTAssertTrue(a, @"Option '-a' should be parsed");
    XCTAssertEqualObjects(b, @"c", @"Option '-b' should be parsed");
    XCTAssertFalse(c, @"Option '-c' should not be parsed");
}

- (void)testEndOfOptions
{
    BOOL a = FALSE;
    BOOL b = FALSE;

    [parser addOptionWithName:'a' variable:&a];
    [parser addOptionWithName:'b' variable:&b];

    NSArray *arguments = [parser parse:@[@"-a", @"--", @"-b"] error:nil];

    XCTAssertEqualObjects(arguments, @[@"-b"], @"There should be arguments");
    XCTAssertTrue(a, @"Option '-a' should be parsed");
    XCTAssertFalse(b, @"Option '-b' should not be parsed");
}

- (void)testParsing
{
    NSString *d = nil;
    NSString *f = nil;

    [parser addOptionWithArgumentWithName:'d' variable:&d];
    [parser addOptionWithArgumentWithName:'f' variable:&f];

    NSArray *arguments = [parser parse:@[@"-f", @"1,3", @"-d", @",", @"foo.csv"] error:nil];

    XCTAssertEqualObjects(arguments, @[@"foo.csv"], @"There should be arguments");
    XCTAssertEqualObjects(d, @",", @"Option '-d' should be parsed");
    XCTAssertEqualObjects(f, @"1,3", @"Option '-f' should be parsed");
}

- (void)testParsingArgcArgv
{
    NSString *d = nil;
    NSString *f = nil;

    [parser addOptionWithArgumentWithName:'d' variable:&d];
    [parser addOptionWithArgumentWithName:'f' variable:&f];

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
    NSString *a = nil;
    BOOL b = FALSE;

    [parser addOptionWithArgumentWithName:'a' variable:&a];
    [parser addOptionWithName:'b' variable:&b];

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

- (void)testUnknownLongOption
{
    NSError *error = nil;

    NSArray *arguments = [parser parse:@[@"--foo"] error:&error];

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