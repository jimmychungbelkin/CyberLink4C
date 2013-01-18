
#import <Foundation/NSString.h>
#import <Foundation/NSDictionary.h>

#import <CyberLink/CGUpnpControlPoint.h>
#import <CyberLink/CGUpnpDevice.h>
#import <CyberLink/CGUpnpService.h>
#import <CyberLink/CGUpnpAction.h>
#import <CyberLink/CGUpnpStateVariable.h>
#import <CyberLink/CGUpnpIcon.h>

typedef enum UpnpDeviceStatus
{
	CgUpnpDeviceStatusAdded = 0,
	CgUpnpDeviceStatusUpdated,
	CgUpnpDeviceStatusInvalid,
	CgUpnpDeviceStatusRemoved
} UpnpDeviceStatus;

// Device types
#define DEVICETYPE_SWITCH @"urn:Belkin:device:controllee:1"
#define DEVICETYPE_SENSOR @"urn:Belkin:device:sensor:1"
#define DEVICETYPE_SOCKET @"urn:Belkin:device:socket:1"
#define DEVICETYPE_CROCKPOT @"urn:Belkin:device:crockpot:1"
#define DEVICETYPE_NETCAM @"urn:Belkin:device:NetCamSensor:1"

// Services
#define SERVICETYPEWIFI         @"urn:Belkin:service:WiFiSetup:1"
#define SERVICETYPETIMESYNC     @"urn:Belkin:service:timesync:1"
#define SERVICETYPEEVENT        @"urn:Belkin:service:basicevent:1"
#define SERVICETYPEFIRMWARE     @"urn:Belkin:service:firmwareupdate:1"
#define SERVICETYPEMETADATAINFO @"urn:Belkin:service:metainfo:1"
#define SERVICETYPERULES        @"urn:Belkin:service:rules:1"
#define SERVICETYPEREMOTEACCESS @"urn:Belkin:service:remoteaccess:1"

// Embedded device action names
#define ACT_GETFRIENDLYNAME     @"GetFriendlyName"
#define ACT_GETBINARYSTATE      @"GetBinaryState"
#define ACT_GETMETAINFO         @"GetMetaInfo"
#define ACT_GETICONURL          @"GetIconURL"
#define ACT_GETFIRMWAREVERSION  @"GetFirmwareVersion"
#define ACT_SETBINARYSTATE      @"SetBinaryState"
#define ACT_FRIENDLYNAME        @"ChangeFriendlyName"
#define ACT_TIMESYNC            @"TimeSync"
#define ACT_RESET               @"ReSetup"
#define ACT_REMOTEACCESS        @"RemoteAccess"
#define ACT_GETICONVERSION      @"GetIconVersion"
#define ACT_UPDATEICONVERSION   @"IncrementIconVersion"
#define ACT_GETSIGNALSTRENGTH   @"GetSignalStrength"
#define ACT_GETWATCHDOGFILE     @"GetWatchdogFile"


// Rules
#define ACT_UPDATEWEEKLYCALENDAR    @"UpdateWeeklyCalendar"
#define ACT_EDITWEEKLYCALENDAR      @"EditWeeklycalendar"
#define ACT_GETRULESDBPATH          @"GetRulesDBPath"
#define ACT_SETRULESDBVERSION       @"SetRulesDBVersion"
#define ACT_GETRULESDBVERSION       @"GetRulesDBVersion"

// Setup
#define ACTION_GET_APLIST           @"GetApList"
#define ACTION_CONNECT_HOME         @"ConnectHomeNetwork"
#define ACTION_GET_NETWORKSTATUS    @"GetNetworkStatus"
#define ACTION_CLOSEAP              @"CloseSetup"

// Firmware Upgrade
#define ACT_FIRMWAREUPGRADE     @"UpdateFirmware"

#define kConnectToHomeTimeout       60

#define DEVICEMODELCODE_SWITCH      @"Socket"
#define DEVICEMODELCODE_SENSOR      @"Sensor"
#define DEVICEMODELCODE_CROCKPOT    @"CrockPot"
#define DEVICEMODELCODE_NETCAM      @"NetCam"

#define FM_STATUS_DOWNLOADING             @"0"
#define FM_STATUS_DOWNLOAD_SUCCESS        @"1"
#define FM_STATUS_DOWNLOAD_UNSUCCESS      @"2"
#define FM_STATUS_UPDATE_STARTING         @"3"

#define kDeviceInfoDescription              @"smartDeviceDescription"
#define kDeviceInfoFriendlyName             @"friendlyName"
#define kDeviceInfoSerialNumber             @"serialNumber"
#define kDeviceInfoStatus                   @"status"
#define kDeviceInfoTimeStamp                @"statusTS"
#define kDeviceInfoMacAddress               @"macAddress"
#define kDeviceInfoPrivateKey               @"privateKey"
#define kDeviceInfoPluginID                 @"pluginId"
#define kDeviceInfoModelCode                @"modelCode"
#define kDeviceInfoUniqueID                 @"uniqueId"
#define kSignalStrength                     @"signalStrength"
#define KRemoteFirmwareUpgradeStatus        @"fwUpgradeStatus"
#define kRemoteFirmwareVersion              @"firmwareVersion"

#define PLUG_STATUS_NO_PEER_ADDRESS         @"No Peer Address Found"                    //2
#define PLUG_STATUS_NO_RESPONSE             @"Unable to remotely reach the WeMo device" //3
#define PLUG_STATUS_ERROR                   @"Status Error"                             //4
#define PLUG_STATUS_VALIDATION_ERROR        @"Validation Error"                         //5
#define PLUG_STATUS_VALIDATION_DB_ERROR     @"Validation Data base Error"               //6
#define PLUG_STATUS_NO_PLUGIN_IN_DB_ERROR   @"Plugin Database Error"                    //7



/** Definition for urlbase XML element name */
#define CG_UPNP_DEVICE_URLBASE_NAME "URLBase"

/** Definition for device type XML element name */
#define CG_UPNP_DEVICE_DEVICE_TYPE "deviceType"

/** Definition for device friendly name XML element name */
#define CG_UPNP_DEVICE_FRIENDLY_NAME "friendlyName"

/** Definition for device firmware version XML element name */
#define CG_UPNP_DEVICE_FIRMWARE_VERSION "firmwareVersion"

/** Definition for device manufacturer XML element name */
#define CG_UPNP_DEVICE_MANUFACTURER "manufacturer"

/** Definition for manufacturer URL XML element name */
#define CG_UPNP_DEVICE_MANUFACTURER_URL "manufacturerURL"

/** Definition for device model description XML element name */
#define CG_UPNP_DEVICE_MODEL_DESCRIPTION "modelDescription"

/** Definition fo device model name XML element name */
#define CG_UPNP_DEVICE_MODEL_NAME "modelName"

/** Definition for device model number XML element name */
#define CG_UPNP_DEVICE_MODEL_NUMBER "modelNumber"

/** Definition for device model URL XML element name */
#define CG_UPNP_DEVICE_MODEL_URL "modelURL"

/** Definition for device serial number XML element name */
#define CG_UPNP_DEVICE_SERIAL_NUMBER "serialNumber"

/** Definition for device UDN XML element name */
#define CG_UPNP_DEVICE_UDN "UDN"

/** Definition for device UPC XML element name */
#define CG_UPNP_DEVICE_UPC "UPC"

/** Definition for device presentation URL XML element name */
#define CG_UPNP_DEVICE_PRESENTATION_URL "presentationURL"

#define ICON_SIZE 160

/**
 * The CGUpnpDevice Category is a Belkin owned wrapper class around CgUpnpDevice of CyberLink for C.
 */
@interface CGUpnpDevice (Belkin)

- (NSMutableArray *)accessPointsFromApResponseString:(NSString *)response;
- (NSInteger)networkStatusCheckWithTimeout:(int)timeout;

- (int)httpPort;

- (NSString *)cipherStringForString:(NSString*)payLoadString;

/**
 * Set a Firmware Version of the device.
 * 
 * @param aFirmwareVersion Firmware Version to set.
 */
-(void)setFirmwareVersionString:(NSString *)aFirmwareVersion;


/**
 *
 * Extended interface to check for manafacturer, modelName and modelNumber
 *
 * rick@edt.ltd.uk
 */

- (NSString *)modelName;
- (NSString *)modelNumber;
- (BOOL)isManufacturer:(NSString *)aManufacturer;
- (BOOL)isModelName:(NSString *)aModelName;
- (BOOL)isModelNumber:(NSString *)aModelNumber;

/**
 * Set the firmware version of the device.
 *
 * \param dev Device in question
 * \param value The Firmware Version
 *
 */
#define cg_upnp_device_setfirmwareversion(dev, value) cg_xml_node_setchildnode(cg_upnp_device_getdevicenode(dev), CG_UPNP_DEVICE_FIRMWARE_VERSION, value)


/**
 * Get the firmware version of the device.
 *
 * \param dev Device in question
 *
 * \return The device's Firmware version
 */
#define cg_upnp_device_getfirmwareversion(dev) cg_xml_node_getchildnodevalue(cg_upnp_device_getdevicenode(dev), CG_UPNP_DEVICE_FIRMWARE_VERSION)


/**
 * Get all services in the device as a NSArray object. The array has the services as instances of CGUpnpService.
 *
 * @return NSArray of CGUpnpService.
 */
#ifndef BELKIN_DUMMYXML
- (NSArray *)services;
#else
- (NSArray *)services: (NSString *) xmlDesc;
-(NSString *) loadServiceXmlFile : (NSString *) xmlfile;
#endif
/**
 * Get a service in the device by the specified service ID.
 *
 * @param serviceId A service ID string of the service.
 *
 * @return The CGUpnpService if the specified service is found; otherwise nil.
 */
- (CGUpnpService *)getServiceForID:(NSString *)serviceId;
/**
 * Get a service in the device by the specified service type.
 *
 * @param serviceType A service type string of the service.
 *
 * @return The CGUpnpService if the specified service is found; otherwise nil.
 */
- (CGUpnpService *)getServiceForType:(NSString *)serviceType;
/**
 * Get all icons in the device as a NSArray object. The array has the services as instances of CGUpnpIconIcon.
 *
 * @return NSArray of CGUpnpIcon.
 */
- (NSArray *)icons;
/**
 * Set a user data.
 *
 * @param aUserData A user data to set.
 *
 * @return The CGUpnpService if the specified service is found; otherwise nil.
 */
- (void)setUserData:(void *)aUserData;
/**
 * Get a stored user data.
 *
 * @return A stored user data.
 */
- (void *)userData;
/**
 * Return a IP address.
 *
 * @return IP address of the device.
 */
- (NSString *)ipaddress;

- (id)lock_device_reset;
- (void)unlock_device_reset:(id)cntrlPoint;

- (NSString *)getFriendlyName;
- (NSString *)getBinaryState;
- (NSString *)getSSID;
- (NSString *)getMacAddress;

#pragma mark - Icon

- (NSString *)getIconURL;
- (NSData *)getIconDataWithURL:(NSString *)urlString;
- (UIImage *)getIcon;
- (BOOL)postIcon:(NSData *)newIconData;
- (NSString *)getIconVersion;
- (BOOL)postIconVersion;

- (NSString *)getFirmwareVersion;
#if CROCK_POT
- (NSDictionary *)getCrockPotMultiState;
- (void)setCrockPotMultiState:(NSDictionary *)stateDict;
#endif
- (void)setBinaryState:(NSString *)state;
- (BOOL)setFriendName:(NSString *)newName;
- (void)setTimeSync;
- (BOOL)resetDevice;
- (BOOL)resetSettings;
- (NSString *)getSignalStrength;
- (BOOL)uploadWatchDog;

#pragma mark - Setup

- (NSArray *)apList;
- (void)connectToHomeNetworkWithDictionary:(NSMutableDictionary *)apDict;
- (void)connectToHomeNetworkWithDictionary:(NSMutableDictionary *)apDict encryptPassword:(BOOL)encrypt;
- (void)closeAccessPoint;
- (NSInteger)networkStatus;

#pragma mark - Rules

- (BOOL)updateWeeklyCalendar:(NSMutableDictionary *)scheduleDictionary;
- (NSString *)getRulesDbVersion;
- (NSString *)getRulesDbPath;
- (void)setRulesDbVersion:(NSString *)rulesDbVersion;


#pragma mark - FirmwareUpgrade
- (void)upgradeFirmWareForDevices:(NSDictionary *)firmwareDictionary;


#pragma mark - Remote

- (int)enableRemote;


@end
