//
//  ViewController.swift
//  Transitions
//
//  Created by Tristan Himmelman on 2014-09-30.
//  Copyright (c) 2014 him. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ZoomTransitionProtocol, UINavigationControllerDelegate {

    var animationController : ZoomTransition?;
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a 
    
        if let navigationController = self.navigationController {
            animationController = ZoomTransition(navigationController: navigationController)
        }
        
        imageView.userInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTapGesture:"))
        imageView.addGestureRecognizer(tapGesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func handleTapGesture(gesture: UITapGestureRecognizer){
        let imageViewController = ImageViewController(nibName: "ImageViewController", bundle: nil)
        self.navigationController?.delegate = animationController
        self.navigationController?.pushViewController(imageViewController, animated: true)
    }
    
    func viewForTransition() -> UIView {
        return imageView
    }
}

