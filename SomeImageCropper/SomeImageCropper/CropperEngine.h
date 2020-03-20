//
//  CropperEngine.h
//  SomeImageCropper
//
//  Created by Sergey Makeev on 21.03.2020.
//  Copyright © 2020 SOME projects. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CropperEngine : NSObject

- (UIImage* _Nullable) doCropFor:(UIImage*) sourceImage rect:(CGRect) rect scale:(NSNumber*) scale;

@end

NS_ASSUME_NONNULL_END
