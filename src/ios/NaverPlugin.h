#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import <NaverThirdPartyLogin/NaverThirdPartyLogin.h>
#import <NaverThirdPartyLogin/NaverThirdPartyLoginConnection.h>

@interface NaverPlugin : CDVPlugin <NaverThirdPartyLoginConnectionDelegate> {
}

- (void)login:(CDVInvokedUrlCommand *)command;

- (void)logout:(CDVInvokedUrlCommand *)command;

- (void)logoutAndDeleteToken:(CDVInvokedUrlCommand *)command;

- (void)refreshAccessToken:(CDVInvokedUrlCommand *)command;

- (void)getState:(CDVInvokedUrlCommand *)command;

- (void)requestApi:(CDVInvokedUrlCommand *)command;

- (void)requestMe:(CDVInvokedUrlCommand *)command;

@end
