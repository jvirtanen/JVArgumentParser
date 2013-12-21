#import <Foundation/Foundation.h>

#import "JVOption.h"

@interface JVAwaitingArgument : NSObject
@property (readonly) NSString *context;
@property (readonly) JVOption *option;

+ (instancetype)awaitingArgumentWithContext:(NSString *)context
                                     option:(JVOption *)option;
- (instancetype)initWithContext:(NSString *)context
                         option:(JVOption *)option;
@end
