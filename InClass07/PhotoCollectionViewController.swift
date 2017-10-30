//
//  PhotoCollectionViewController.swift
//  InClass07
//
//  Created by Gupta, Nidhi on 10/26/17.
//  Copyright © 2017 Example. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class PhotoCollectionViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var userID: String = ""
    private var photosCollection = [PhotoCollection]()
    
    var ref: DatabaseReference!
    override func viewDidAppear(_ animated: Bool) {
        userID = (Auth.auth().currentUser?.uid)!
        ref = Database.database().reference()
        GetAllUserPhotos()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       //  GetAllUserPhotos()
      
        /*self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)*/

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
      return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosCollection.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCellCollectionViewCell
        let photoUrl = photosCollection[indexPath.item].photoUrl
        cell.tag = indexPath.item
        cell.imageView.sd_setImage(with: URL(string : photoUrl), completed: nil)
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        //let photoUrl = photosCollection[indexPath.item]
        
        /*let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let navController = storyBoard.instantiateViewController(withIdentifier: "navController") as! UINavigationController
        let photoVC = self.storyboard!.instantiateViewController(withIdentifier: "photoVC") as! PhotoViewController
        photoVC.imageURL = photoUrl
        self.present(navController, animated: false, completion: {
            navController.title = "Photo"
            navController.pushViewController(photoVC, animated: true)
        })*/
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "photoSeque"){
            let tag = (sender as! PhotoCellCollectionViewCell!).tag
            let destination = segue.destination as! PhotoViewController
            destination.photoInformation = photosCollection[tag]
        }
        
        
    }
    @IBAction func btnUploadPhoto(_ sender: Any) {
        let imagePicker = UIImagePickerController()
       
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
          imagePicker.sourceType = .savedPhotosAlbum
          imagePicker.delegate = self
          imagePicker.allowsEditing = false
          self.present(imagePicker, animated: true, completion: nil)
        }
    }
    @IBAction func btnLogout_Clicked(_ sender: Any) {
        print("logout")
        try! Auth.auth().signOut()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyBoard.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
        self.present(loginViewController, animated: true, completion: nil)
    }
    func UploadImageToFirebaseStorage(data : Data){
        
        let photoId = UUID().uuidString
        
        let storageRef = Storage.storage().reference(withPath: String("\(photoId).jpg"))
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        storageRef.putData(data, metadata: uploadMetaData){(metadata, error) in
            if(error != nil){
                print(error?.localizedDescription ?? "error")
            }else{
                print("success")
                let photoUrl =  metadata?.downloadURL()?.absoluteString
                let userPhotoRef = self.ref.child("Photos").child(self.userID).childByAutoId()
                userPhotoRef.setValue(photoUrl)
                self.GetAllUserPhotos()
            }
        }
    }
    func GetAllUserPhotos(){
        let userPhotosRef = self.ref.child("Photos").child(self.userID)
        userPhotosRef.observeSingleEvent(of: DataEventType.value) { (snapshot) in
            if let photoURLCollection = snapshot.value as? NSDictionary{
                self.photosCollection.removeAll()
                for photo in photoURLCollection {
                    let newPhoto = PhotoCollection()
                    newPhoto.photoKey = photo.key as! String
                    newPhoto.photoUrl = (photo.value as? String)!
                    self.photosCollection.append(newPhoto)
                }
                self.collectionView?.reloadData()
            }
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        return
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
       
            if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage,
                let imageData = UIImageJPEGRepresentation(originalImage, 0.8){
                UploadImageToFirebaseStorage(data: imageData)
            }
          dismiss(animated: true, completion: nil)
    }
}

