//
//  	
//  CyberLink for C
//
//  Created by Satoshi Konno on 08/03/14.
//  Copyright 2008 Satoshi Konno. All rights reserved.
//

//#include <cybergarage/upnp/cdevice.h>
//#include <cybergarage/upnp/cservice.h>
//#include <cybergarage/upnp/cicon.h>

#import "CGUpnpDevice+Belkin.h"

#import "NSString+AESCrypt.h"
#import "NSNotificationCenter+Ext.h"
#import "OpenSSLEncryption.h"
#import "Utilities.h"
#import "NetworkUtilities.h"
#import "Constants.h"

#import <objc/runtime.h>

//to save the original password for wifi to userDefaults which is required .
static void *myWifiPassword;

@implementation CGUpnpDevice (Belkin)

#pragma mark - Getters and setters for basic service information 

- (NSString *)getWifiOrignalPassword {
    return objc_getAssociatedObject(self, &myWifiPassword);
}

- (void)setWifiOrignalPassword:(NSString *)result {
    if (result) {
        objc_setAssociatedObject(self, &myWifiPassword, result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

-(void)setFirmwareVersionString:(NSString *)aFirmwareVersion
{
	if (!self.cObject)
		return;
	cg_upnp_device_setfirmwareversion(self.cObject, (char *)[aFirmwareVersion UTF8String]);
}

#pragma mark - UPnP convenience methods

- (BOOL)isManufacturer:(NSString *)aManufacturer
{
	return [aManufacturer isEqualToString:[self manufacturer]];
}

#pragma mark - Services

- (int)httpPort
{
    if (!self.cObject)
		return 0;
	
	int port =0 ;
	char *location_str = cg_upnp_device_getlocationfromssdppacket(self.cObject);
	if (0 < cg_strlen(location_str)) {
		CgNetURL *url = cg_net_url_new();
		cg_net_url_set(url, location_str);
		port = cg_net_url_getport(url);
		cg_net_url_delete(url);
	}
	
	return port;
}

#pragma mark - Lock

- (id)lock_device_reset
{
    return cg_upnp_lock_device_while_reset(self.cObject);
}

- (void)unlock_device_reset:(id)cntrlPoint
{
    cg_upnp_unlock_device_while_reset((void*)cntrlPoint);
}

#ifdef BELKIN_DUMMYXML
-(NSString *) loadServiceXmlFile : (NSString *) xmlfile
{
    
    char * str = cg_upnp_device_loadfile((char*) [xmlfile UTF8String]);
    NSString * xmldesc = [[NSString alloc] initWithUTF8String:str];
    return xmldesc;
    
}
#endif

#pragma mark - Device Information and control

- (NSString *)getFriendlyName
{
    CGUpnpService *service = [self getServiceForType:SERVICETYPEEVENT];
    CGUpnpAction *action = [service getActionForName:ACT_GETFRIENDLYNAME];
    [action post];
    
    NSDictionary* friendlyNameDict = [action arguments];
    return [friendlyNameDict valueForKey:@"FriendlyName"];
}

- (BOOL)setFriendName:(NSString *)newName
{
    CGUpnpService *service = [self getServiceForType:SERVICETYPEEVENT];
    CGUpnpAction *action = [service getActionForName:ACT_FRIENDLYNAME];
    [action setArgumentValue:newName forName:@"FriendlyName"];
    return [action post];
}

- (NSString *)getBinaryState
{
    CGUpnpService *service = [self getServiceForType:SERVICETYPEEVENT];
    CGUpnpAction *action = [service getActionForName:ACT_GETBINARYSTATE];
    [action post];
    
    NSDictionary* binaryStateDict = [action arguments];
    return [binaryStateDict valueForKey:@"BinaryState"];
}

- (void)setBinaryState:(NSString *)state
{
    dispatch_async(dispatch_get_global_queue(0, 0),
                   ^{
                       CGUpnpService *service = [self getServiceForType:SERVICETYPEEVENT];
                       CGUpnpAction *action = [service getActionForName:ACT_SETBINARYSTATE];
                       [action setArgumentValue:state forName:@"BinaryState"];
                       BOOL success = [action post];
                       
                       NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:success],@"setBinaryState",state, [self udn], [self deviceType], nil] forKeys:[NSArray arrayWithObjects:@"ActionSuccessful",@"ActionType",@"BinaryState",@"UDN",@"DeviceType",nil]];
                       [[NSNotificationCenter defaultCenter] postNotificationName:NSNOTIFICATION_UPNPACTIONFINISHED object:nil userInfo:userInfo];
                   });
}

#if CROCK_POT
/**
 Method block to get the status Dictionary  of crock pot
 @return  NSDictionary status Dictionary of crockpot
 */
- (NSDictionary *)getCrockPotMultiState
{
    CGUpnpService *service = [self getServiceForType:SERVICETYPEEVENT];
    CGUpnpAction *action = [service getActionForName:ACT_GETBINARYSTATE];
    [action post];
    
    NSDictionary* binaryStateDict = [action arguments];
    return binaryStateDict;
}

/**
 Method block for updating the status Dictionary  of crock pot
 @param  stateDict status Dictionary of crockpot
 */
- (void)setCrockPotMultiState:(NSDictionary *)stateDict
{
    dispatch_async(dispatch_get_global_queue(0, 0),
                   ^{
#if CROCK_POT_DEMO
                       CGUpnpService *service = [self getServiceForType:SERVICETYPEEVENT];
                       CGUpnpAction *action = [service getActionForName:ACT_SETBINARYSTATE];
                       [action setArgumentValue:[stateDict objectForKey:@"mode"] forName:@"BinaryState"];
                       BOOL success = [action post];
                       
                       NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:success],@"setBinaryState",[stateDict objectForKey:@"mode"], [self udn], [self deviceType], nil] forKeys:[NSArray arrayWithObjects:@"ActionSuccessful",@"ActionType",@"BinaryState",@"UDN",@"DeviceType",nil]];
                       [[NSNotificationCenter defaultCenter] postNotificationName:NSNOTIFICATION_UPNPACTIONFINISHED object:nil userInfo:userInfo];
                       
#else
                       
                       CGUpnpService *service = [self getServiceForType:SERVICETYPEEVENT];
                       CGUpnpAction *action = [service getActionForName:ACT_SETBINARYSTATE];
                       [action setArgumentValue:[stateDict objectForKey:@"mode"] forName:@"mode"];
                       [action setArgumentValue:[stateDict objectForKey:@"timeVariable"] forName:@"timeVariable"];
                       BOOL success = [action post];
                       
                       // NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:success],@"setCrockPotState",[stateDict objectForKey:@"mode"], [self udn], [self deviceType], nil] forKeys:[NSArray arrayWithObjects:@"ActionSuccessful",@"ActionType",@"CrockPotState",@"UDN",@"DeviceType",nil]];
                       NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:success],@"setCrockPotState",[stateDict objectForKey:@"mode"], [stateDict objectForKey:@"timeVariable"],[self udn], [self deviceType], nil] forKeys:[NSArray arrayWithObjects:@"ActionSuccessful",@"ActionType",@"mode",@"timeVariable",@"UDN",@"DeviceType",nil]];
                       [[NSNotificationCenter defaultCenter] postNotificationName:NSNOTIFICATION_UPNPACTIONFINISHED object:nil userInfo:userInfo];
#endif
                   });

}
#endif

- (NSString *)getSSID
{
    CGUpnpService *service = [self getServiceForType:SERVICETYPEMETADATAINFO];
    CGUpnpAction *action = [service getActionForName:ACT_GETMETAINFO];
    [action post];
    
    CGUpnpStateVariable * cgStateVar = [service getStateVariableForName:@"MetaInfo"];
    
    // [cgStateVar value] is 000C4300D00C|221138K0100D03|Plugin Device|WeMo_WW_1.01.1139.PVT|WeMo.D03|Socket
    if (cgStateVar)
    {
        NSArray *pipeSeparatedParsedString = [[cgStateVar value] componentsSeparatedByString:@"|"];
        if ([pipeSeparatedParsedString count]>4) 
            return [pipeSeparatedParsedString objectAtIndex:4];
    }
    return @"";
}

/**
	Get mac address by running action on cgupnp device  and returnresult.
	@returns returns mac address if service succes else return nil.
 */
- (NSString *)getMacAddress
{
    CGUpnpService *service = [self getServiceForType:SERVICETYPEMETADATAINFO];
    CGUpnpAction *action = [service getActionForName:ACT_GETMETAINFO];
    [action post];
    
    CGUpnpStateVariable * cgStateVar = [service getStateVariableForName:@"MetaInfo"];
    
    // [cgStateVar value] is 000C4300D00C|221138K0100D03|Plugin Device|WeMo_WW_1.01.1139.PVT|WeMo.D03|Socket
    if (cgStateVar)
    {
        NSArray *pipeSeparatedParsedString = [[cgStateVar value] componentsSeparatedByString:@"|"];
        if ([pipeSeparatedParsedString count]>0)
            return [pipeSeparatedParsedString objectAtIndex:0];
    }
    return nil;
}

- (NSString *)getFirmwareVersion
{
    CGUpnpService *service = [self getServiceForType:SERVICETYPEFIRMWARE];
    CGUpnpAction *action = [service getActionForName:ACT_GETFIRMWAREVERSION];
    [action post];
    
    // Need to parse! Values returned look like this:
    //[action arguments]::              FirmwareVersion = "FirmwareVersion:WeMo_WW_1.01.1139.PVT|SkuNo:Plugin Device"
    //firmwareVersionExtraLong::        FirmwareVersion:WeMo_WW_1.01.1139.PVT|SkuNo:Plugin Device
    //firmwareVersionLong::             FirmwareVersion:WeMo_WW_1.01.1139.PVT
    //return value::                    WeMo_WW_1.01.1139.PVT
    
    NSString *firmwareVersionExtraLong = [[action arguments] valueForKey:@"FirmwareVersion"];
    NSString *firmwareVersionLong = [[firmwareVersionExtraLong componentsSeparatedByString:@"|"] objectAtIndex:0];
    NSArray *firmwareVersionArray=[firmwareVersionLong componentsSeparatedByString:@":"];
    
    NSString* firmwareVersion = @"";
    if ([firmwareVersionArray count] > 1)
        firmwareVersion = [firmwareVersionArray objectAtIndex:1];

    [self setFirmwareVersionString:firmwareVersion];
    return firmwareVersion;
}

- (void)setTimeSync
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"Z"]; 
    NSString *temp = [dateFormatter stringFromDate:[NSDate date]];
    NSString *timeZone=[temp substringToIndex:3];
    
    float temp2 = [[temp substringWithRange: NSMakeRange(3, 2)] floatValue];
    temp2 = temp2/60;
    NSString *temp3 = [[NSString stringWithFormat:@"%0.2f",temp2] substringWithRange: NSMakeRange(1, 3)];
    timeZone = [timeZone stringByAppendingString:temp3];
    if ([[timeZone substringToIndex:1] isEqualToString:@"+"]) {
        timeZone = [timeZone substringWithRange: NSMakeRange(1, 5)];
    }
    //getting the dst value from timezone
    NSTimeZone * tz =  [NSTimeZone systemTimeZone];
    //DST_Supported new parameter added on 20th Jan 2012  Hemant/Viral
    [dateFormatter setDateFormat:@"EEEE"]; 
    NSDate *currentdate = [tz nextDaylightSavingTimeTransition];
    NSString * dstsupported = @"0";
    
    if (currentdate)
    {
        dstsupported = @"1";
    }
    //DST_Supported new parameter added on 20th Jan 2012  Hemant/Viral --- End
    BOOL isDST = [tz isDaylightSavingTime];
    NSString * dst = @"0";
    if (isDST == YES)
    {
        dst = @"1";
    }
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970];
    NSString * utc =[NSString stringWithFormat:@"%0.0f",timeInMiliseconds];
    //DLog(@"UTC = %@",utc);
    
    [dateFormatter release];
    
    CGUpnpService *service = [self getServiceForType:SERVICETYPETIMESYNC];
    CGUpnpAction *action = [service getActionForName:ACT_TIMESYNC];
    [action setArgumentValue:utc forName:@"UTC"];
    [action setArgumentValue:timeZone forName:@"TimeZone"];
    [action setArgumentValue:dst forName:@"dst"];
    [action setArgumentValue:dstsupported forName:@"DstSupported"];
    [action post];
}

- (NSString *)getSignalStrength
{
    CGUpnpService *service = [self getServiceForType:SERVICETYPEEVENT];
    CGUpnpAction *action = [service getActionForName:ACT_GETSIGNALSTRENGTH];
    [action post];
    NSDictionary* signalStrengthDictionary = [action arguments];
    
    return [signalStrengthDictionary valueForKey:@"SignalStrength"];
}
- (BOOL)uploadWatchDog
{
    CGUpnpService *service = [self getServiceForType:SERVICETYPEEVENT];
    CGUpnpAction *action = [service getActionForName:ACT_GETWATCHDOGFILE];
    BOOL result =[action post];
    
    DLog(@"Upload watch dog post result %d response -- %@ ", result,[action arguments]);
    NSString *deviceWatchDogStatus = [action argumentValueForName:@"WDFile"];
    
    if (deviceWatchDogStatus && [deviceWatchDogStatus isEqualToString:@"Sending"])
    {
        return YES;
    }
    return NO;
}
#pragma mark Icon

- (NSString *)getIconURL
{
    CGUpnpService *service = [self getServiceForType:SERVICETYPEEVENT];
    int retry=3;
    NSString *iconURL = NULL;
    
    while (retry != 0)
    { 
        CGUpnpAction * action = [service getActionForName:ACT_GETICONURL];
        [action post];
        
        NSDictionary* iconURLDict = [action arguments];
        iconURL = [iconURLDict valueForKey:@"URL"];
        //DLog(@"icon url = %@",iconURL);
        
        if (iconURL == NULL)
        {
            NSLog(@"ERROR : icon url is NULL");
            retry--;
        }
        else
            break;
    }
    
    if ((retry == 0) && (iconURL == NULL))
        return @"";
    
    return iconURL;
}

- (NSData *)getIconDataWithURL:(NSString *)urlString
{    
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data;
}

- (UIImage *)getIcon
{
    NSString *iconURL = [self getIconURL];
    NSData *iconData = [self getIconDataWithURL:iconURL];
    
    // These icons from the firmware are incorrect, so we will to replace them with the image from the app.
    if ([iconData length]==2966         // switch image from FW 1105PVT
        || [iconData length]==2700      // sensor image from FW 1105PVT
        || [iconData length]==5571      // switch image from FW 993/997PVT
        || [iconData length]==2663)     // sensor image from FW 993/997PVT
    {
        if ([[self deviceType] isEqualToString:DEVICETYPE_SWITCH] == YES || [[self deviceType] isEqualToString:DEVICETYPE_SOCKET] == YES)
            iconData = UIImagePNGRepresentation([UIImage imageNamed:@"ic_switch.png"]);
        else if ([[self deviceType] isEqualToString:DEVICETYPE_SENSOR] == YES)
            iconData = UIImagePNGRepresentation([UIImage imageNamed:@"ic_sensor.png"]);
        else if ([[self deviceType] isEqualToString:DEVICETYPE_CROCKPOT] == YES)
            iconData = UIImagePNGRepresentation([UIImage imageNamed:@"ic_crockpot.png"]);
        else if ([[self deviceType] isEqualToString:DEVICETYPE_NETCAM] == YES)
            iconData = UIImagePNGRepresentation([UIImage imageNamed:@"ic_netcam_nobg.png"]);
    }
    
    return [UIImage imageWithData:iconData];
}

- (BOOL)postIcon:(NSData *)newIconData
{
    NSString *iconURL = [self getIconURL];
    if([iconURL length] > 0) 
    {
        NSString *postLength = [NSString stringWithFormat:@"%d", [newIconData length]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setHTTPMethod:@"POST"];
        [request setURL:[NSURL URLWithString:iconURL]];
        [request setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:newIconData];
        
        NSURLResponse *urlresponse = nil;
        NSError *error = nil;
        NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlresponse error:&error];
        [request release];
        
        if (result == nil) 
        {
            if (error != nil) 
            {
            }
            return NO;
        }
        return YES;
    }
    
    return NO;
}

- (NSString *)getIconVersion
{   
    CGUpnpService *service = [self getServiceForType:SERVICETYPEEVENT];
    CGUpnpAction *action = [service getActionForName:ACT_GETICONVERSION];
    
    if (action == nil) 
    {
        // Not every firmware version supports icon versioning
        return nil;
    }
    
    if([action post])
    {
        NSDictionary *iconVersion = [action arguments];
        return [iconVersion valueForKey:@"IconVersion"];        
    }
    
    return @"";
}

- (BOOL)postIconVersion
{   
    CGUpnpService *service = [self getServiceForType:SERVICETYPEEVENT];
    CGUpnpAction *action = [service getActionForName:ACT_UPDATEICONVERSION];
    
    if (action == nil) 
    {
        // Not every firmware version supports icon versioning
        return NO;
    }
    
    if([action post])
    {
        return YES;        
    }
    
    return NO;
}

#pragma mark Device Reset

- (BOOL)resetDevice
{
    CGUpnpService *service = [self getServiceForType:SERVICETYPEEVENT];
    CGUpnpAction *action = [service getActionForName:ACT_RESET];
    [action setArgumentValue:@"2" forName:@"Reset"];
    
    BOOL actionResponseStatus = [action post];
    if(actionResponseStatus)
    {        
        CGUpnpStateVariable *cgStateVar = [service getStateVariableForName:@"Reset"];
        NSString *result = [cgStateVar value];
        DLog(@"Reset status = %@",result);
        
        if ([result isEqualToString:@"success"] == YES)
            return YES;
        else
            return NO;
    }
    
    return NO;
}

- (BOOL)resetSettings
{
    CGUpnpService *service = [self getServiceForType:SERVICETYPEEVENT];
    CGUpnpAction *action = [service getActionForName:ACT_RESET];
    [action setArgumentValue:@"1" forName:@"Reset"];
    
    BOOL actionResponseStatus = [action post];
    if(actionResponseStatus)
    {        
        CGUpnpStateVariable *cgStateVar = [service getStateVariableForName:@"Reset"];
        NSString *status = [cgStateVar value];
        DLog(@"Reset status = %@",status);
        
        if ([status isEqualToString:@"success"] == YES)
            return YES;
        else
            return NO;
    }
    
    return NO;
}

#pragma mark Firmware Upgrade

/**
 Method block for updating the new firmware version for the devices
 @param firmwareDictionary Dictionary holding the firmware version details
 */
- (void)upgradeFirmWareForDevices:(NSDictionary *)firmwareDictionary
{
    // Getting the version, url , releaseData and signature from the dictionary
    NSString *version = [NSString stringWithFormat:@"%@",[firmwareDictionary valueForKey:@"VERSION"]];;
    NSString *url = [NSString stringWithFormat:@"%@",[firmwareDictionary valueForKey:@"URL"]];;
    NSString *releaseDate =[NSString stringWithFormat:@"%@",[firmwareDictionary valueForKey:@"RELEASEDATE"]];; 
    NSString *signature = [NSString stringWithFormat:@"%@",[firmwareDictionary valueForKey:@"SIGNATURE"]];;
    NSString *downloadStartTime = [NSString stringWithFormat:@"%@",[firmwareDictionary valueForKey:DOWNLOAD_START_TIME]];;
    
    //Creating a service of type firmwareupgrade....
    CGUpnpService *service = [self getServiceForType:SERVICETYPEFIRMWARE];
    CGUpnpAction *action = [service getActionForName:ACT_FIRMWAREUPGRADE];
    
    //Setting the parameters to the action ..
    [action setArgumentValue:version forName:@"NewFirmwareVersion"];
    [action setArgumentValue:releaseDate forName: @"ReleaseDate"];
    [action setArgumentValue:url forName:@"URL"];
    [action setArgumentValue:signature forName:@"Signature"];
    [action setArgumentValue:downloadStartTime forName:DOWNLOAD_START_TIME];
    
    BOOL isSuccess = [action post];
    DLog(@"UpgradeFirmware Post: %d",isSuccess);
}

#pragma mark - Rules

- (BOOL)updateWeeklyCalendar:(NSMutableDictionary *)scheduleDictionary
{
    BOOL isSuccess = NO;
    
    // if in local mode-- remote case is not handled here
    if([[scheduleDictionary valueForKey:@"MONDAY"] isEqualToString:@""]==NO || [[scheduleDictionary valueForKey:@"TUESDAY"] isEqualToString:@""]==NO || [[scheduleDictionary valueForKey:@"WEDNESDAY"] isEqualToString:@""]==NO || [[scheduleDictionary valueForKey:@"THURSDAY"] isEqualToString:@""]==NO || [[scheduleDictionary valueForKey:@"FRIDAY"] isEqualToString:@""]==NO || [[scheduleDictionary valueForKey:@"SATURDAY"] isEqualToString:@""]==NO || [[scheduleDictionary valueForKey:@"SUNDAY"] isEqualToString:@""]==NO )
    {
        CGUpnpService *service = [self getServiceForType:SERVICETYPERULES];
        CGUpnpAction *action = [service getActionForName:ACT_UPDATEWEEKLYCALENDAR];
        [action setArgumentValue:[scheduleDictionary valueForKey:@"MONDAY"] forName:@"Mon"];
        [action setArgumentValue:[scheduleDictionary valueForKey:@"TUESDAY"] forName: @"Tues"];
        [action setArgumentValue:[scheduleDictionary valueForKey:@"WEDNESDAY"] forName:@"Wed"];
        [action setArgumentValue:[scheduleDictionary valueForKey:@"THURSDAY"] forName:@"Thurs"];
        [action setArgumentValue:[scheduleDictionary valueForKey:@"FRIDAY"] forName:@"Fri"];
        [action setArgumentValue:[scheduleDictionary valueForKey:@"SATURDAY"] forName:@"Sat"];
        [action setArgumentValue:[scheduleDictionary valueForKey:@"SUNDAY"] forName:@"Sun"];
        isSuccess = [action post];
    }
    else
    {
        CGUpnpService *service = [self getServiceForType:SERVICETYPERULES];
        CGUpnpAction *action = [service getActionForName:ACT_EDITWEEKLYCALENDAR];
        [action setArgumentValue:@"2" forName:@"action"];
        isSuccess = [action post];
    }
    
    return isSuccess;
}

- (NSString *)getRulesDbVersion
{
    // if in local mode
    CGUpnpService *service = [self getServiceForType:SERVICETYPERULES];
    CGUpnpAction *action = [service getActionForName:ACT_GETRULESDBVERSION];
    [action post];
    
    NSDictionary* rulesDbVersionDict = [action arguments];
    if([rulesDbVersionDict valueForKey:@"RulesDBVersion"] != NULL)
        return [rulesDbVersionDict valueForKey:@"RulesDBVersion"];
    else
        return @"";
}

- (NSString *)getRulesDbPath
{
    CGUpnpService *service = [self getServiceForType:SERVICETYPERULES];
    CGUpnpAction *action = [service getActionForName:ACT_GETRULESDBPATH];
    [action post];
    
    NSDictionary* rulesDbPathDict = [action arguments];
    if([rulesDbPathDict valueForKey:@"RulesDBPath"]!= NULL)
        return [rulesDbPathDict valueForKey:@"RulesDBPath"];
    else
        return @"";
}

- (void)setRulesDbVersion:(NSString *)rulesDbVersion
{
    CGUpnpService *service = [self getServiceForType:SERVICETYPERULES];
    CGUpnpAction *action = [service getActionForName:ACT_SETRULESDBVERSION];
    [action setArgumentValue:rulesDbVersion forName:@"RulesDBVersion"];
    [action post];
}

#pragma mark - Setup

- (NSArray *)apList
{
    CGUpnpService *setupService = [self getServiceForType:SERVICETYPEWIFI];
    CGUpnpAction *apListAction = [setupService getActionForName:ACTION_GET_APLIST];
    
    NSMutableArray *accessPoints = [NSMutableArray array];
    NSInteger apListChunkCount = 0;
    NSInteger apListActionPostCount = 0;
    
    // The list of access points is provided by the WeMo device in chunks in response to multiple action posts.
    do
    {
        apListActionPostCount++;
        
        // Synchronous HTTP Post message.
        if ([apListAction post])
        {
            // The response of previous post is recieved as an in-argument.
            NSString *apListChunk = [apListAction argumentValueForName:@"ApList"];
            
            // Find out (once) number of times the post message needs to be sent (= number of pages of resp.)
            NSArray *responsePieces = [apListChunk componentsSeparatedByString:@"/"];
            if (apListChunkCount == 0 && responsePieces.count > 1)
                apListChunkCount = [[responsePieces objectAtIndex:1] integerValue];
            
            [accessPoints addObjectsFromArray:[self accessPointsFromApResponseString:apListChunk]];
        }
    }
    while (apListActionPostCount < apListChunkCount);
        
    // Sort the access point list alphabetically
    return [accessPoints sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"SSID" ascending:YES], nil]];
}

- (void)connectToHomeNetworkWithDictionary:(NSMutableDictionary *)apDict
{
    [self connectToHomeNetworkWithDictionary:apDict encryptPassword:YES];
}

- (void)connectToHomeNetworkWithDictionary:(NSMutableDictionary *)apDict encryptPassword:(BOOL)encrypt
{
    // Do time sync prior to connect home???
    [self setTimeSync];
    self.wifiOrignalPassword = [apDict objectForKey:@"PASSWORD"];
    if ([[self getWifiOrignalPassword] isEqualToString:@""] == NO)
    {
        if(encrypt == NO)
        {
            NSString *decryptedPassword = [[self getWifiOrignalPassword] AES256DecryptWithKey:AESKeyString];
            [self setWifiOrignalPassword:decryptedPassword];
            [apDict setValue:decryptedPassword forKey:@"PASSWORD"];
        }
        
        NSString *encryptedPassword = [self cipherStringForString:[self getWifiOrignalPassword]];
        [apDict setValue:encryptedPassword forKey:@"PASSWORD"];
    }
    
    CGUpnpService *setupService = [self getServiceForType:SERVICETYPEWIFI];
    CGUpnpAction *setupHomeNetwork = [setupService getActionForName:ACTION_CONNECT_HOME];
    
    [setupHomeNetwork setArgumentValue:[apDict objectForKey:@"SSID"] forName:@"ssid"];
    [setupHomeNetwork setArgumentValue:[apDict objectForKey:@"AUTH"] forName:@"auth"];
    [setupHomeNetwork setArgumentValue:[apDict objectForKey:@"PASSWORD"] forName:@"password"];
    [setupHomeNetwork setArgumentValue:[apDict objectForKey:@"ENCRYPT"] forName:@"encrypt"];
    [setupHomeNetwork setArgumentValue:[apDict objectForKey:@"CHANNEL"] forName:@"channel"];
    
    int setupStatus = -1;
    
    // Synchronus post to WeMo Device
    if([setupHomeNetwork post] == YES)
    {
        // Give the connect home message a chance to reach the plugin.  
        // Oddly, in some circumstances, the getNetworkStatus was reaching before the Connect Home
        [NSThread sleepForTimeInterval:2];
    
        // returned only after success or 60 sec time out
        setupStatus = [self networkStatusCheckWithTimeout:kConnectToHomeTimeout];
        DLog(@"*** Setup plugin, final network status: %d ***", setupStatus);
        
        if(setupStatus == 1 || setupStatus == 3)
        {
            // Persist dictionary for fast setup via save wifi information
            NSString *encryptedPassword = [[self getWifiOrignalPassword] AES256EncryptWithKey:AESKeyString];
            [apDict setValue:encryptedPassword forKey:@"PASSWORD"];
            NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
            [preferences setObject:apDict forKey:NSUserDefaultsSetupDictionary];
            [preferences synchronize];
            
            //************************************************************************************************//
            // Set home network SSID if not already configured
            //************************************************************************************************//
            if([NetworkUtilities isHomeNetworkSet] == NO && [[apDict objectForKey:@"SSID"] length] > 0)
            {
                // 1. When setting up the first WeMo device, the user most likely does not have a home network set
                //    in NSUserDefaults.  In this case, we want to set the network that the WeMo was paired to.  
                // 2. When enabling remote from the More screen, the home network should already be configured.  
                // 3. When enabling remote from discovery (as the second iOS client on an already setup WeMo network),
                //    the home network should also be configured.  
                if([NetworkUtilities isPluginWithSSID:[apDict objectForKey:@"SSID"]] == NO)
                {
                    // Double check that we did not switch to a WeMo AP
                    [NetworkUtilities setHomeNetworkSSID:[apDict objectForKey:@"SSID"]];
                }
            }            
        }
    }
    
    [[NSNotificationCenter defaultCenter] postOnMainThreadWithNotificationName:@"ConnectToHomeComplete" object:[NSNumber numberWithInt:setupStatus]];
}

- (void)closeAccessPoint
{
    CGUpnpService *service = [self getServiceForType:SERVICETYPEWIFI];
    CGUpnpAction *cgUPnPAction = [service getActionForName:ACTION_CLOSEAP];
    [cgUPnPAction closeApActionPost];    
}

- (NSInteger)networkStatus
{
    CGUpnpService *setupService = [self getServiceForType:SERVICETYPEWIFI];
    CGUpnpAction *getNetworkStatusAfterSetup = [setupService getActionForName:ACTION_GET_NETWORKSTATUS];
    
    // Synchronus post to WeMo Device
    [getNetworkStatusAfterSetup post];
    
    NSString *statusString = [getNetworkStatusAfterSetup argumentValueForName:@"NetworkStatus"];
    return [statusString integerValue];
}

#pragma mark - Remote

- (int)enableRemote
{
    CGUpnpService *remoteService = [self getServiceForType:SERVICETYPEREMOTEACCESS];
    CGUpnpAction *enableRemote = [remoteService getActionForName:ACT_REMOTEACCESS];
    
    NSString *devicenameString = [[UIDevice currentDevice] name];
    DLog(@"Before devicenameString = %@", devicenameString);
    devicenameString = [devicenameString stringByReplacingOccurrencesOfString:@"&" withString:@"U+0026"];
    devicenameString = [devicenameString stringByReplacingOccurrencesOfString:@"<" withString:@"U+003C"];
    devicenameString = [devicenameString stringByReplacingOccurrencesOfString:@">" withString:@"U+003E"];
    devicenameString = [devicenameString stringByReplacingOccurrencesOfString:@"\"" withString:@"U+0022"];
    devicenameString = [devicenameString stringByReplacingOccurrencesOfString:@"\'" withString:@"U+0027"];
    DLog(@"After devicenameString = %@", devicenameString);
    
    [enableRemote setArgumentValue:[Utilities uniqueIdentifier] forName:@"DeviceId"];
    [enableRemote setArgumentValue:[Utilities daylightSavingsTimeForRemote] forName:@"dst"];
    [enableRemote setArgumentValue:devicenameString forName:@"DeviceName"];
    [enableRemote setArgumentValue:@"" forName:@"pluginprivateKey"];
    [enableRemote setArgumentValue:@"" forName:@"smartprivateKey"];
    [enableRemote setArgumentValue:@"" forName:@"smartUniqueId"];
    
    /***************************************************************************
     Added App Auth Header to the RemoteAccess UPnP Action
     to enable plugin registration using App's Auth Header
     ***************************************************************************/
    NSString* privateKey  = [NetworkUtilities getRemotePrivateKey];;
    
#if SEND_APP_PRIVATE_KEY
    [cgUPnPAction setArgumentValue:privateKey forName:@"AppPrivateKey"];
#else     
    NSString* authHeader = @"";
    
    if (privateKey.length > 0)
        authHeader = [Utilities authHeaderWithPrivateKey:privateKey];
    
    [enableRemote setArgumentValue:authHeader forName:@"DeviceAuthHeader"];
#endif
    
    /***************************************************************************/
    
    
    
    if([[NetworkUtilities getRemoteHomeID] length] > 0)
        [enableRemote setArgumentValue:[NetworkUtilities getRemoteHomeID] forName:@"HomeId"];
    else
        [enableRemote setArgumentValue:@"" forName:@"HomeId"];

    DLog(@"RemoteAccess, submit post");
    if([enableRemote post])
    {
        NSString *statusCode = [[remoteService getStateVariableForName:@"statusCode"] value];
        DLog(@"remoteaccess statuscode = %@", statusCode);
        
        if(statusCode == nil || statusCode == NULL)
        {
            return PERFORM_ACTION_FAIL;
        }
        
        if([statusCode isEqualToString:@"F"] == YES)
        {
            NSString *resultCode = [[remoteService getStateVariableForName:@"resultCode"] value];
            DLog(@"remoteaccess fail, resultCode = %@", resultCode);
            if([resultCode isEqualToString:AUTH_BAD_REQUEST] == YES) 
            {
                return PERFORM_ACTION_AUTH_FAIL;
            }
            return PERFORM_ACTION_FAIL;       
        }
        else if([statusCode isEqualToString:@"S"])
        {
            // Story: 606
            // Sometimes, one of the service calls (smartprivateKey or homeId) fails and it returns null.
            // If we were to store null, and then send a null key to the server, we end up with "authorization fail" 
            // errors due to key mismatch.  Instead, we only save private key and home id if both values are fetched ok.
            NSString *smartprivateKey = [[remoteService getStateVariableForName:@"smartprivateKey"] value];
            NSString *homeId = [[remoteService getStateVariableForName:@"homeId"] value];
            if([smartprivateKey length]>0 && [homeId length]>0) 
            {
                [NetworkUtilities setRemotePrivateKey:smartprivateKey];
                [NetworkUtilities setRemoteHomeID:homeId];
                
                return PERFORM_ACTION_SUCCESS;

            }
            else
            {
                DLog(@"Enable Remote error:  did not receive either private key (%@) or home id (%@)", smartprivateKey, homeId);
            }

            return PERFORM_ACTION_FAIL;
        }
        else
        {
            return PERFORM_ACTION_FAIL;
        }
    }

    return PERFORM_ACTION_FAIL;
}

#pragma mark - Private Methods

// Returns array of Access Point detail dictionaries by parsing the response string of a single post response.
- (NSMutableArray *)accessPointsFromApResponseString:(NSString *)response
{
    NSString *apDetailsString = [response substringFromIndex:[response rangeOfString:@"$"].location + 1];
    NSArray *apStrings = [apDetailsString componentsSeparatedByString:@","];
    
    NSMutableArray *accessPoints  = [NSMutableArray array];
    for (NSString *apString in apStrings)
    {
        // Skip if there is a blank string (There is always one at last because of an unwanted comma afer the last item in the set.)
        if (apString.length < 7) 
            continue; // A min length of 7 chars e.g. "a|1|2|d"
        
        // Do not add WeMo access points to the list of available SSID's
        NSArray *apStringPieces = [apString componentsSeparatedByString:@"|"];
        if([apStringPieces objectAtIndex:0] && [[[apStringPieces objectAtIndex:0] substringFromIndex:1] rangeOfString:@"WeMo."].location == NSNotFound)
        {
            NSMutableDictionary *apDict = [NSMutableDictionary dictionary];
            
            [apDict setObject:[[apStringPieces objectAtIndex:0] substringFromIndex:1] forKey:@"SSID"];
            [apDict setObject:[apStringPieces objectAtIndex:1] forKey:@"CHANNEL"];
            [apDict setObject:[apStringPieces objectAtIndex:2] forKey:@"SIGNALSTRENGTH"];
            
            NSArray *authAndEncryption = [[apStringPieces objectAtIndex:3] componentsSeparatedByString:@"/"];
            [apDict setObject:[authAndEncryption objectAtIndex:0] forKey:@"AUTH"];
            [apDict setObject:(authAndEncryption.count > 1) ? [authAndEncryption objectAtIndex:1] : @"" forKey:@"ENCRYPT"];
            
            [accessPoints addObject:apDict];
        }
    }
    
    return accessPoints;
}

- (NSInteger)networkStatusCheckWithTimeout:(int)timeout
{
    NSDate *startingTime = [NSDate date];
    
    NSInteger status = [self networkStatus];
    while(status != 1 && status != 2 && status != 4)
    {
        NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:startingTime];
        if (diff > timeout)
        { 
            break;
        }
        
        sleep(1);
        status = [self networkStatus];
        DLog(@"Setup plugin, network status check: %d", status);
    }
    
    return status;
}

- (NSString *)cipherStringForString:(NSString *)payLoadString
{
    CGUpnpService *deviceMetaInfoService = [self getServiceForType:SERVICETYPEMETADATAINFO];
    CGUpnpAction *getDeviceMetaInfo = [deviceMetaInfoService getActionForName:ACT_GETMETAINFO];
    
    // Synchronus post to WeMo Device
    [getDeviceMetaInfo post];
    
    // MetaInfo is a state variable in the WeMo device exposed by SERVICETYPEMETADATAINFO
    NSString *deviceInfoString = [[deviceMetaInfoService getStateVariableForName:@"MetaInfo"] value];
    NSString *cipherString = [OpenSSLEncryption cipherStringForPayload:payLoadString withDeviceInfo:deviceInfoString];
    
    return cipherString;
}
@end