#import "NaverPlugin.h"
#import <objc/runtime.h>

@interface NaverPlugin ()

@property(strong, nonatomic) NSString *loginCallbackId;
@end

@implementation NaverPlugin

- (void)pluginInitialize {
    NSLog(@"Start Naver plugin");

    // Delegate 설정
    [NaverThirdPartyLoginConnection getSharedInstance].delegate = self;

    // 네이버 앱과, 인앱 브라우저 인증을 둘다 사용하도록 설정
    [[NaverThirdPartyLoginConnection getSharedInstance] setIsNaverAppOauthEnable:YES];
    [[NaverThirdPartyLoginConnection getSharedInstance] setIsInAppOauthEnable:YES];

    // 세로 화면 고정 설정
    [[NaverThirdPartyLoginConnection getSharedInstance] setOnlyPortraitSupportInIphone:YES];

    // 네이버 플러그인 데이터 설정
    NSString *serviceUrlScheme = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NaverAppScheme"];
    NSString *consumerKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NaverClientID"];
    NSString *consumerSecret = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NaverClientSecret"];
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NaverClientName"];

    [[NaverThirdPartyLoginConnection getSharedInstance] setServiceUrlScheme:serviceUrlScheme];
    [[NaverThirdPartyLoginConnection getSharedInstance] setConsumerKey:consumerKey];
    [[NaverThirdPartyLoginConnection getSharedInstance] setConsumerSecret:consumerSecret];
    [[NaverThirdPartyLoginConnection getSharedInstance] setAppName:appName];
}


#pragma mark - Cordova commands

/**
 * 네이버 로그인을 요청합니다
 *
 * @param command
 */
- (void)login:(CDVInvokedUrlCommand *)command {

    // 로그인 콜백 아이디 설정
    self.loginCallbackId = command.callbackId;

    // 로그인 요청
    NaverThirdPartyLoginConnection *login = [NaverThirdPartyLoginConnection getSharedInstance];
    [login requestThirdPartyLogin];
}

/**
 * 토큰을 지워 로그아웃 처리 합니다.
 *
 * @param command
 */
- (void)logout:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
    [[NaverThirdPartyLoginConnection getSharedInstance] resetToken];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * 토큰을 지우고, 계정 연동을 해제합니다.
 *
 * @param command
 */
- (void)logoutAndDeleteToken:(CDVInvokedUrlCommand *)command {
    // 콜백 아이디 설정
    self.loginCallbackId = command.callbackId;

    // 로그아웃 요청
    NaverThirdPartyLoginConnection *loginConnection = [NaverThirdPartyLoginConnection getSharedInstance];
    [loginConnection requestDeleteToken];
}

/**
 * 클라이언트에 저장된 갱신 토큰(refresh token)을 이용해 접근 토큰(access token)을 갱신하고 갱신된 접근 토큰을 반환합니다.
 *
 * @param command
 */
- (void)refreshAccessToken:(CDVInvokedUrlCommand *)command {
    // 콜백 아이디 설정
    self.loginCallbackId = command.callbackId;

    // AccessToken 재 발급 요청
    NaverThirdPartyLoginConnection *loginConnection = [NaverThirdPartyLoginConnection getSharedInstance];
    [loginConnection requestAccessTokenWithRefreshToken];
}

/**
 * 네이버 아이디로 로그인 인스턴스의 현재 상태를 반환합니다.
 *
 * @param command
 */
- (void)getState:(CDVInvokedUrlCommand *)command {
    // TODO 구현 필요, 안드로이드 라이브러리에는 있으나 아이폰 라이브러리에는 존재하지 않는 메소드
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"구현되지 않았습니다"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * GET 메서드로 API를 호출합니다. 성공하면 결과(content body)를 반환합니다.
 *
 * @param command
 */
- (void)requestApi:(CDVInvokedUrlCommand *)command {
    // TODO 구현 필요, 안드로이드 라이브러리에는 있으나 아이폰 라이브러리에는 존재하지 않는 메소드
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"구현되지 않았습니다"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * 네이버 로그인을 통해 인증받은 받고 정보 제공에 동의한 회원에 대해 회원 메일 주소, 별명, 프로필 사진, 생일, 연령대 값을 조회할 수 있는 로그인 오픈 API입니다.
 * API 호출 결과로 네이버 아이디값은 제공하지 않으며, 대신 'id'라는 애플리케이션당 유니크한 일련번호값을 이용해서 자체적으로 회원정보를 구성하셔야 합니다.
 * 기존 REST API처럼 요청 URL과 요청 변수로 호출하는 방법은 동일하나, OAuth 2.0 인증 기반이므로 추가적으로 네이버 로그인 API를 통해 접근 토큰(access token)을 발급받아,
 * HTTP로 호출할 때 Header에 접근 토큰 값을 전송해 주시면 활용 가능합니다.
 * @param command
 */
- (void)requestMe:(CDVInvokedUrlCommand *)command {
    NSString *accessToken = [[NaverThirdPartyLoginConnection getSharedInstance] accessToken];

    NSString *urlString = @"https://openapi.naver.com/v1/nid/me"; // 사용자 프로필 호출 API URL
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSString *authValue = [NSString stringWithFormat:@"Bearer %@", accessToken];
    NSString *contentType = @"text/json;charset=utf-8";
    [urlRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
    [urlRequest setValue:contentType forHTTPHeaderField:@"Content-Type"];

    [[[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *serializationError;
        NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&serializationError];

        // camelCase 형태로 변경
        [self buildRequestMeJsonObject:json];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:json];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }] resume];
}


#pragma mark - Utility methods

- (void)exchangeKey:(NSString *)aKey withKey:(NSString *)aNewKey inMutableDictionary:(NSMutableDictionary *)aDict {
    if (![aKey isEqualToString:aNewKey]) {
        id objectToPreserve = aDict[aKey];
        aDict[aNewKey] = objectToPreserve;
        [aDict removeObjectForKey:aKey];
    }
}

- (void)buildRequestMeJsonObject:(NSMutableDictionary *)dictionary {
    NSMutableDictionary *responseDict = dictionary[@"response"];
    [self exchangeKey:@"enc_id" withKey:@"encryptionId" inMutableDictionary:responseDict];
    [self exchangeKey:@"profile_image" withKey:@"profileImage" inMutableDictionary:responseDict];

    dictionary[@"response"] = responseDict;
    [self exchangeKey:@"resultcode" withKey:@"resultCode" inMutableDictionary:dictionary];
}


#pragma mark - NaverThirdPartyLoginConnectionDelegate

- (void)oauth20ConnectionDidFinishRequestACTokenWithAuthCode {
    NSLog(@"oauth20ConnectionDidFinishRequestACTokenWithAuthCode");
    NSString *accessToken = [[NaverThirdPartyLoginConnection getSharedInstance] accessToken];
    NSString *refreshToken = [[NaverThirdPartyLoginConnection getSharedInstance] refreshToken];
    NSDate *expiresAt = [[NaverThirdPartyLoginConnection getSharedInstance] accessTokenExpireDate];
    NSString *tokenType = [[NaverThirdPartyLoginConnection getSharedInstance] tokenType];

    NSDictionary *result = @{
                             @"accessToken" : accessToken,
                             @"refreshToken" : refreshToken,
                             @"expiresAt" : [NSString stringWithFormat:@"%f", [expiresAt timeIntervalSince1970]],
                             @"tokenType" : tokenType
                             };

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary: result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.loginCallbackId];

    self.loginCallbackId = nil;
}

- (void)oauth20ConnectionDidFinishRequestACTokenWithRefreshToken {
    NSLog(@"oauth20ConnectionDidFinishRequestACTokenWithRefreshToken");
    NSString *accessToken = [[NaverThirdPartyLoginConnection getSharedInstance] accessToken];
    NSString *refreshToken = [[NaverThirdPartyLoginConnection getSharedInstance] refreshToken];
    NSDate *expiresAt = [[NaverThirdPartyLoginConnection getSharedInstance] accessTokenExpireDate];
    NSString *tokenType = [[NaverThirdPartyLoginConnection getSharedInstance] tokenType];

    NSDictionary *result = @{
                             @"accessToken" : accessToken,
                             @"refreshToken" : refreshToken,
                             @"expiresAt" : [NSString stringWithFormat:@"%f", [expiresAt timeIntervalSince1970]],
                             @"tokenType" : tokenType
                             };

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary: result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.loginCallbackId];

    self.loginCallbackId = nil;
}

- (void)oauth20ConnectionDidFinishDeleteToken {
    NSLog(@"oauth20ConnectionDidFinishDeleteToken");
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.loginCallbackId];

    self.loginCallbackId = nil;
}

- (void)oauth20Connection:(NaverThirdPartyLoginConnection *)oauthConnection didFailWithError:(NSError *)error {
    NSLog(@"oauth20Connection");
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.description];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.loginCallbackId];

    self.loginCallbackId = nil;
}

- (void)oauth20Connection:(NaverThirdPartyLoginConnection *)oauthConnection didFailAuthorizationWithRecieveType:(THIRDPARTYLOGIN_RECEIVE_TYPE)receiveType
{
    NSLog(@"NaverApp login fail handler");
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"%u", (THIRDPARTYLOGIN_RECEIVE_TYPE)receiveType]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.loginCallbackId];

    self.loginCallbackId = nil;
}

- (void)oauth20Connection:(NaverThirdPartyLoginConnection *)oauthConnection didFinishAuthorizationWithResult:(THIRDPARTYLOGIN_RECEIVE_TYPE)receiveType
{
    NSLog(@"Getting auth code from NaverApp success!");
}

@end