//
//  CGUpnpAvContentDirectory.m
//  CyberLink for C
//
//  Created by Satoshi Konno on 08/07/02.
//  Copyright 2008 Satoshi Konno. All rights reserved.
//

#import <CGUpnpAvContentDirectory.h>

@implementation CGUpnpAvContentDirectory

- (id)init
{
	if ((self = [super init]) == nil)
		return nil;
	contentMgr = [[CGUpnpAvContentManager alloc] init];
	return self;
}

- (void)dealloc
{
	[contentMgr release];
	[super dealloc];
}

- (void)finalize
{
	[contentMgr release];
	[super finalize];
}

- (CGUpnpAvObject *)objectForId:(NSString *)aObjectId
{
	return [contentMgr objectForId:aObjectId];
}

- (CGUpnpAvObject *)objectForTitlePath:(NSString *)aTitlePath
{
	return [contentMgr objectForTitlePath:aTitlePath];
}

- (NSArray *)browse:(NSString *)aObjectId;
{
	CGUpnpService *conDirService = [self getServiceForType:@"urn:schemas-upnp-org:service:ContentDirectory:1"];
	if (!conDirService)
		return nil;

	CGUpnpAction *browseAction = [conDirService getActionForName:@"Browse"];
	if (!browseAction)
		return nil;

	[browseAction setArgumentValue:aObjectId forName:@"ObjectID"];
	[browseAction setArgumentValue:@"BrowseDirectChildren" forName:@"BrowseFlag"];
	[browseAction setArgumentValue:@"*" forName:@"Filter"];
	[browseAction setArgumentValue:@"0" forName:@"StartingIndex"];
	[browseAction setArgumentValue:@"0" forName:@"RequestedCount"];
	[browseAction setArgumentValue:@"" forName:@"SortCriteria"];
	
	if (![browseAction post])
		return nil;
	
	NSString *resultStr = [browseAction argumentValueForName:@"Result"];
	
	NSError *xmlErr;
	NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithXMLString:resultStr options:0 error:&xmlErr];
	if (!xmlDoc)
		return nil;

	NSMutableArray *avObjArray = [[[NSMutableArray alloc] init] autorelease];
	
	NSArray *contentArray = [xmlDoc nodesForXPath:@"/DIDL-Lite/*" error:&xmlErr];
	for (NSXMLElement *contentNode in contentArray) {
		NSString *objId = [[contentNode attributeForName:@"id"] stringValue];
		NSArray *titleArray = [contentNode elementsForName:@"dc:title"];
		NSString *title = @"";
		for (NSXMLNode *titleNode in titleArray) {
			title = [titleNode stringValue];
			break;
		}
		if ([objId length] <= 0 || [title length] <= 0)
			continue;
		CGUpnpAvObject *avObj = nil;
		if ([[contentNode name] isEqualToString:@"container"]) {
			CGUpnpAvContainer *avCon = [[[CGUpnpAvContainer alloc] initWithXMLNode:contentNode] autorelease];
			avObj = avCon;
		}
		else {
			CGUpnpAvItem *avItem = [[[CGUpnpAvItem alloc] initWithXMLNode:contentNode] autorelease];
			NSArray *resArray = [contentNode elementsForName:@"res"];
			for (NSXMLElement *resNode in resArray) {
				CGUpnpAvResource *avRes = [[[CGUpnpAvResource alloc] initWithXMLNode:resNode] autorelease];
				[avItem addResource:avRes];
			}
			avObj = avItem;
		}
		if (avObj == nil)
			continue;
		[avObjArray addObject:avObj];
	}

	/* Update Content Manager */
	CGUpnpAvObject *parentObj = [self objectForId:aObjectId];
	if (parentObj != nil) {
		[parentObj removeAllChildren];
		[parentObj addChildren:contentArray];
	}

	return avObjArray;
}

@end

