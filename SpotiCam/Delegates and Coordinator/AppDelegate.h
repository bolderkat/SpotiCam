//
//  AppDelegate.h
//  SpotiCam
//
//  Created by Daniel Luo on 2/9/21.
//

#import <UIKit/UIKit.h>
@protocol OIDExternalUserAgentSession;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property(nonatomic, strong, nullable) id<OIDExternalUserAgentSession> currentAuthorizationFlow;

@end

