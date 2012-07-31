/*
 Copyright 2010 Microsoft Corp
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <UIKit/UIKit.h>
#import "ServiceCaller.h"

@interface NewPOIViewControllerViewController : UIViewController <UIImagePickerControllerDelegate> {
@private
    ServiceCaller *serviceCaller;
    NSString *sasURL;
}

- (IBAction)getImage:(id)sender;
- (IBAction)getSasUrl:(id)sender;
- (IBAction)postPOI:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *buttonGetSasURL;
@property (weak, nonatomic) IBOutlet UILabel *labelSasUrlInfo;
@property (weak, nonatomic) IBOutlet UIButton *buttonPostPOI;


@end
