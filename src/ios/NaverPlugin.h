#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>
#import <NaverThirdPartyLogin/NaverThirdPartyLogin.h>
#import "AppDelegate.h"

@interface NaverPlugin : CDVPlugin

- (void)login:(CDVInvokedUrlCommand *)command;

- (void)logout:(CDVInvokedUrlCommand *)command;

- (void)logoutAndDeleteToken:(CDVInvokedUrlCommand *)command;

- (void)refreshAccessToken:(CDVInvokedUrlCommand *)command;

@end
