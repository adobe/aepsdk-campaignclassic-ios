/*
 Copyright 2022 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License")
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

#import "ViewController.h"
@import AEPCampaignClassic;
@import AEPCore;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lbl_version;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_lbl_version setText:[NSString stringWithFormat:@"version %@", [AEPMobileCampaignClassic extensionVersion]]];
}

- (IBAction)privacyOptOutClicked:(id)sender {
    [AEPMobileCore setPrivacyStatus:AEPPrivacyStatusOptedOut];
}

- (IBAction)privacyOptInClicked:(id)sender {
    [AEPMobileCore setPrivacyStatus:AEPPrivacyStatusOptedIn];
}

- (IBAction)privacyOptUnknownClicked:(id)sender {
    [AEPMobileCore setPrivacyStatus:AEPPrivacyStatusUnknown];
}

@end
