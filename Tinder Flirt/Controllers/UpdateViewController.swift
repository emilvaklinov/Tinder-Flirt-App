//
//  UpdateViewController.swift
//  Tinder Flirt
//
//  Created by Emil Vaklinov on 02/05/2020.
//  Copyright © 2020 Emil Vaklinov. All rights reserved.
//

import UIKit
import Parse

class UpdateViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var userGenderSwitch: UISwitch!
    @IBOutlet weak var interestedGenderSwitch: UISwitch!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorLabel.isHidden = true
        
        if let isFemale = PFUser.current()?["isFemale"] as? Bool {
            userGenderSwitch.setOn(isFemale, animated: false)
        }
        
        if let isInterestedInWomen = PFUser.current()?["isInterestedInWomen"] as? Bool {
            interestedGenderSwitch.setOn(isInterestedInWomen, animated: false)
        }
        
        if let photo = PFUser.current()?["photo"] as? PFFileObject {
            photo.getDataInBackground(block: { (data, error) in
                if let imageData = data {
                    if let image = UIImage(data: imageData) {
                        self.profileImageView.image = image
                    }
                }
            })
        }

    }
    
    func createWomen() {
        let imageUrls = ["https://upload.wikimedia.org/wikipedia/en/7/76/Edna_Krabappel.png","https://static.comicvine.com/uploads/scale_small/0/40/235856-101359-ruth-powers.png","http://vignette3.wikia.nocookie.net/simpsons/images/f/fb/Serious-sam--cover.jpg","https://s-media-cache-ak0.pinimg.com/736x/e4/42/5a/e4425aad73f01d36ace4c86c3156dcdc.jpg","http://www.simpsoncrazy.com/content/pictures/onetimers/LurleenLumpkin.gif","https://vignette2.wikia.nocookie.net/simpsons/images/b/bc/Becky.gif","http://vignette3.wikia.nocookie.net/simpsons/images/b/b0/Woman_resembling_Homer.png"]
        
        var counter = 0
            
            for imageUrl in imageUrls {
                counter += 1
                if let url = URL(string: imageUrl) {
                    if let data = try? Data(contentsOf: url) {
                        let imageFile = PFFileObject(name: "photo.png", data: data)
                        
                        let user = PFUser()
                        user["photo"] = imageFile
                        user.username = String(counter)
                        user.password = "abc123"
                        user["isFemale"] = true
                        user["isInterestedInWomen"] = false
                        
                        user.signUpInBackground(block: { (success, error) in
                            if success {
                                print("Women User created!")
                            }
                        })
                    }
                }
            }
        }
    
    @IBAction func updateImageTapped(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateTapped(_ sender: Any) {
        PFUser.current()?["isFemale"] = userGenderSwitch.isOn
               PFUser.current()?["isInterestedInWomen"] = interestedGenderSwitch.isOn
               
               if let image = profileImageView.image {
               
                if let imageData = image.pngData() {
                   
                       PFUser.current()?["photo"] = PFFileObject(name: "profile.png", data: imageData)
                       
                       PFUser.current()?.saveInBackground(block: { (success, error) in
                           if error != nil {
                               var errorMessage = "Update Failed - Try Again"
                               
                               if let newError = error as NSError? {
                                   if let detailError = newError.userInfo["error"] as? String {
                                       errorMessage = detailError
                                   }
                               }
                               
                               self.errorLabel.isHidden = false
                               self.errorLabel.text = errorMessage
                               
                           } else {
                               print("Update Successful")
                            self.performSegue(withIdentifier: "updateToSwipeSague", sender: nil)
                           }
                       })
                   }
               }
               
           }
}
