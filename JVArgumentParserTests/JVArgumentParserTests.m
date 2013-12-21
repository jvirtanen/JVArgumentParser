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

    [parser addOptionWithName:'a' value:&a];

    NSArray *arguments = [parser parse:@[@"-a"] error:nil];

    XCTAssertEqualObjects(arguments, @[]);
    XCTAssertTrue(a);
}

- (void)testLongOption
{
    BOOL foo = FALSE;

    [parser addOptionWithLongName:@"foo" value:&foo];

    NSArray *arguments = [parser parse:@[@"--foo"] error:nil];

    XCTAssertEqualObjects(arguments, @[]);
    XCTAssertTrue(foo);
}

- (void)testOptionAndLongOption
{
    __block int count = 0;

    [parser addOptionWithName:'a' longName:@"foo" block:^{
        count++;
    }];

    [parser parse:@[@"-a", @"--foo"] error:nil];

    XCTAssertEqual(count, 2);
}

- (void)testOptionWithArgument
{
    NSString *a = nil;

    [parser addOptionWithArgumentWithName:'a' value:&a];

    NSArray *arguments = [parser parse:@[@"-a", @"foo"] error:nil];

    XCTAssertEqualObjects(arguments, @[]);
    XCTAssertEqualObjects(a, @"foo");
}

- (void)testOptionWithArgumentWithoutOptionalSpaceInBetween
{
    NSString *a = nil;

    [parser addOptionWithArgumentWithName:'a' value:&a];

    NSArray *arguments = [parser parse:@[@"-afoo"] error:nil];

    XCTAssertEqualObjects(arguments, @[]);
    XCTAssertEqualObjects(a, @"foo");
}

- (void)testLongOptionWithArgument
{
    NSString *foo = nil;

    [parser addOptionWithArgumentWithLongName:@"foo" value:&foo];

    NSArray *arguments = [parser parse:@[@"--foo", @"bar"] error:nil];

    XCTAssertEqualObjects(arguments, @[]);
    XCTAssertEqualObjects(foo, @"bar");
}

- (void)testLongOptionWithArgumentWithEqualsInBetween
{
    NSString *foo = nil;

    [parser addOptionWithArgumentWithLongName:@"foo" value:&foo];

    NSArray *arguments = [parser parse:@[@"--foo=bar"] error:nil];

    XCTAssertEqualObjects(arguments, @[]);
    XCTAssertEqualObjects(foo, @"bar");
}

- (void)testOptionAndLongOptionWithArgument
{
    __block int count = 0;

    [parser addOptionWithArgumentWithName:'a' longName:@"foo" block:^(NSString *argument){
        count++;
    }];

    [parser parse:@[@"-abar", @"--foo=baz"] error:nil];

    XCTAssertEqual(count, 2);
}

- (void)testOptionGroup
{
    BOOL a = FALSE;
    BOOL b = FALSE;
    BOOL c = FALSE;

    [parser addOptionWithName:'a' value:&a];
    [parser addOptionWithName:'b' value:&b];
    [parser addOptionWithName:'c' value:&c];

    NSArray *arguments = [parser parse:@[@"-ab"] error:nil];

    XCTAssertEqualObjects(arguments, @[]);
    XCTAssertTrue(a);
    XCTAssertTrue(b);
    XCTAssertFalse(c);
}

- (void)testOptionGroupTerminatedByOptionWithArgument
{
    BOOL a = FALSE;
    BOOL b = FALSE;
    NSString *c = nil;

    [parser addOptionWithName:'a' value:&a];
    [parser addOptionWithName:'b' value:&b];
    [parser addOptionWithArgumentWithName:'c' value:&c];

    NSArray *arguments = [parser parse:@[@"-abc", @"foo"] error:nil];

    XCTAssertEqualObjects(arguments, @[]);
    XCTAssertTrue(a);
    XCTAssertTrue(b);
    XCTAssertEqualObjects(c, @"foo");
}

- (void)testOptionGroupTerminatedByOptionWithArgumentWithoutOptionalSpaceInBetween
{
    BOOL a = FALSE;
    BOOL b = FALSE;
    NSString *c = nil;

    [parser addOptionWithName:'a' value:&a];
    [parser addOptionWithName:'b' value:&b];
    [parser addOptionWithArgumentWithName:'c' value:&c];

    NSArray *arguments = [parser parse:@[@"-abcfoo"] error:nil];

    XCTAssertEqualObjects(arguments, @[]);
    XCTAssertTrue(a);
    XCTAssertTrue(b);
    XCTAssertEqualObjects(c, @"foo");
}

- (void)testOptionGroupWithOptionWithArgument
{
    BOOL a = FALSE;
    NSString *b = nil;
    BOOL c = FALSE;

    [parser addOptionWithName:'a' value:&a];
    [parser addOptionWithArgumentWithName:'b' value:&b];
    [parser addOptionWithName:'c' value:&c];

    NSArray *arguments = [parser parse:@[@"-abc"] error:nil];

    XCTAssertEqualObjects(arguments, @[]);
    XCTAssertTrue(a);
    XCTAssertEqualObjects(b, @"c");
    XCTAssertFalse(c);
}

- (void)testEndOfOptions
{
    BOOL a = FALSE;
    BOOL b = FALSE;

    [parser addOptionWithName:'a' value:&a];
    [parser addOptionWithName:'b' value:&b];

    NSArray *arguments = [parser parse:@[@"-a", @"--", @"-b"] error:nil];

    XCTAssertEqualObjects(arguments, @[@"-b"]);
    XCTAssertTrue(a);
    XCTAssertFalse(b);
}

- (void)testParsing
{
    NSString *d = nil;
    NSString *f = nil;

    [parser addOptionWithArgumentWithName:'d' value:&d];
    [parser addOptionWithArgumentWithName:'f' value:&f];

    NSArray *arguments = [parser parse:@[@"-f", @"1,3", @"-d", @",", @"foo.csv"] error:nil];

    XCTAssertEqualObjects(arguments, @[@"foo.csv"]);
    XCTAssertEqualObjects(d, @",");
    XCTAssertEqualObjects(f, @"1,3");
}

- (void)testParsingArgcArgv
{
    NSString *d = nil;
    NSString *f = nil;

    [parser addOptionWithArgumentWithName:'d' value:&d];
    [parser addOptionWithArgumentWithName:'f' value:&f];

    int argc = 6;
    const char *argv[] = { "/usr/bin/cut", "-f", "1,3", "-d", ",", "foo.csv" };

    NSArray *arguments = [parser parseArgc:argc argv:argv encoding:NSUTF8StringEncoding error:nil];

    XCTAssertEqualObjects(arguments, @[@"foo.csv"]);
    XCTAssertEqualObjects(d, @",");
    XCTAssertEqualObjects(f, @"1,3");
}

- (void)testMissingOptionArgument
{
    NSError *error = nil;

    [parser addOptionWithArgumentWithName:'a' block:^(NSString *argument){
    }];

    NSArray *arguments = [parser parse:@[@"-a"] error:&error];

    XCTAssertNil(arguments);
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, JVArgumentParserErrorDomain);
    XCTAssertEqual(error.code, JVArgumentParserErrorMissingArgument);
    XCTAssertEqualObjects(error.localizedDescription, @"Missing argument: -a");
}

- (void)testMissingOptionArgumentBetweenOptions
{
    NSString *a = nil;
    BOOL b = FALSE;

    [parser addOptionWithArgumentWithName:'a' value:&a];
    [parser addOptionWithName:'b' value:&b];

    NSArray *arguments = [parser parse:@[@"-a", @"-b"] error:nil];

    XCTAssertEqualObjects(arguments, @[]);
    XCTAssertEqualObjects(a, @"-b");
    XCTAssertFalse(b);
}

- (void)testMissingOptionArgumentForLongOption
{
    NSError *error = nil;

    [parser addOptionWithArgumentWithLongName:@"foo" block:^(NSString *argument) {
    }];

    NSArray *arguments = [parser parse:@[@"--foo="] error:&error];

    XCTAssertNil(arguments);
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, JVArgumentParserErrorDomain);
    XCTAssertEqual(error.code, JVArgumentParserErrorMissingArgument);
    XCTAssertEqualObjects(error.localizedDescription, @"Missing argument: --foo=");
}

- (void)testUnknownOption
{
    NSError *error = nil;

    NSArray *arguments = [parser parse:@[@"-a"] error:&error];

    XCTAssertNil(arguments);
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, JVArgumentParserErrorDomain);
    XCTAssertEqual(error.code, JVArgumentParserErrorUnknownOption);
    XCTAssertEqualObjects(error.localizedDescription, @"Unknown option: -a");
}

- (void)testUnknownLongOption
{
    NSError *error = nil;

    NSArray *arguments = [parser parse:@[@"--foo"] error:&error];

    XCTAssertNil(arguments);
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, JVArgumentParserErrorDomain);
    XCTAssertEqual(error.code, JVArgumentParserErrorUnknownOption);
    XCTAssertEqualObjects(error.localizedDescription, @"Unknown option: --foo");
}

- (void)testUnknownOptionInGroup
{
    NSError *error = nil;

    [parser addOptionWithName:'a' block:^{
    }];

    NSArray *arguments = [parser parse:@[@"-ab"] error:&error];

    XCTAssertNil(arguments);
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, JVArgumentParserErrorDomain);
    XCTAssertEqual(error.code, JVArgumentParserErrorUnknownOption);
    XCTAssertEqualObjects(error.localizedDescription, @"Unknown option: -ab");
}

- (void)testSuperfluousOptionArgument
{
    NSError *error = nil;

    [parser addOptionWithLongName:@"foo" block:^{
    }];

    NSArray *arguments = [parser parse:@[@"--foo=bar"] error:&error];

    XCTAssertNil(arguments);
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, JVArgumentParserErrorDomain);
    XCTAssertEqual(error.code, JVArgumentParserErrorSuperfluousArgument);
    XCTAssertEqualObjects(error.localizedDescription, @"Superfluous argument: --foo=bar");
}

- (void)testNoErrorInformation
{
    NSArray *arguments = [parser parse:@[@"-a"] error:nil];

    XCTAssertNil(arguments);
}

@end