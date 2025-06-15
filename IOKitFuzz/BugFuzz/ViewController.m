#import "ViewController.h"
#import "DynamicFuzzer.h"

@interface ViewController ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UISwitch *modeSwitch;
@property (nonatomic, strong) DynamicFuzzer *pocHarness;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"AppleCLCD PoC";
    self.titleLabel.font = [UIFont boldSystemFontOfSize:24];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.titleLabel];
    
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.text = @"Toggle the switch to trigger the undocumented display mode.";
    self.statusLabel.font = [UIFont systemFontOfSize:16];
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.statusLabel];

    self.modeSwitch = [[UISwitch alloc] init];
    [self.modeSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    self.modeSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.modeSwitch];

    [NSLayoutConstraint activateConstraints:@[
        [self.titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:60],
        
        [self.modeSwitch.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.modeSwitch.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        
        [self.statusLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.statusLabel.topAnchor constraintEqualToAnchor:self.modeSwitch.bottomAnchor constant:30],
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20]
    ]];

    self.pocHarness = [[DynamicFuzzer alloc] init];
    if (!self.pocHarness) {
        self.statusLabel.textColor = [UIColor systemRedColor];
        self.statusLabel.text = @"Failed to initialize PoC. AppleCLCD service might not be accessible.";
        self.modeSwitch.enabled = NO;
    }
}

- (void)switchChanged:(UISwitch *)sender {
    if (!self.pocHarness) return;
    
    kern_return_t result = [self.pocHarness toggleDisplayMode:sender.isOn];
    
    if (result == KERN_SUCCESS) {
        self.statusLabel.text = [NSString stringWithFormat:@"IOKit call succeeded. Display mode set to: %@", sender.isOn ? @"ON" : @"OFF"];
        self.statusLabel.textColor = [UIColor labelColor];
    } else {
        self.statusLabel.text = [NSString stringWithFormat:@"IOKit call failed with error: 0x%x", result];
        self.statusLabel.textColor = [UIColor systemRedColor];
    }
}

@end
