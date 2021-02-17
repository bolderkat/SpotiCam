//
//  SCAuthManager.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/16/21.
//

#import "SCAuthManager.h"
#import "AppAuth.h"
#import "AppDelegate.h"

typedef void (^PostRegistrationCallback)(OIDServiceConfiguration *configuration,
                                         OIDRegistrationResponse *registrationResponse);

static NSString *const kIssuer = @"https://accounts.spotify.com/authorize";
static NSString *const kClientID = @"38c7c609489149489ca5736800605f90";
static NSString *const kRedirectURI = @"io.dangiesoft.SpotiCam:/oauth2redirect/spotify";
static NSString *const kAppAuthStateKey = @"authState";

@interface SCAuthManager () <OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate>
@end

@implementation SCAuthManager


- (void)saveState {
    // TODO: persist with keychain instead
    NSError *error = nil;
    NSData *archivedAuthState = [NSKeyedArchiver archivedDataWithRootObject:self.authState requiringSecureCoding:NO error:&error];
    if (error != nil) {
        NSLog(@"%@", [error localizedDescription]);
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:archivedAuthState forKey:kAppAuthStateKey];
}

- (void)loadState {
    // Loads from OIDAuthState from NSUserDefaults
    NSError *error = nil;
    NSData *archivedAuthState = [[NSUserDefaults standardUserDefaults] objectForKey:kAppAuthStateKey];
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
}


- (void)didChangeState:(nonnull OIDAuthState *)state {
    [self saveState];
}


- (void)authState:(nonnull OIDAuthState *)state didEncounterAuthorizationError:(nonnull NSError *)error {
    NSLog(@"%@", [error localizedDescription]);
}


- (void)doAuthWithAutoCodeExchange:(OIDServiceConfiguration *)configuration {
    NSURL *redirectURI = [NSURL URLWithString:kRedirectURI];
    
    OIDAuthorizationRequest *request =
    [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                  clientId:kClientID
                                                    scopes:nil
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
            [self setAuthState:authState];
        } else {
            NSLog(@"Authorizationerror: %@", [error localizedDescription]);
            [self setAuthState:nil];
        }
    }];
}

@end
