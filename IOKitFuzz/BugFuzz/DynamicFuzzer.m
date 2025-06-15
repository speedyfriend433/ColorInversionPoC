#import "DynamicFuzzer.h"
#import <mach/mach.h>
#import <IOKit/IOKitLib.h>
#define CLCD_SERVICE_NAME "AppleCLCD"
#define UNDOCUMENTED_DISPLAY_MODE_SELECTOR 0x13

@interface DynamicFuzzer()
@property (nonatomic, assign) io_connect_t connection;
@end

@implementation DynamicFuzzer

- (instancetype)init {
    self = [super init];
    if (self) {
        io_service_t service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching(CLCD_SERVICE_NAME));
        if (service == IO_OBJECT_NULL) {
            NSLog(@"[PoC] FATAL: %s service not found.", CLCD_SERVICE_NAME);
            return nil;
        }
        
        kern_return_t kr = IOServiceOpen(service, mach_task_self(), 0, &_connection);
        IOObjectRelease(service);
        
        if (kr != KERN_SUCCESS) {
            NSLog(@"[PoC] FATAL: IOServiceOpen failed: %s", mach_error_string(kr));
            return nil;
        }
        
        NSLog(@"[PoC] Successfully acquired connection to %s.", CLCD_SERVICE_NAME);
    }
    return self;
}

- (void)dealloc {
    if (self.connection) {
        IOServiceClose(self.connection);
        NSLog(@"[PoC] Connection closed.");
    }
}

- (kern_return_t)toggleDisplayMode:(BOOL)enabled {
    if (!self.connection) {
        return kIOReturnNotOpen;
    }
    uint64_t input = enabled;
    
    NSLog(@"[PoC] Calling selector 0x%X with input: %llu", UNDOCUMENTED_DISPLAY_MODE_SELECTOR, input);
    return IOConnectCallScalarMethod(self.connection, UNDOCUMENTED_DISPLAY_MODE_SELECTOR, &input, 1, NULL, 0);
}

@end
