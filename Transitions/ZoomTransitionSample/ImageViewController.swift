//
//  ImageViewController.swift
//  Transitions
//
//  Created by Tristan Himmelman on 2014-09-30.
//  Copyright (c) 2014 him. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, ZoomTransitionProtocol {

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        imageView.userInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTapGesture:"))
        imageView.addGestureRecognizer(tapGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()
        
//        let topGuide = self.topLayoutGuide;
//        let views = ["_imageView": imageView, "topGuide": topGuide]
//        let constraint:[AnyObject]! = NSLayoutConstraint.constraintsWithVisualFormat("V:[topGuide][_imageView]", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: views)
//        self.view.addConstraints(constraint)
    }
    
    func handleTapGesture(gesture: UITapGestureRecognizer){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func viewForTransition() -> UIView {
        return imageView
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
