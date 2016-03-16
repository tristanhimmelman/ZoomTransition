ZoomTransition
==============
[![CocoaPods](https://img.shields.io/cocoapods/v/ZoomTransition.svg)](https://github.com/tristanhimmelman/ZoomTransition)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

An easy to use interactive zoom transition for presenting view controllers onto a navigation stack. This transition mimics the iOS 7 & 8 photos app. 

ZoomTransition supports pinch, rotate and pan gestures while dismissing the presented view controller. 

![Screenshot](https://raw.githubusercontent.com/tristanhimmelman/ZoomTransition/master/example.gif)

To use the transition in your app, simply create a ZoomTransition object by passing in the current NavigationController.
Then set the ZoomTransition object to be the NavigationControllers delegate
```swift
if let navigationController = self.navigationController {
    self.animationController = ZoomTransition(navigationController: navigationController)
}
self.navigationController?.delegate = animationController

// present view controller
let imageViewController = ImageViewController(nibName: "ImageViewController", bundle: nil)
self.navigationController?.pushViewController(imageViewController, animated: true)
```

Finally, you must implement the ZoomTransistionProtocol on both the presenting and the presented view controllers so the ZoomTransition knows which views to transition between
```swift
func viewForTransition() -> UIView {
	return imageView
}
```

#Installation

ZoomTransition can be easily added to your project using [CocoaPods](https://cocoapods.org/) by adding the following to your Podfile:

`pod 'ZoomTransition', '~> 0.3'`

Otherwise you can include ZoomTransition.swift directly to your project.
