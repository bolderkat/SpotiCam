//
//  SceneDelegate.h
//  SpotiCam
//
//  Created by Daniel Luo on 2/9/21.
//

#import <UIKit/UIKit.h>
#import "SCMainCoordinator.h"

@interface SceneDelegate : UIResponder <UIWindowSceneDelegate>

@property (strong, nonatomic) UIWindow * window;
@property (nonatomic) SCMainCoordinator *coordinator;

@end

