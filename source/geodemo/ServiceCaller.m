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

#import "ServiceCaller.h"
#import "StateObject.h"

@implementation ServiceCaller

-(ServiceCaller*) init {
    callbacks = [[NSMutableDictionary alloc] init];
    return self;
}

/**
 This method performs a generic post to a web endpoint.  It can handle different content types, post types,
 as well as data or no data.  It expects a callback method (block) which will be called upon completion.
 */
-(void) postToUrl:(NSString *)url withBody:(NSData *)body andPostType: (NSString *) postType andContentType: (NSString *) contentType
     withCallback: (void (^)(NSString *))callback {
    NSLog(@"Posting Url: %@", url);
    NSMutableURLRequest* request = [NSMutableURLRequest 
                                    requestWithURL: [NSURL URLWithString:url]]; 
    [request setHTTPMethod:postType];   
    if (contentType)
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        
    NSError *error;
    // should check for and handle errors here but we aren't
    [request setHTTPBody:body];
    //Start the request
    NSURLConnection *conn = [[NSURLConnection alloc] 
                             initWithRequest: request delegate:self];
    //Store a StateObject which has an instance of receivedData to store any data that comes back for the 
    //request in addition to the callback that needs to be called upon completion.
    StateObject* connectionState = [[StateObject alloc] init];
    connectionState.receivedData = [[NSMutableData alloc] init];
    [connectionState.receivedData setLength:0];
    connectionState.callbackBlock = callback;
    //Here the StateObject is being stored with the connections Hash as it's key
    [callbacks setValue:connectionState forKey:[NSString stringWithFormat:@"%i", conn.hash]];
}

#pragma NSUrlConnectionDelegate Methods

-(void)connection:(NSConnection*)conn didReceiveResponse:
(NSURLResponse *)response 
{
    NSHTTPURLResponse *httpRes = (NSHTTPURLResponse *) response;
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if ([httpResponse statusCode] >= 400) {
        NSLog(@"Status Code: %i", [httpResponse statusCode]);
        NSLog(@"Remote url returned error %d %@",[httpResponse statusCode],[NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]]);
    }
    else {
        NSLog(@"Safe Response Code: %i", [httpResponse statusCode]);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:
(NSData *)data
{
    StateObject* connectionState = [callbacks objectForKey:[NSString stringWithFormat:@"%i", connection.hash]];
    [connectionState.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:
(NSError *)error
{    
    //We should do something more with the error handling here
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:
           NSURLErrorFailingURLStringErrorKey]);
    
    //Remove the state object on an error, or add an error callback to it and use that
    NSString* connectionHash = [NSString stringWithFormat:@"%i", connection.hash];  
    StateObject* connectionState = [callbacks objectForKey:connectionHash];    
    [callbacks removeObjectForKey:connectionHash];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{   
    NSString* connectionHash = [NSString stringWithFormat:@"%i", connection.hash];  

    //Pull out the stateobject by the connection's hash
    StateObject* connectionState = [callbacks objectForKey:connectionHash];    
    NSString *txt = [[NSString alloc] initWithData:connectionState.receivedData
                                          encoding: NSASCIIStringEncoding];    
    NSLog(@"Response data: %@", txt);
    //Call the callback that was originally sent in for this request
    connectionState.callbackBlock(txt);
    [callbacks removeObjectForKey:connectionHash];
}
@end
