//
//  SCAuthManager.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/16/21.
//

#import "SCAuthManager.h"
#import "AppAuth.h"
#import <UICKeyChainStore/UICKeyChainStore.h>
#import "AppDelegate.h"
#import "SCMainCoordinator.h"

typedef void (^PostRegistrationCallback)(OIDServiceConfiguration *configuration,
                                         OIDRegistrationResponse *registrationResponse);

static NSString *const kIssuer = @"https://accounts.spotify.com/authorize";
static NSString *const kTokenEndpoint = @"https://accounts.spotify.com/api/token";
static NSString *const kClientID = @"38c7c609489149489ca5736800605f90";
static NSString *const kRedirectURI = @"io.dangiesoft.SpotiCam:/oauth2redirect/spotify";
static NSString *const kAppAuthStateKey = @"authState";
static NSString *const kKeyChainService = @"com.spotify.accounts";

@interface SCAuthManager () <OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate>
@end

@implementation SCAuthManager


- (void)saveState {
    NSError *error = nil;
    NSData *archivedAuthState = [NSKeyedArchiver archivedDataWithRootObject:self.authState
                                                      requiringSecureCoding:NO
                                                                      error:&error];
    if (error != nil) {
        NSLog(@"%@", [error localizedDescription]);
        return;
    }
    
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:kKeyChainService];
    [keychain setData:archivedAuthState forKey:kAppAuthStateKey];
}

- (void)loadState {
    // Loads from OIDAuthState from Keychain
    NSError *error = nil;
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:kKeyChainService];
    NSData *archivedAuthState = [keychain dataForKey:kAppAuthStateKey];
    OIDAuthState *authState = [NSKeyedUnarchiver unarchivedObjectOfClass:[OIDAuthState class]
                                                                fromData:archivedAuthState
                                                                   error:&error];
    if (error != nil) {
        NSLog(@"%@", [error localizedDescription]);
        return;
    }
    [self setAuthState:authState];
}


- (void)setAuthState:(OIDAuthState * _Nullable)authState {
    if (self.authState == authState) {
        return;
    }
    _authState = authState;
    _authState.stateChangeDelegate = self;
    [self stateChanged];
}

- (void)stateChanged {
    [self saveState];
    
}


- (void)didChangeState:(nonnull OIDAuthState *)state {
    [self saveState];
}


- (void)authState:(nonnull OIDAuthState *)state didEncounterAuthorizationError:(nonnull NSError *)error {
    NSLog(@"%@", [error localizedDescription]);
}


- (void)doAuthWithAutoCodeExchange {
    NSURL *issuer = [NSURL URLWithString:kIssuer];
    NSURL *tokenEndpoint = [NSURL URLWithString:kTokenEndpoint];
    NSURL *redirectURI = [NSURL URLWithString:kRedirectURI];
    
    OIDServiceConfiguration *configuration =
    [[OIDServiceConfiguration alloc] initWithAuthorizationEndpoint:issuer tokenEndpoint:tokenEndpoint];
    
    OIDAuthorizationRequest *request =
    [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                  clientId:kClientID
                                                    scopes:@[@"playlist-modify-public"]
                                               redirectURL:redirectURI
                                              responseType:OIDResponseTypeCode
                                      additionalParameters:nil];
    
    // Perform auth request with AppDelegate's currentAuthorizationFlow session
    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    appDelegate.currentAuthorizationFlow =
    [OIDAuthState authStateByPresentingAuthorizationRequest:request
                                   presentingViewController:self.viewController
                                                   callback:^(OIDAuthState * _Nullable authState, NSError * _Nullable error) {
        if (authState) {
            NSLog(@"Got authorization tokens. Access token: %@", authState.lastTokenResponse.accessToken);
            // Flag set to yes once user auths for the first time in v1.1
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasUserAuthorizedPlaylistScope"];
            [self setAuthState:authState];
            [self.coordinator proceedAfterAuth];
        } else {
            NSLog(@"Authorization error: %@", [error localizedDescription]);
            [self setAuthState:nil];
        }
    }];
}

@end
