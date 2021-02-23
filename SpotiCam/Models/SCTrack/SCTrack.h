//
//  SCTrack.h
//  SpotiCam
//
//  Created by Daniel Luo on 2/22/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCTrack : NSObject
@property (nonatomic) NSString *uri;
@property (nonatomic) NSString *trackTitle;
@property (nonatomic) NSString *albumTitle;
@property (nonatomic) NSArray<NSDictionary*> *albumArtURLs; // 3 URLs at key "url": 640x640, 300x300, 64x64
@property (nonatomic) NSArray<NSDictionary*> *artists; // Dictionary keys: name, uri, id, external_urls, href, type
@property (nonatomic) NSNumber *duration; // milliseconds

- (instancetype)initWithJSON:(NSDictionary*)dict;

@end

NS_ASSUME_NONNULL_END
