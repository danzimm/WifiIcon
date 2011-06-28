#import <SpringBoard/SpringBoard.h>
#import "SBIconViewMap.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

@interface SBIconModel (meislazy)
-(id)leafIconForIdentifier:(id)identifier;
@end

@interface SBIcon (meh)
- (void)updateIconLabel;
@end

@interface SBIconLabel (lazzyagain)
- (void)setText:(id)text;
@end

@interface SBIconController (meh)
-(id)currentRootIconList;
@end

@interface NSObject (GAH)
-(BOOL)containsIcon:(id)idcon;
@end

static int _currentMode = 0;

static BOOL _held = NO;

	//Stolen! thanks ryan
static inline NSString *GetIPAddress()
{
	NSString *result = nil;
	struct ifaddrs *interfaces;
	char str[INET_ADDRSTRLEN];
	if (getifaddrs(&interfaces))
		return nil;
	struct ifaddrs *test_addr = interfaces;
	while (test_addr) {
		if(test_addr->ifa_addr->sa_family == AF_INET) {
			if (strcmp(test_addr->ifa_name, "en0") == 0) {
				inet_ntop(AF_INET, &((struct sockaddr_in *)test_addr->ifa_addr)->sin_addr, str, INET_ADDRSTRLEN);
				result = [NSString stringWithUTF8String:str];
				break;
			}
		}
		test_addr = test_addr->ifa_next;
	}
	freeifaddrs(interfaces);
	return result;
}

static NSString *getsuffix() {
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
		return @"-72";
	
	if ([[UIScreen mainScreen] scale] < 2.0f)
		return @"";
	
	return @"@2x";
	
}

%subclass WIIcon : SBApplicationIcon

-(void)longPressTimerFired
{

	if (![[%c(SBIconController) sharedInstance] isEditing]) {
	
		_held = YES;
	
		[[%c(SBWiFiManager) sharedInstance] setWiFiEnabled:![[%c(SBWiFiManager) sharedInstance] wiFiEnabled]];
		
		[self updateIconLabel];
		
	} else {
		
		%orig;
		
	}
	
}

-(id)displayName
{		
	NSString *zString = nil;
	
	if ([[%c(SBWiFiManager) sharedInstance] wiFiEnabled]) {
		
		switch (_currentMode) {
				
				
			case 0:
				zString = [NSString stringWithFormat:@"| %@", [[%c(SBWiFiManager) sharedInstance] currentNetworkName] ? : @"None"];
				break;
			case 1:
				zString = [NSString stringWithFormat:@"| %@", GetIPAddress()];
				break;
			case 2:
				zString = [NSString stringWithFormat:@"| %i", [[%c(SBWiFiManager) sharedInstance] signalStrengthBars]];
				break;
			default:
				zString = @"ERR";
				break;
				
		}
		
		
	} else {
		
		zString = @"O";
		
	}
	
	return zString;
}

- (void)launch
{
	if (_held) {
		_held = NO;
		return;
	}
	
	_currentMode++;
	if (_currentMode == 2) _currentMode = 0;
		
		[self updateIconLabel];
	
}

%new(v@:)
- (void)updateIconLabel
{
	
	
	NSString *zString = nil;
	
	UIImage *zImage = nil;
	
	if ([[%c(SBWiFiManager) sharedInstance] wiFiEnabled]) {
		
		switch (_currentMode) {
				
				
			case 0:
				zString = [NSString stringWithFormat:@"| %@", [[%c(SBWiFiManager) sharedInstance] currentNetworkName] ? : @"None"];
				break;
			case 1:
				zString = [NSString stringWithFormat:@"| %@", GetIPAddress()? : @"None"];
				break;
			case 2:
				zString = [NSString stringWithFormat:@"| %i", [[%c(SBWiFiManager) sharedInstance] signalStrengthBars]];
				break;
			default:
				zString = @"ERR";
				break;
				
		}
		
		zImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/Applications/WIIcon.app/%i%@%@.png", [[%c(SBWiFiManager) sharedInstance] signalStrengthBars], @"_Bar", getsuffix()]];
		
	} else {
		
		zString = @"O";
		
		zImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/Applications/WIIcon.app/%@%@.png", @"Off", getsuffix()]];
		
	}
	
	
		//I'm on 5.0 for testing stuff so get over it, this isnt meant for 5.0 nor do i encourage it so bleh
	
	SBIconLabel *zLabel = nil;
	
	SBIconImageView *zImageView = nil;
	
	if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0f) {
		
		SBIconLabel *&label = (MSHookIvar<SBIconLabel *>(self, "_label"));
		zLabel = label;
		
		SBIconImageView *&imageView = (MSHookIvar<SBIconImageView *>(self, "_iconImageView"));
		zImageView = imageView;
		
	} else {
		
		SBIconLabel *&label = (MSHookIvar<SBIconLabel *>([[%c(SBIconViewMap) homescreenMap] mappedIconViewForIcon:self], "_label"));
		zLabel = label;
		
		SBIconImageView *&imageView = (MSHookIvar<SBIconImageView *>([[%c(SBIconViewMap) homescreenMap] mappedIconViewForIcon:self], "_iconImageView"));
		zImageView = imageView;
		
	}
	
	[zLabel setText:zString];
	
	zImageView.image = zImage;
	

	[NSObject cancelPreviousPerformRequestsWithTarget:self];

	if (self)
		[self performSelector:@selector(updateIconLabel) withObject:nil afterDelay:0.5f];
	
}

-(id)generateIconImage:(int)image
{
	if ([[%c(SBWiFiManager) sharedInstance] wiFiEnabled]) {
				
		return [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/Applications/WIIcon.app/%i%@%@.png", [[%c(SBWiFiManager) sharedInstance] signalStrengthBars], @"_Bar", getsuffix()]];
		
	} else {
				
		return [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/Applications/WIIcon.app/%@%@.png", @"Off", getsuffix()]];
		
	}

}
-(id)getStandardIconImageForLocation:(int)location
{
	return [self generateIconImage:location];
}

-(id)getIconImage:(int)image
{
	return [self generateIconImage:image];
}

-(id)getGenericIconImage:(int)image
{
	return [self generateIconImage:image];
}


%end

	//yawn nothing going on here.....
%hook SBIconView

-(void)longPressTimerFired
{		
	SBIcon *&zIcon = (MSHookIvar<SBIcon *>(self, "_icon"));
	
	
	if (![[%c(SBIconController) sharedInstance] isEditing] && [zIcon respondsToSelector:@selector(updateIconLabel)]) {
		
		_held = YES;
		
		[[%c(SBWiFiManager) sharedInstance] setWiFiEnabled:![[%c(SBWiFiManager) sharedInstance] wiFiEnabled]];

		[zIcon updateIconLabel];
		
	} else {
		
		%orig;
		
	}
	
	
}


%end

%hook SBAwayController

- (void)unlockWithSound:(BOOL)sound
{
	%orig;
	
	if ([[[[%c(SBIconController) sharedInstance] currentRootIconList] model] containsIcon:[[%c(SBIconModel) sharedInstance] leafIconForIdentifier:@"com.thezimm.WIIcon"]]) {
		
		[[[%c(SBIconModel) sharedInstance] leafIconForIdentifier:@"com.thezimm.WIIcon"] updateIconLabel];
		
	}

}

%end

%hook SBIconController

-(void)scrollViewDidScroll:(id)scrollView
{
	%orig;
	
	[NSObject cancelPreviousPerformRequestsWithTarget:[[%c(SBIconModel) sharedInstance] leafIconForIdentifier:@"com.thezimm.WIIcon"]];
	
}



-(void)scrollViewDidEndDecelerating:(id)scrollView
{
	%orig;
	
	if ([[[self currentRootIconList] model] containsIcon:[[%c(SBIconModel) sharedInstance] leafIconForIdentifier:@"com.thezimm.WIIcon"]]) {
		
		[[[%c(SBIconModel) sharedInstance] leafIconForIdentifier:@"com.thezimm.WIIcon"] updateIconLabel];
		
	}
	
}


%end

