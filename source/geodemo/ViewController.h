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
#import "CoreLocationController.h"
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController <CoreLocationControllerDelegate, MKMapViewDelegate> {
    CoreLocationController *CLController;
    __weak IBOutlet MKMapView *mapView;
    __weak IBOutlet UILabel *labelLongitude;
    __weak IBOutlet UILabel *labelLatitude;
    
    @private
    BOOL viewDidAppear;
    CLLocation * currentLocation;
}

@property (nonatomic, retain) CoreLocationController *CLController;
@property (weak, nonatomic) IBOutlet UIButton *refreshPointsOfInterest;

- (void)getCurrentPointsOfInterest;
- (IBAction)refreshPointsOfInterest:(id)sender;

@end
