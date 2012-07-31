# Geolocation - The iOS Client
This is an iOS client for a Geolocation service.  The client depends on a web service backend written in PHP which is [available here](https://github.com/WindowsAzure-Samples/Geolocation-PHP-Service).  Once the PHP site is up and running in Windows Azure Websites, the iOS client will allow users to view their current location as well as any points tagged near them in addition to upload new points of interest.  This sample was built using XCode and the iOS Framework.

Below you will find requirements and deployment instructions.

## Requirements
* OSX - This sample was built on OSX Lion (10.7.4) but should work with more current releases of OSX.
* XCode - This sample was built with XCode 4.4 and requires at least XCode 4.0 due to use of storyboards and ARC.
* Windows Azure Account - Needed to run the PHP website.  [Sign up for a free trial](https://www.windowsazure.com/en-us/pricing/free-trial/).

## Additional Resources

#Specifying your site's subdomain.
Once you've set up your PHP backend with Windows Azure Websites, you will need to enter your site's subdomain into the source/geodemo/Constants.m file.  Replace all of the \<your-subdomain\> with the subdomain of the site you set up.

    NSString *kGetPOIUrl = @"http://<Your Subdomain>.azurewebsites.net/api/Location/FindPointsOfInterestWithinRadius";
	NSString *kGetSASUrl = @"http://<Your Subdomain>.azurewebsites.net/api/blobsas/get";
	NSString *kAddPOIUrl = @"http://<Your Subdomain>.azurewebsites.net/api/location/postpointofinterest/";

## Contact

For additional questions or feedback, please contact the [team](mailto:chrisner@microsoft.com).