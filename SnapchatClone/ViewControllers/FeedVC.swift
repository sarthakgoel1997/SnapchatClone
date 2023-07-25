//
//  FeedVC.swift
//  SnapchatClone
//
//  Created by Sarthak Goel on 29/06/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SDWebImage

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    let firestoreDatabase = Firestore.firestore()
    var snapArray = [Snap]()
    
    var chosenSnap : Snap?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getSnapsFromFirestore()
        getUserInfo()
    }
    
    func getSnapsFromFirestore() {
        firestoreDatabase.collection("Snaps").order(by: "date", descending: true).addSnapshotListener { (snapshot, getSnapsError) in
            if getSnapsError != nil {
                self.makeAlert(title: "Error", message: getSnapsError?.localizedDescription ?? "Error while getting data")
            } else if snapshot != nil && snapshot?.isEmpty == false {
                self.snapArray.removeAll()
                
                for doc in snapshot!.documents {
                    let documentId = doc.documentID
                    
                    if let username = doc.get("snapOwner") as? String {
                        if let imageUrlArray = doc.get("imageUrlArray") as? [String] {
                            if let date = doc.get("date") as? Timestamp {
                                
                                if let difference = Calendar.current.dateComponents([.hour], from: date.dateValue(), to: Date()).hour {
                                    if difference >= 24 {
                                        self.firestoreDatabase.collection("Snaps").document(documentId).delete { (deleteError) in
                                            if deleteError != nil {
                                                self.makeAlert(title: "Error", message: deleteError?.localizedDescription ?? "Error while deleting data after 24 hours")
                                            }
                                        }
                                    } else {
                                        let snap = Snap(username: username, imageUrlArray: imageUrlArray, date: date.dateValue(), timeLeft: 24 - difference)
                                        self.snapArray.append(snap)
                                    }
                                }
                            }
                        }
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func getUserInfo() {
        firestoreDatabase.collection("UserInfo").whereField("email", isEqualTo: Auth.auth().currentUser!.email!).getDocuments { (snapshot, error) in
            if error != nil {
                self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error while getting user info")
            } else if snapshot != nil && snapshot?.isEmpty == false {
                for doc in snapshot!.documents {
                    if let username = doc.get("username") as? String {
                        UserSingleton.sharedUserInfo.email = Auth.auth().currentUser!.email!
                        UserSingleton.sharedUserInfo.username = username
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return snapArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedCell
        cell.feedUsernameLabel.text = snapArray[indexPath.row].username
        cell.feedImageView.sd_setImage(with: URL(string: snapArray[indexPath.row].imageUrlArray[0]))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenSnap = snapArray[indexPath.row]
        performSegue(withIdentifier: "toSnapVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSnapVC" {
            let destVC = segue.destination as! SnapVC
            destVC.selectedSnap = chosenSnap
        }
    }

}
