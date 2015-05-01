ZoomTransition
==============

An easy to use interactive zoom transition for presenting view controllers onto a navigation stack. This transition mimics the iOS 7 & 8 photos app. 

ZoomTransition supports pinch, rotate and pan gestures while dismissing the presented view controller. 

![Screenshot](https://raw.githubusercontent.com/tristanhimmelman/ZoomTransition/master/example.gif)

To add to your app, simply create a ZoomTransition by passing the current NavigationController
Then set the ZoomTransition object be the NavigationController delegate
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

ZoomTransition can be easily added to your project using [Cocoapods](https://cocoapods.org/) by adding the following to your Podfile:

`pod 'ObjectMapper', '~> 0.11'`

Otherwise you can include ZoomTransition.swift directly to your project.
