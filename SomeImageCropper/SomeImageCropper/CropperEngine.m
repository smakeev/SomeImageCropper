//
//  CropperEngine.m
//  SomeImageCropper
//
//  Created by Sergey Makeev on 21.03.2020.
//  Copyright © 2020 SOME projects. All rights reserved.
//

#import "CropperEngine.h"

@implementation CropperEngine

- (UIImage* _Nullable) doCropFor:(UIImage*) sourceImage rect:(CGRect) rect scale:(NSNumber*) scale {
	
	NSData *imageData = UIImagePNGRepresentation(sourceImage);
	
	CFDictionaryRef options = (__bridge CFDictionaryRef) @{
		(id) kCGImageSourceCreateThumbnailWithTransform: @YES,
		(id) kCGImageSourceCreateThumbnailFromImageAlways: @YES
	};
	
	CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
	CGImageRef image = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options);
	
	 if (image == NULL) {
		return nil;
	 }
	 
	size_t width = CGImageGetWidth(image);
	size_t height = CGImageGetHeight(image);
	size_t scaledWidth = (size_t) (width * rect.size.width * scale.floatValue);
	size_t scaledHeight = (size_t) (height * rect.size.height * scale.floatValue);
	size_t bitsPerComponent = CGImageGetBitsPerComponent(image);
	size_t bytesPerRow = CGImageGetBytesPerRow(image) / width * scaledWidth;
	CGImageAlphaInfo bitmapInfo = CGImageGetAlphaInfo(image);
	CGColorSpaceRef colorspace = CGImageGetColorSpace(image);
	
	CGImageRef croppedImage = CGImageCreateWithImageInRect(image,
														   CGRectMake(width * rect.origin.x,
																	  height * rect.origin.y,
																	  width * rect.size.width,
																	  height * rect.size.height));
	
	CFRelease(image);
	CFRelease(imageSource);
	
	if (scale.floatValue != 1.0) {
		CGContextRef context = CGBitmapContextCreate(NULL,
													 scaledWidth,
													 scaledHeight,
													 bitsPerComponent,
													 bytesPerRow,
													 colorspace,
													 bitmapInfo);
		
		if (context == NULL) {
			//can't scale
			CFRelease(croppedImage);
			return nil;
		}
		
		CGRect rect = CGContextGetClipBoundingBox(context);
		CGContextDrawImage(context, rect, croppedImage);
		
		CGImageRef scaledImage = CGBitmapContextCreateImage(context);
		
		CGContextRelease(context);
		CFRelease(croppedImage);
		
		croppedImage = scaledImage;
	}
	
	UIImage *resultImage = [[UIImage alloc] initWithCGImage: croppedImage];
	
	CFRelease(croppedImage);
	
	return resultImage;
}

@end
