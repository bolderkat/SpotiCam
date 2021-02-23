//
//  SCTrack.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/22/21.
//

#import "SCTrack.h"

@implementation SCTrack

- (instancetype)initWithJSON:(NSDictionary *)dict {
    self.uri = dict[@"uri"];
    self.trackTitle = dict[@"name"];
    self.albumTitle = dict[@"album"][@"name"];
    self.albumArtURLs = dict[@"album"][@"images"];
    self.artists = dict[@"artists"];
    self.duration = dict[@"duration_ms"];
    
    return self;
}
@end
