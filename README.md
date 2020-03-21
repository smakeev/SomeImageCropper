# SomeImageCropper
![Farmers Market Finder Demo](demo/demo.gif)

# How to use:
```
use_frameworks!
pod "SomeImageCropper"
```

# dependencies 
https://github.com/smakeev/SomeInnerView

Example:
```swift
let cropper: CropperView = CropperView()
...
cropper.sourceImage = image
//after that user will be able to select part of the image

_ = cropper.crop() { img in
			imageView.image = img //put result
		}
```
