//
//  SCAPIManager.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/12/21.
//

#import "SCAPIManager.h"
#import <OIDAuthState.h>



@interface SCAPIManager ()
@property (weak, nonatomic) SCMainCoordinator *coordinator;
@property (nonatomic) void (^playlistCompletionHandler)(NSString* _Nullable, NSDictionary* _Nullable);

@end

@implementation SCAPIManager

+ (void)fetchGenreSeedsWithToken:(NSString*)token completion:(void (^)(NSArray<NSString*>*, NSDictionary* _Nullable))completion {
    NSString *urlString = @"https://api.spotify.com/v1/recommendations/available-genre-seeds";
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *authValue = [NSString stringWithFormat:@"Bearer %@", token];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.HTTPAdditionalHeaders = @{@"Authorization": authValue};
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    [[session dataTaskWithURL:url
                               completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error fetching genre seeds from Spotify API: %@", [error localizedDescription]);
            return;
        }
        
        NSError *err;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        if (err) {
            NSLog(@"Failed to serialize JSON: %@", [err localizedDescription]);
            return;
        }
        
        NSArray *genreSeeds = dict[@"genres"];
        NSDictionary *apiError = dict[@"error"];
        completion(genreSeeds, apiError);
    }] resume];
}

- (instancetype)initWithColor:(UIColor *)color coordinator:(SCMainCoordinator*)coordinator {
    CGFloat h, s, b, a;
    [color getHue:&h saturation:&s brightness:&b alpha:&a];
    self.danceability = [self calculateDanceabilityWithHue:h saturation:s brightness:b];
    self.energy = [self calculateEnergyWithHue:h saturation:s brightness:b];
    self.valence = [self calculateValenceWithHue:h saturation:s brightness:b];
    self.coordinator = coordinator;
    return self;
}

- (void)fetchTrackRecommendationsWithCompletion:(void (^)(NSArray<SCTrack*>*, NSDictionary* _Nullable))completion {
    [self.coordinator.authManager.authState performActionWithFreshTokens:^(NSString * _Nullable accessToken, NSString * _Nullable idToken, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error fetching fresh tokens for track recommendations: %@", [error localizedDescription]);
        }
        // Build API Query
        NSInteger trackLimit = 20;
        NSArray *genres = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedGenres"];
        long popularity = [[NSUserDefaults standardUserDefaults] integerForKey:@"popularity"] ?: 0;
        NSMutableArray *lowercaseGenres = [NSMutableArray array];
        for (NSString *genre in genres) {
            [lowercaseGenres addObject:[genre lowercaseString]];
        }
        NSString *genreString = [lowercaseGenres componentsJoinedByString:@"%2C"];
        NSString *urlString = [NSString stringWithFormat:@"https://api.spotify.com/v1/recommendations?limit=%ld&seed_genres=%@&target_danceability=%.2f&target_energy=%.2f&min_popularity=%ld&target_valence=%.2f", trackLimit, genreString, self.danceability, self.energy, popularity, self.valence];
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLSession *session = [self setUpURLSessionWithAccessToken:accessToken];
        
        [[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error fetching track recommendations: %@", [error localizedDescription]);
                return;
            }
            
            NSError *err;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
            if (err) {
                NSLog(@"Failed to serialize track recommendation JSON: %@", [err localizedDescription]);
                return;
            }
            NSArray<SCTrack*> *tracks = [self parseTracksFromJSON:dict];
            NSDictionary *apiError = dict[@"error"];
            completion(tracks, apiError);
        }] resume];
    }];
}

- (NSArray<SCTrack*>*)parseTracksFromJSON:(NSDictionary*)dict {
    NSArray *trackData = dict[@"tracks"];
    NSMutableArray *parsedTracks = [NSMutableArray array];
    
    for (NSDictionary *track in trackData) {
        [parsedTracks addObject:[[SCTrack alloc] initWithJSON:track]];
    }
    return [NSArray arrayWithArray:parsedTracks];
}


#pragma mark:- Playlist creation methods

- (void)createPlaylistWithTracks:(NSArray<SCTrack*>*)tracks playlistData:(NSDictionary*)playlistData completionHandler:(void (^)(NSString* _Nullable, NSDictionary* _Nullable))completion {
    self.playlistCompletionHandler = completion;
    [self getSpotifyUserIDWithPlaylistData:playlistData tracks:tracks];
}

- (void)getSpotifyUserIDWithPlaylistData:(NSDictionary*)playlistData tracks:(NSArray<SCTrack*>*)tracks {
    // First need to retrieve user's Spotify user ID before we can create a playlist on their behalf.
    [self.coordinator.authManager.authState performActionWithFreshTokens:^(NSString * _Nullable accessToken, NSString * _Nullable idToken, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error fetching fresh tokens to retrieve user ID: %@", [error localizedDescription]);
        }
        NSString *urlString = @"https://api.spotify.com/v1/me";
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLSession *session = [self setUpURLSessionWithAccessToken:accessToken];
        
        [[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error fetching user profile for ID: %@", [error localizedDescription]);
                return;
            }
            
            NSError *err;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
            if (err) {
                NSLog(@"Failed to serialize user profile JSON: %@", [err localizedDescription]);
                return;
            }
            if (dict[@"error"]) {
                self.playlistCompletionHandler(nil, dict[@"error"]);
            } else {
                NSString *uid = dict[@"id"];
                [self createNewPlaylistForUserID:uid
                                    playlistData:playlistData
                                          tracks:tracks
                                     accessToken:accessToken];
            }
        }] resume];
        
    }];
}

- (void)createNewPlaylistForUserID:(NSString*)uid playlistData:(NSDictionary*)playlistData tracks:(NSArray<SCTrack*>*)tracks accessToken:(NSString*)accessToken {
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:playlistData
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    NSString *urlString = [NSString stringWithFormat:@"https://api.spotify.com/v1/users/%@/playlists", uid];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSURLSession *session = [self setUpURLSessionWithAccessToken:accessToken];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error creating new playlist: %@", [error localizedDescription]);
            return;
        }
        
        NSError *err;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        if (err) {
            NSLog(@"Failed to serialize new playlist JSON: %@", [err localizedDescription]);
            return;
        }
        if (dict[@"error"]) {
            self.playlistCompletionHandler(nil, dict[@"error"]);
        } else {
            [self addTracksToPlaylist:dict
                               tracks:tracks
                          accessToken:accessToken];
        }
        
    }] resume];
}

- (void)addTracksToPlaylist:(NSDictionary*)receivedPlaylistInfo tracks:(NSArray<SCTrack*>*)tracks accessToken:(NSString*)accessToken {
    NSMutableArray<NSString*> *trackIDs = [NSMutableArray array];
    
    for (SCTrack *track in tracks) {
        NSString *uriString = [NSString stringWithFormat:@"%@", track.uri];
        [trackIDs addObject:uriString];
    }
    
    NSString *trackRequestString = [trackIDs componentsJoinedByString:@","];
    NSString *urlString = [NSString stringWithFormat:@"https://api.spotify.com/v1/playlists/%@/tracks?uris=%@", receivedPlaylistInfo[@"id"], trackRequestString];
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSURLSession *session = [self setUpURLSessionWithAccessToken:accessToken];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error adding tracks to playlist: %@", [error localizedDescription]);
            return;
        }
        
        NSError *err;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        if (err) {
            NSLog(@"Failed to serialize playlist JSON after adding tracks: %@", [err localizedDescription]);
            return;
        }
        
        self.playlistCompletionHandler(receivedPlaylistInfo[@"external_urls"][@"spotify"], dict[@"error"]);
    }] resume];
}

- (NSURLSession*)setUpURLSessionWithAccessToken:(NSString*)accessToken {
    NSString *authValue = [NSString stringWithFormat:@"Bearer %@", accessToken];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.HTTPAdditionalHeaders = @{@"Authorization": authValue};
    
    return [NSURLSession sessionWithConfiguration:sessionConfig];
}


#pragma mark- Track attribute calculations

- (CGFloat)calculateDanceabilityWithHue:(CGFloat)h saturation:(CGFloat)s brightness:(CGFloat)b {
    CGFloat hFactor = [self applySlightMidDipCurveToHue:h];
    CGFloat sFactor = [self applyModerateSlopeToSaturation:s];
    CGFloat bFactor = [self applyBrightnessCurveToBrightness:b];
    
    CGFloat danceability = hFactor * sFactor * bFactor;
    return [self constrainValueBetweenZeroAndOne:danceability];
}

- (CGFloat)calculateEnergyWithHue:(CGFloat)h saturation:(CGFloat)s brightness:(CGFloat)b {
    CGFloat hFactor = [self applySlightMidDipCurveToHue:h];
    CGFloat sFactor = [self applyMildSlopeToSaturation:s];
    CGFloat bFactor = [self applyBrightnessCurveToBrightness:b];
    
    CGFloat energy = hFactor * sFactor * bFactor;
    return [self constrainValueBetweenZeroAndOne:energy];
}

- (CGFloat) calculateValenceWithHue:(CGFloat)h saturation:(CGFloat)s brightness:(CGFloat)b {
    CGFloat hFactor = [self applyValenceCurveToHue:h];
    CGFloat sFactor = [self applyMildSlopeToSaturation:s];
    CGFloat bFactor = [self applyBrightnessCurveToBrightness:b];
    
    CGFloat valence = hFactor * sFactor * bFactor;
    return [self constrainValueBetweenZeroAndOne:valence];
}

- (CGFloat)constrainValueBetweenZeroAndOne:(CGFloat)x {
    if (x < 0.0) {
        x = 0.0;
    } else if (x > 1.0) {
        x = 1.0;
    }
    
    return x;
}


#pragma mark - Curve equations
- (CGFloat)applySlightMidDipCurveToHue:(CGFloat)x {
    // Curve that slightly decreases output value as x travels through mid-range of values between 0.0 and 1.0
    return -4.1667 * pow(x, 4) + 8.3333 * pow(x, 3) - 4.2083 * pow(x, 2) + 0.0417 * x + 1;
}

- (CGFloat)applyModerateMidDipCurveToHue:(CGFloat)x {
    // Steeper version of above curve
    return -3.8889 * pow(x, 4) + 7.7778 * pow(x, 3) - 3.2611 * pow(x, 2) - 0.6278 * x + 1;
}

- (CGFloat)applyBrightnessCurveToBrightness:(CGFloat)x {
    // Starts low and increases with input value
    return 3.2124 * pow(x, 4) - 9.2086 * pow(x, 3) + 7.7728 * pow(x, 2) - 0.7952 * x + 0.0053;
}

- (CGFloat)applyValenceCurveToHue:(CGFloat)x {
    // Curve to interpret mood of specific hue values
    return -68.451 * pow(x, 6) + 214.59 * pow(x, 5) - 269.55 * pow(x, 4) + 178.62 * pow(x, 3) - 65.336 * pow(x, 2) + 9.9679 * x + 0.4945;
}

- (CGFloat)applyMildSlopeToSaturation:(CGFloat)x {
    return 0.25 * x + 0.75;
}

- (CGFloat)applyModerateSlopeToSaturation:(CGFloat)x {
    return 0.75 * x + 0.25;
}


@end
