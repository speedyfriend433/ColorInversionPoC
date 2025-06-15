# AppleCLCD Display Toggle PoC (iOS 18+)

This is a **proof-of-concept (PoC)** that demonstrates access to the private `AppleCLCD` IOKit service on iOS 18. It invokes an **undocumented selector (0x13)** that appears to toggle an internal display mode — likely color inversion or a hardware debugging feature.

## ✨ Features
- Connects to `AppleCLCD` using `IOServiceOpen`
- Calls selector `0x13` with scalar input to toggle mode
- No entitlements or special privileges required (tested via TrollStore or dev mode)

## 🧠 Why This Matters
This shows that `AppleCLCD` exposes undocumented functionality to user space via selector `0x13`, which:
- Alters system display behavior
- Works without crashing up to iOS 26
- Requires no entitlement if run from sandboxed context

Apple Security has been informed, and they **closed the report without action**. This PoC is now published **for educational and research purposes only**.

## 🔒 Disclaimer
This code is provided **as-is** and is intended only for educational use.  
**Do not use on production devices.**  
Do not attempt to bypass sandbox or entitlements unless you're legally authorized to do so.

## 📱 Tested On
- iOS 26.0 (iPhone 11 Pro)
- Xcode builds (sandboxed)

## 🧪 Usage

```objc
DynamicFuzzer *fuzzer = [[DynamicFuzzer alloc] init];
[fuzzer toggleDisplayMode:YES]; // enable
[fuzzer toggleDisplayMode:NO];  // disable
```

## 📖 Credits
AppinstalleriOS - Thanks for optimizing the code to find exact selector of IOServices
