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

#import "NewPOIViewControllerViewController.h"
#import "Constants.h"
#import "ServiceCaller.h"

@interface NewPOIViewControllerViewController ()

@end

@implementation NewPOIViewControllerViewController
@synthesize labelSasUrlInfo;
@synthesize buttonPostPOI;
@synthesize imageView;
@synthesize buttonGetSasURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    buttonGetSasURL.enabled = NO;
    buttonPostPOI.enabled = NO;
    serviceCaller = [[ServiceCaller alloc] init];
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setButtonGetSasURL:nil];
    [self setLabelSasUrlInfo:nil];
    [self setButtonPostPOI:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/**
 Opens up the photo gallery so the user can select an image
 */
- (IBAction)getImage:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentModalViewController:picker animated:YES];
}

/**
 Cals the ServiceCaller and requests a new SAS string
 */
- (IBAction)getSasUrl:(id)sender {
        
    NSString *time = [NSString stringWithFormat:@"%i", -CFAbsoluteTimeGetCurrent()];
    
    //Just pass the call over to our generic serviceCaller
    [serviceCaller postToUrl:[NSString stringWithFormat:@"%@?container=%@&blobname=%@"
                              ,kGetSASUrl, kContainerName, time]
                    withBody:nil andPostType:@"GET" andContentType:nil withCallback:^(NSString *response) {
                        //This is the callback code that the ServiceCaller will call upon success
                        labelSasUrlInfo.text = response;
                        sasURL = [response stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                        NSLog(@"SAS URL: %@", sasURL);
                        buttonPostPOI.enabled = YES;
                        buttonGetSasURL.enabled = NO;
                    }];
    
}

/**
 Posts the POI and Image data to the server
 */
- (IBAction)postPOI:(id)sender {
    UIImage *image = imageView.image;
    
    NSData *data = UIImagePNGRepresentation(image);
    //Just pass the call over to our generic serviceCaller
    [serviceCaller postToUrl:sasURL
        withBody:data andPostType:@"PUT" andContentType:@"image/jpeg" withCallback:^(NSString *response) {
            //This is the callback code that the ServiceCaller will call upon success
            labelSasUrlInfo.text = response;
            if ([response isEqualToString:@""])
                labelSasUrlInfo.text = @"Should have been a success, proceeding";
                        
            //   Now add the location information to the server
            NSString *poiURL = [[sasURL componentsSeparatedByString:@"?"] objectAtIndex:0];
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            
            //build an info object and convert to json
            NSDictionary* jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                            @"My Image", @"Description",
                                            [self generateUuidString], @"Id",
                                            [prefs stringForKey:@"Latitude"], @"Latitude",
                                            [prefs stringForKey:@"Longitude"], @"Longitude",
                                            @"1", @"Type",
                                            poiURL, @"Url",
                                            nil];
            NSError *error;
            NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary 
                                   options:NSJSONWritingPrettyPrinted error:&error];
            //Pass the call over to our generic serviceCaller
            [serviceCaller postToUrl:kAddPOIUrl
                withBody:jsonData andPostType:@"POST" andContentType:@"application/json" withCallback:^(NSString *response) {
                    //This is the callback code that the ServiceCaller will call upon success
                    labelSasUrlInfo.text = response;
                    if ([response isEqualToString:@""])
                        labelSasUrlInfo.text = @"Should have been a success, poi added";
                    [self.navigationController popViewControllerAnimated:YES];
                    
                }];
            
        }];
}

// return a new autoreleased UUID string
- (NSString *)generateUuidString
{
    // create a new UUID
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    
    // create a new CFStringRef (toll-free bridged to NSString)
    NSString *uuidString = (__bridge NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);    
    
    // release the UUID
    CFRelease(uuid);
    
    return uuidString;
}


#pragma UIImagePickerControllerDelegate Methods

/**
 Called when the user has selected an image from the Gallery
 */
- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    imageView.image = image;
    [picker dismissModalViewControllerAnimated:YES];
    buttonGetSasURL.enabled = YES;
    buttonPostPOI.enabled = NO;
}
@end
