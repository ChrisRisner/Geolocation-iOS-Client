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

#import "Constants.h"

@implementation Constants

NSString *kGetPOIUrl = @"http://<Your Subdomain>.azurewebsites.net/api/Location/FindPointsOfInterestWithinRadius";
NSString *kGetSASUrl = @"http://<Your Subdomain>.azurewebsites.net/api/blobsas/get";
NSString *kAddPOIUrl = @"http://<Your Subdomain>.azurewebsites.net/api/location/postpointofinterest/";

NSString *kContainerName = @"test";

@end
