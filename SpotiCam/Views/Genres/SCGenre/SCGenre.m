//
//  SCGenre.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/17/21.
//

#import "SCGenre.h"

@implementation SCGenre

- (instancetype)initWithName:(NSString*)name isChecked:(BOOL)isChecked {
    if (self = [super init]) {
        self.name = name;
        self.isChecked = isChecked;
    }
    return self;
}

@end
