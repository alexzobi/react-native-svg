/*
 * Copyright (C) 2005 Apple Computer, Inc.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE COMPUTER, INC. ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE COMPUTER, INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
#import "WKArithmeticFilter.h"

static CIKernel *arithmeticFilter = nil;

@implementation WKArithmeticFilter
+ (void)initialize
{
    id<CIFilterConstructor> anObject = (id<CIFilterConstructor>)self;
    [CIFilter registerFilterName:@"WKArithmeticFilter"
                     constructor:anObject
                 classAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                  @"WebKit Arithmetic Filter", kCIAttributeFilterDisplayName,
                                  [NSArray arrayWithObjects:kCICategoryStylize, kCICategoryVideo,
                                   kCICategoryStillImage, kCICategoryNonSquarePixels,nil], kCIAttributeFilterCategories,
                                  [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithDouble:0.0], kCIAttributeMin,
                                   [NSNumber numberWithDouble:0.0], kCIAttributeDefault,
                                   [NSNumber numberWithDouble:1.0], kCIAttributeIdentity,
                                   kCIAttributeTypeScalar, kCIAttributeType,
                                   nil], @"inputK1",
                                  [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithDouble:0.0], kCIAttributeMin,
                                   [NSNumber numberWithDouble:0.0], kCIAttributeDefault,
                                   [NSNumber numberWithDouble:1.0], kCIAttributeIdentity,
                                   kCIAttributeTypeScalar, kCIAttributeType,
                                   nil], @"inputK2",
                                  [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithDouble:0.0], kCIAttributeMin,
                                   [NSNumber numberWithDouble:0.0], kCIAttributeDefault,
                                   [NSNumber numberWithDouble:1.0], kCIAttributeIdentity,
                                   kCIAttributeTypeScalar, kCIAttributeType,
                                   nil], @"inputK3",
                                  [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithDouble:0.0], kCIAttributeMin,
                                   [NSNumber numberWithDouble:0.0], kCIAttributeDefault,
                                   [NSNumber numberWithDouble:1.0], kCIAttributeIdentity,
                                   kCIAttributeTypeScalar, kCIAttributeType,
                                   nil], @"inputK4",
                                  nil]];
}

+ (CIFilter *)filterWithName:(NSString *)name
{
    return [[self alloc] init];
}

- (id)init
{
    if (!arithmeticFilter) {
        NSString *code =
@"kernel vec4 arithmeticComposite(sampler in1, sampler in2, float k1, float k2, float k3, float k4)\
{\
    vec4 vin1 = sample(in1, samplerCoord(in1));\
    vec4 vin2 = sample(in2, samplerCoord(in2));\
    vec4 res = k1*vin1*vin2 + k2*vin1 + k3*vin2 + vec4(k4);\
    return res;\
}";
        arithmeticFilter = [CIKernel kernelWithString:code];
    }
    return [super init];
}

- (CIImage *)outputImage
{
    CIImage *result = inputImage;
    CIKernelROICallback callback = ^CGRect(int index, CGRect rect) {
        return CGRectMake(0, 0, CGRectGetWidth(result.extent), CGRectGetHeight(result.extent));
    };
    return [arithmeticFilter applyWithExtent:result.extent roiCallback:callback arguments:@[inputImage, inputBackgroundImage, inputK1, inputK2, inputK3, inputK4]];
}

@end
