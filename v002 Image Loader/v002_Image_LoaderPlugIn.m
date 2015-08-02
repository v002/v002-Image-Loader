//
//  v002_Image_LoaderPlugIn.m
//  v002 Image Loader
//
//  Created by vade on 8/1/15.
//  Copyright (c) 2015 v002. All rights reserved.
//

// It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering
#import <OpenGL/CGLMacro.h>

#import "v002_Image_LoaderPlugIn.h"

#define	kQCPlugIn_Name				@"v002 Image Loader"
#define	kQCPlugIn_Description		@"v002 Image Loader description"

void MyQCPlugInBufferReleaseCallback(const void* address, void * context)
{
    CGImageRef image = (CGImageRef) context;
    CGImageRelease(image);
}

@implementation v002_Image_LoaderPlugIn


@synthesize loadedImage;

@dynamic inputImagePath;
@dynamic inputColorCorrect;
@dynamic outputImage;

+ (NSDictionary *)attributes
{
    return @{QCPlugInAttributeNameKey:kQCPlugIn_Name, QCPlugInAttributeDescriptionKey:kQCPlugIn_Description};
}

+ (NSDictionary *)attributesForPropertyPortWithKey:(NSString *)key
{

    if([key isEqualToString:@"inputImagePath"])
    {
        return @{QCPortAttributeNameKey : @"Image Location"};
    }
    
    if([key isEqualToString:@"inputColorCorrect"])
    {
        return @{QCPortAttributeNameKey : @"Color Correction",
                 QCPortAttributeDefaultValueKey : @YES};
    }
    
    if([key isEqualToString:@"outputImage"])
    {
        return @{QCPortAttributeNameKey : @"Image"};
    }

	return nil;
}

+ (NSArray*) sortedPropertyPortKeys
{
    return @[@"inputImagePath", @"inputColorCorrect", @"outputmage"];
}

+ (QCPlugInExecutionMode)executionMode
{
	return kQCPlugInExecutionModeProvider;
}

+ (QCPlugInTimeMode)timeMode
{
	return kQCPlugInTimeModeNone;
}

- (instancetype)init
{
	self = [super init];
	if (self)
    {
        image = NULL;
        self.loadedImage = NO;
	}
	
	return self;
}

- (void) dealloc
{
    [super dealloc];

}

@end

@implementation v002_Image_LoaderPlugIn (Execution)

- (BOOL)startExecution:(id <QCPlugInContext>)context
{
	return YES;
}

- (void)enableExecution:(id <QCPlugInContext>)context
{
}

- (BOOL)execute:(id <QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary *)arguments
{
		
    if([self didValueForInputKeyChange:@"inputImagePath"] || [self didValueForInputKeyChange:@"inputColorCorrect"])
    {
        // Bail early if we have a nil or empty path because f that noise.
        if(!self.inputImagePath || (self.inputImagePath.length == 0))
        {
            return YES;
        }
        
        // load image
        CGImageSourceRef imageSource;
        NSDictionary* opts = @{(NSString*)kCGImageSourceShouldAllowFloat : @YES,
                               (NSString*)kCGImageSourceShouldCache : @YES,
                               (NSString*)kCGImageSourceShouldCacheImmediately : @YES};
        
        NSString* standardPath = [self.inputImagePath stringByStandardizingPath];
        
        NSURL* filePathURL = [NSURL fileURLWithPath:standardPath];
        imageSource = CGImageSourceCreateWithURL((CFURLRef) filePathURL, NULL);
        
        image = CGImageSourceCreateImageAtIndex(imageSource, 0, (CFDictionaryRef)opts);
    
        // our output image
        id<QCPlugInOutputImageProvider> imageProvider = nil;

        // calculate our image format
        // Note we are not
        NSString* imageProviderFormat = nil;

        size_t imageBitsPerComponent = CGImageGetBitsPerComponent(image);
        if(imageBitsPerComponent == 32)
        {
            imageProviderFormat = QCPlugInPixelFormatRGBAf;
        }
        else if(imageBitsPerComponent == 16)
        {
            // QC does not support 16 bbc
            // TODO: Swizzle it to 32 by rendering into a 32 CGBitmap context.
            imageProviderFormat = nil;
        }
        else if (imageBitsPerComponent == 8)
        {
#if __BIG_ENDIAN__
            imageProviderFormat = QCPlugInPixelFormatARGB8;
#else 
            imageProviderFormat = QCPlugInPixelFormatBGRA8;
#endif
        }
        
        if(imageProviderFormat)
        {
            size_t imageWidth = CGImageGetWidth(image);
            size_t imageHeight = CGImageGetHeight(image);
            size_t imageBytesPerRow = CGImageGetBytesPerRow(image);
            CGColorSpaceRef imageColorSpace = CGImageGetColorSpace(image);
            
            CGDataProviderRef imageDataProvider = CGImageGetDataProvider(image);
            
            CFDataRef data = CGDataProviderCopyData(imageDataProvider);
            void* baseAdrress = (void*)CFDataGetBytePtr(data);
            
            imageProvider = [context outputImageProviderFromBufferWithPixelFormat:imageProviderFormat
                                                                       pixelsWide:imageWidth
                                                                       pixelsHigh:imageHeight
                                                                      baseAddress:baseAdrress
                                                                      bytesPerRow:imageBytesPerRow
                                                                  releaseCallback:MyQCPlugInBufferReleaseCallback
                                                                   releaseContext:image
                                                                       colorSpace:imageColorSpace
                                                                 shouldColorMatch:self.inputColorCorrect];
            
            CGDataProviderRelease(imageDataProvider);
        }
        if(imageProvider)
            self.outputImage = imageProvider;
        else
            self.outputImage = nil;

    }
    
	return YES;
}

- (void)disableExecution:(id <QCPlugInContext>)context
{
}

- (void)stopExecution:(id <QCPlugInContext>)context
{
}

@end
