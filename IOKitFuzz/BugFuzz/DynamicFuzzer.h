#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DynamicFuzzer : NSObject

- (instancetype)init;
- (kern_return_t)toggleDisplayMode:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_END
