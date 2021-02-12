//
//  SCAPIManager.m
//  SpotiCam
//
//  Created by Daniel Luo on 2/12/21.
//

#import "SCAPIManager.h"

@interface SCAPIManager ()

@end

@implementation SCAPIManager

- (instancetype)initWithColor:(UIColor *)color {
    CGFloat h, s, b, a;
    [color getHue:&h saturation:&s brightness:&b alpha:&a];
    self.danceability = [self calculateDanceabilityWithHue:h saturation:s brightness:b];
    self.energy = [self calculateEnergyWithHue:h saturation:s brightness:b];
    self.valence = [self calculateValenceWithHue:h saturation:s brightness:b];
    return self;
}


#pragma mark- Track attribute calculations

- (CGFloat)calculateDanceabilityWithHue:(CGFloat)h saturation:(CGFloat)s brightness:(CGFloat)b {
    CGFloat hFactor = [self applySlightMidDipCurveToHue:h];
    CGFloat sFactor = [self applyModerateSlopeToSaturation:s];
    CGFloat bFactor = [self applyBrightnessCurveToBrightness:b];
    
    CGFloat danceability = hFactor * sFactor * bFactor;
    if (danceability < 0.0) {
        danceability = 0.0;
    } else if (danceability > 1.0) {
        danceability = 1.0;
    }
    
    return danceability;
}

- (CGFloat)calculateEnergyWithHue:(CGFloat)h saturation:(CGFloat)s brightness:(CGFloat)b {
    CGFloat hFactor = [self applySlightMidDipCurveToHue:h];
    CGFloat sFactor = [self applyMildSlopeToSaturation:s];
    CGFloat bFactor = [self applyBrightnessCurveToBrightness:b];
    
    CGFloat energy = hFactor * sFactor * bFactor;
    if (energy < 0.0) {
        energy = 0.0;
    } else if (energy > 1.0) {
        energy = 1.0;
    }
    
    return energy;
}

- (CGFloat) calculateValenceWithHue:(CGFloat)h saturation:(CGFloat)s brightness:(CGFloat)b {
    CGFloat hFactor = [self applyValenceCurveToHue:h];
    CGFloat sFactor = [self applyMildSlopeToSaturation:s];
    CGFloat bFactor = [self applyBrightnessCurveToBrightness:b];
    
    CGFloat valence = hFactor * sFactor * bFactor;
    if (valence < 0.0) {
        valence = 0.0;
    } else if (valence > 1.0) {
        valence = 1.0;
    }
    
    return valence;
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
    return -0.8184 * pow(x, 3) + 1.7978 * pow(x, 2) + 0.0301 * x - 0.0023;
}

- (CGFloat)applyValenceCurveToHue:(CGFloat)x {
    // Curve to interpret mood of specific hue values
    return -68.451 * pow(x, 6) + 214.59 * pow(x, 5) - 269.55 * pow(x, 4) + 178.62 * pow(x, 3) - 65.336 * pow(x, 2) + 9.9679 * x + 0.4945;
}

- (CGFloat)applyMildSlopeToSaturation:(CGFloat)x {
    return 0.25 * x + 0.75;
}

- (CGFloat)applyModerateSlopeToSaturation:(CGFloat)x {
    return 0.5 * x + 0.5;
}


@end
