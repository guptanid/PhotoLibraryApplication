//
//  PhotoViewController.swift
//  InClass07
//
//  Created by Gupta, Nidhi on 10/26/17.
//  Copyright © 2017 Example. All rights reserved.
//

import UIKit
import Firebase
import  SDWebImage
class PhotoViewController: UIViewController {
    
    var photoInformation = PhotoCollection()
    var userID: String = ""
    var ref: DatabaseReference!
    
    @IBOutlet weak var signleImageView: UIImageView!
    
    @IBAction func btnDeletePhoto(_ sender: Any) {
       showAlert("Do you want to delete this photo?")
    }
    func showAlert(_ message: String) {
        let alertController = UIAlertController(title: "Photo Delete", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let actionOK = UIAlertAction(title: "Delete", style: .default) { (alertAction:UIAlertAction) in
            
            let photoRef = self.ref.child("Photos").child(self.userID).child(self.photoInformation.photoKey)
            photoRef.removeValue()
            photoRef.removeValue { error, _ in
                if let error = error {
                    print("error")
                    print(error.localizedDescription)
                } else {
                    print("deleted successfully from DB")
                }
            }
            
             let photoStorageRef = Storage.storage().reference(forURL: self.photoInformation.photoUrl)
            // Delete the file
            photoStorageRef.delete { error in
                if let error = error {
                   print("error")
                    print(error.localizedDescription)
                } else {
                    print("deleted successfully from Storage")
                }
            }
            _ = self.navigationController?.popViewController(animated: true)
           
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(actionOK)
        alertController.addAction(actionCancel)
        self.navigationController?.present(alertController, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        signleImageView.sd_setImage(with: URL.init(string: photoInformation.photoUrl), completed: nil)
        userID = (Auth.auth().currentUser?.uid)!
        ref = Database.database().reference()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
