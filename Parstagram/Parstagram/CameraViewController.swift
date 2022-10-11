//
//  CameraViewController.swift
//  Parstagram
//
//  Created by Sammy Torres II on 10/10/22.
//

import UIKit
import AlamofireImage
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.isUserInteractionEnabled = true

        // Do any additional setup after loading the view.
    }
    
    // Creates object for table
    @IBAction func onSubmitButton(_ sender: Any) {
        //an object for posting
        let post = PFObject(className: "Posts")
        
        //Below is the schema(columns/rows) for parse
        post["caption"] = commentField.text!
        post["author"] = PFUser.current() // it's the current user logged in
        
        let imageData = imageView.image!.pngData() // saves the image
        let file = PFFileObject(name: "image.png", data: imageData!) // a binary object to add image as a column
        
        post["image"] = file
        
        
        post.saveInBackground{ (success, error) in
            if (success){
                self.dismiss(animated: true, completion: nil)
                print("saved!")
            }
            else {
                print("error!")
            }
        }
    }
    
    // Launches the camera
    @IBAction func onCameraButton(_ sender: Any) {
        
        let picker = UIImagePickerController()
        // this lets us know after taken the photo what was taken and call me back
        picker.delegate = self
        // allows the user after taken the photo to tweak it (edit) befor finishing up
        picker.allowsEditing = true
        
        // this checks if a camera is available else use the photo library
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        }
        else {
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    // Lets user add an image to screen
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        
        //resizes image
        let size = CGSize(width: 300, height: 300)
        //this is an Alamofire extension to scale down image
        let scaledImage = image.af.imageScaled(to: size)
        //This puts the scaled image inside of image view
        imageView.image = scaledImage
        
        //dismisses camera view
        dismiss(animated: true, completion: nil)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
