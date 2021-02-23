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
    
    NSMutableArray<NSString*> *artists = [NSMutableArray array];
    for (NSDictionary *artist in dict[@"artists"]) {
        [artists addObject:artist[@"name"]];
    }
    self.artists = [NSArray arrayWithArray:artists];
    self.duration = dict[@"duration_ms"];
    
    return self;
}
@end
