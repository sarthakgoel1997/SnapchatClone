//
//  UploadVC.swift
//  SnapchatClone
//
//  Created by Sarthak Goel on 29/06/23.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

class UploadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var uploadImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uploadImageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(choosePicture))
        uploadImageView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func choosePicture() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        uploadImageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
    }
    
    @IBAction func uploadClicked(_ sender: Any) {
        // Storage
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        let mediaFolder = storageReference.child("media")
        
        if let data = uploadImageView.image?.jpegData(compressionQuality: 0.5) {
            let uuid = UUID().uuidString
            let imageReference = mediaFolder.child("\(uuid).jpg")
            
            imageReference.putData(data) { (metadata, uploadImageError) in
                if uploadImageError != nil {
                    self.makeAlert(title: "Error", message: uploadImageError?.localizedDescription ?? "Error while uploading image")
                } else {
                    imageReference.downloadURL { (url, downloadUrlError) in
                        if downloadUrlError == nil {
                            let imageUrl = url?.absoluteString
                            
                            // Firestore
                            let firestore = Firestore.firestore()
                            
                            firestore.collection("Snaps").whereField("snapOwner", isEqualTo: UserSingleton.sharedUserInfo.username).getDocuments { (snapshot, getDocumentsError) in
                                if getDocumentsError != nil {
                                    self.makeAlert(title: "Error", message: getDocumentsError?.localizedDescription ?? "Error while getting data")
                                } else if snapshot != nil && snapshot?.isEmpty == false {
                                    
                                    for doc in snapshot!.documents {
                                        let documentId = doc.documentID
                                        if var imageUrlArray = doc.get("imageUrlArray") as? [String] {
                                            imageUrlArray.append(imageUrl!)
                                            let additionalDictionary = ["imageUrlArray" : imageUrlArray] as [String : Any]
                                            
                                            firestore.collection("Snaps").document(documentId).setData(additionalDictionary, merge: true) { (updateDataError) in
                                                if updateDataError != nil {
                                                    self.makeAlert(title: "Error", message: updateDataError?.localizedDescription ?? "Error while saving data to firestore")
                                                } else {
                                                    self.tabBarController?.selectedIndex = 0
                                                    self.uploadImageView.image = UIImage(named: "select")
                                                }
                                            }
                                        }
                                    }
                                    
                                } else {
                                    let snapDictionary = ["imageUrlArray": [imageUrl!], "snapOwner": UserSingleton.sharedUserInfo.username, "date": FieldValue.serverTimestamp()] as [String : Any]
                                    
                                    firestore.collection("Snaps").addDocument(data: snapDictionary) { (storeDataError) in
                                        if storeDataError != nil {
                                            self.makeAlert(title: "Error", message: storeDataError?.localizedDescription ?? "Error while saving data to firestore")
                                        } else {
                                            self.tabBarController?.selectedIndex = 0
                                            self.uploadImageView.image = UIImage(named: "select")
                                        }
                                    }
                                }
                            }
                            
                            
                        }
                    }
                }
            }
        }
    }
    
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
    
}
