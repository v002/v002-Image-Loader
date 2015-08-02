//
//  v002_Image_LoaderPlugIn.h
//  v002 Image Loader
//
//  Created by vade on 8/1/15.
//  Copyright (c) 2015 v002. All rights reserved.
//

#import <Quartz/Quartz.h>

@interface v002_Image_LoaderPlugIn : QCPlugIn
{
    CGImageRef image;
}

@property (assign) BOOL loadedImage;

@property (copy) NSString* inputImagePath;
@property (assign) BOOL inputColorCorrect; // CGColorRenderingIntent


@property (retain) id<QCPlugInOutputImageProvider> outputImage;

@end
