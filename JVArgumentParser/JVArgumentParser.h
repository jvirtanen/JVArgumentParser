#import <Foundation/Foundation.h>

#import "JVArgumentParserError.h"
#import "JVOptionHandler.h"
#import "JVOptionWithArgumentHandler.h"

/**
 * The `JVArgumentParser` class implements a command line argument parser.
 * Typically you create a parser, add options to it and then give it command
 * line arguments to parse. The parser iterates over the command line arguments,
 * calling handlers for encountered options on the way, and finally returns the
 * remaining arguments.
 */
@interface JVArgumentParser : NSObject

/**
 * @name Creating Parsers
 */

/**
 * Returns a parser.
 */
+ (instancetype)argumentParser;

/**
 * @name Adding Options
 */

/**
 * Add an option.
 *
 * @param name   The name of the option.
 * @param block  A block that will be called on the option.
 */
- (void)addOptionWithName:(unichar)name
                    block:(JVOptionHandler)block;

/**
 * Add an option.
 *
 * @param name   The name of the option.
 * @param value  A pointer to a value that will be set to `TRUE` on the option.
 */
- (void)addOptionWithName:(unichar)name
                    value:(BOOL *)value;

/**
 * Add a long option.
 *
 * @param longName  The name of the long option.
 * @param block     A block that will be called on the option.
 */
- (void)addOptionWithLongName:(NSString *)longName
                        block:(JVOptionHandler)block;

/**
 * Add a long option.
 *
 * @param longName  The name of the long option.
 * @param value     A pointer to a value that will be set to `TRUE` on the
 *                  option.
 */
- (void)addOptionWithLongName:(NSString *)longName
                        value:(BOOL *)value;

/**
 * Add an option and a corresponding long option.
 *
 * @param name      The name of the option.
 * @param longName  The name of the long option.
 * @param block     A block that will be called on the options.
 */
- (void)addOptionWithName:(unichar)name
                 longName:(NSString *)longName
                    block:(JVOptionHandler)block;

/**
 * Add an option and a corresponding long option.
 *
 * @param name      The name of the option.
 * @param longName  The name of the long option.
 * @param value     A pointer to a value that will be set to `TRUE` on the
 *                  options.
 */
- (void)addOptionWithName:(unichar)name
                 longName:(NSString *)longName
                    value:(BOOL *)value;

/**
 * Add an option that takes an argument.
 *
 * @param name   The name of the option.
 * @param block  A block that will be called on the option.
 */
- (void)addOptionWithArgumentWithName:(unichar)name
                                block:(JVOptionWithArgumentHandler)block;

/**
 * Add an option that takes an argument.
 *
 * @param name   The name of the option.
 * @param value  A pointer to a value that will be set on the option.
 */
- (void)addOptionWithArgumentWithName:(unichar)name
                                value:(NSString __strong **)value;

/**
 * Add a long option that takes an argument.
 *
 * @param longName  The name of the long option.
 * @param block     A block that will be called on the option.
 */
- (void)addOptionWithArgumentWithLongName:(NSString *)longName
                                    block:(JVOptionWithArgumentHandler)block;

/**
 * Add a long option that takes an argument.
 *
 * @param longName  The name of the long option.
 * @param value     A pointer to a value that will be set on the option.
 */
- (void)addOptionWithArgumentWithLongName:(NSString *)longName
                                    value:(NSString __strong **)value;

/**
 * Add an option and a corresponding long option that take an argument.
 *
 * @param name      The name of the option.
 * @param longName  The name of the long option.
 * @param block     A block that will be called on the options.
 */
- (void)addOptionWithArgumentWithName:(unichar)name
                             longName:(NSString *)longName
                                block:(JVOptionWithArgumentHandler)block;

/**
 * Add an option and a corresponding long option that take an argument.
 *
 * @param name      The name of the option.
 * @param longName  The name of the long option.
 * @param value     A pointer to a value that will be set on the options.
 */
- (void)addOptionWithArgumentWithName:(unichar)name
                             longName:(NSString *)longName
                                value:(NSString __strong **)value;

/**
 * @name Parsing Command Line Arguments
 */

/**
 * Parses the given command line arguments.
 *
 * @param args   The command line arguments.
 * @param error  A pointer to an error object. You may specify `nil` for this
 *               parameter if you do not want the error information.
 *
 * @return The remaining arguments or `nil` if an error occurred.
 */
- (NSArray *)parse:(NSArray *)args
             error:(NSError **)error;

/**
 * Parses the command line arguments contained in the given program arguments.
 * The head of the program argument vector is treated as the program name and
 * the rest as the command line arguments.
 *
 * @param argc      The program argument count.
 * @param argv      The program argument vector.
 * @param encoding  The character encoding applied to the program argument
 *                  vector.
 * @param error     A pointer to an error object. You may specify `nil` for this
 *                  parameter if you do not want the error information.
 *
 * @return The remaining arguments or `nil` if an error occurred.
 */
- (NSArray *)parseArgc:(int)argc
                  argv:(const char **)argv
              encoding:(NSStringEncoding)encoding
                 error:(NSError **)error;

@end
