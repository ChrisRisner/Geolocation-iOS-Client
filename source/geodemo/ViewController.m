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

#import "ViewController.h"
#import "Constants.h"
#import "MapAnnotation.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize refreshPointsOfInterest;

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Start getting the current location
    CLController = [[CoreLocationController alloc] init];
	CLController.delegate = self;
	[CLController.locMgr startUpdatingLocation];
    
    //Set the map view to show the current location and use self for updates
    mapView.showsUserLocation = YES;
    [mapView setDelegate:self];
    viewDidAppear = NO;
}

/**
 This method is fired whenever the Location Manager indicates there is an update.
 */
- (void)locationUpdate:(CLLocation *)location {
    //Set the private currentLocation field to be the location passed in
    currentLocation = location;
    labelLatitude.text= [NSString stringWithFormat:@"Latitude: %f", [location coordinate].latitude];
    labelLongitude.text = [NSString stringWithFormat:@"Longitude: %f", [location coordinate].longitude];
    
    //Save our long and latitude into defaults for adding a POI later
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:[NSString stringWithFormat:@"%f", [location coordinate].latitude] forKey:@"Latitude"];
    [prefs setObject:[NSString stringWithFormat:@"%f", [location coordinate].longitude] forKey:@"Longitude"];
    [prefs synchronize];
    
    //Center on our location
    CLLocationCoordinate2D mapCenter = mapView.centerCoordinate;
    mapCenter = [location coordinate];
    [mapView setCenterCoordinate:mapCenter animated:YES];
    
    MKCoordinateRegion theRegion = mapView.region;    
    //Here we're only rechecking for POIs if the lat / long delta is a significant amount
    if (theRegion.span.longitudeDelta > 2 ||
        theRegion.span.latitudeDelta > 2) {

        //Decreasing the scale will zoom the map in farther
        //Increasing will zoom out
        double scale = .01;
        theRegion.span.longitudeDelta = scale;
        theRegion.span.latitudeDelta = scale;
        [mapView setRegion:theRegion animated:YES];        
                
        [self getCurrentPointsOfInterest];
    }
    
}

/**
 Starts an async request to the server for local Points of Interest
 */
- (void)getCurrentPointsOfInterest {
    NSURL *requestUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?latitude=%f&longitude=%f&radiusInMeters=1000",kGetPOIUrl, [currentLocation coordinate].latitude, [currentLocation coordinate].longitude]];
    //Get our POI
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: 
                        requestUrl];
        [self performSelectorOnMainThread:@selector(fetchedData:) 
                               withObject:data waitUntilDone:YES];
    });
}

- (IBAction)refreshPointsOfInterest:(id)sender {
    [self getCurrentPointsOfInterest];
}

- (void)locationError:(NSError *)error {
    labelLatitude.text = [error description];
    labelLongitude.text = nil;
}

/**
 Here, we're checking to see if the view has already appeared, if not, we just mark it as having appeared.
 If it has, we'll recheck for POIs.  This will cause the map to redraw POIs in case the user just added a POI.
 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (viewDidAppear == YES) {
        [self getCurrentPointsOfInterest];
    } else {
        viewDidAppear = YES;
    }
}

- (void)viewDidUnload
{
    mapView = nil;
    labelLongitude = nil;
    labelLatitude = nil;
    [self setRefreshPointsOfInterest:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)fetchedData:(NSData *)responseData {
    NSError* error;
    //Build a JSON object from the response Data
    NSArray* json = [NSJSONSerialization 
                          JSONObjectWithData:responseData //1
                          
                          options:kNilOptions 
                          error:&error];
    
    //Go through each POI in the JSON data and pull out the important fields
    for (NSDictionary *pointOfInterest in json) {
        NSLog(@"POI:%@", pointOfInterest);

        
        CLLocationCoordinate2D mapPoint = mapView.centerCoordinate;
        NSString *latString = [pointOfInterest valueForKey:@"Latitude"];
        NSString *longString = [pointOfInterest valueForKey:@"Longitude"];
        NSString *description = [pointOfInterest valueForKey:@"Description"];
        NSString *url = [pointOfInterest valueForKey:@"Url"];
        mapPoint.latitude = [latString doubleValue];
        mapPoint.longitude = [longString doubleValue];
            
        //Add a new map annotation for each POI
        MKPointAnnotation *anny = [[MKPointAnnotation alloc] init];
        anny.coordinate = mapPoint;
        anny.title = description;
        anny.subtitle = url;
        [mapView addAnnotation:anny];        
    }
}    

/**
 Called for each map annotation item.  Essentially we're just telling the map to place a pin on each spot.
 */
- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    
    static NSString *AnnotationViewID = @"annotationViewID";
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    if (annotationView == nil)
    {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
    }
    annotationView.canShowCallout = YES;
    annotationView.annotation = annotation;
    
    return annotationView;
}


@end
