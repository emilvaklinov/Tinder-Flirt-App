//
//  ViewController.swift
//  Tinder Flirt
//
//  Created by Emil Vaklinov on 02/05/2020.
//  Copyright © 2020 Emil Vaklinov. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {
    
    var displayUserID = ""
    
    @IBOutlet weak var swipeImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(gestureRecognizer:)))
        swipeImage.addGestureRecognizer(gesture)
        
        updateImage()
    }
    @IBAction func logoutTapped(_ sender: Any) {
        PFUser.logOut()
        performSegue(withIdentifier: "logoutSegue", sender: nil)
    }
    
    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        let labelPoint = gestureRecognizer.translation(in: view)
        swipeImage.center = CGPoint(x: view.bounds.width / 2 + labelPoint.x, y: view.bounds.height / 2 + labelPoint.y)
        
        let xFromCenter = view.bounds.width / 2 - swipeImage.center.x
        
        var rotation = CGAffineTransform(rotationAngle: xFromCenter / 200)
        
        let scale = min(100 / abs(xFromCenter), 1)
        
        var scaledAndRotated = rotation.scaledBy(x: scale, y: scale)
        
        swipeImage.transform = scaledAndRotated
        
        // Fixing swiping to exact point
        if gestureRecognizer.state == .ended {
            var acceptedOrRejected = ""
            
            if swipeImage.center.x < (view.bounds.width / 2 - 100) {
                print("Not interested")
                acceptedOrRejected = "rejected"
            }
            if swipeImage.center.x < (view.bounds.width / 2 + 100) {
                print("Interested")
                acceptedOrRejected = "accepted"
            }
            
            if acceptedOrRejected != "" && displayUserID != "" {
                PFUser.current()?.addUniqueObject(displayUserID, forKey: acceptedOrRejected)
                
                PFUser.current()?.saveInBackground(block: { (success, error) in
                    if success {
                        self.updateImage()
                    }
                })
            }
            // Fixing the rotation
            rotation = CGAffineTransform(rotationAngle: 0)
            scaledAndRotated = rotation.scaledBy(x: 1, y: 1)
            swipeImage.transform = scaledAndRotated
            
            swipeImage.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
            
            
        }
    }
    
    func updateImage() {
        if let query = PFUser.query() {
            if let isInterestedInWomen = PFUser.current()?["isInterestedInWomen"] {
                query.whereKey("isFemale", equalTo: isInterestedInWomen)
            }
            if let isFemale = PFUser.current()?["isFemale"] {
                query.whereKey("isInterestedInWomen", equalTo: isFemale)
            }
            query.limit = 1
            query.findObjectsInBackground { (objects, error) in
                if let users = objects {
                    for object in users {
                        if let user = object as? PFUser {
                            if let imageFile = user["photo"] as? PFFileObject {
                                imageFile.getDataInBackground(block: { (data, error) in
                                    if let imageData = data {
                                        self.swipeImage.image = UIImage(data: imageData)
                                        if let objectID = object.objectId {
                                            self.displayUserID = objectID
                                        }
                                    }
                                })
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
}
