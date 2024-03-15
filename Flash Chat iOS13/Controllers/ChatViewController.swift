//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    var messages : [Message] = [Message(sender: "raghu@gmail..com", body: "Hey")]
    
    override func viewDidLoad() {
        title = Constants.appName
        tableView.dataSource = self
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
    
        tableView.register(UINib(nibName: Constants.cellNibName, bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier)
        
        loadMessages()
    }
    
    func loadMessages() {
        db.collection(Constants.FStore.collectionName)
            .order(by: Constants.FStore.dateField)
            .addSnapshotListener { querySnapshot, error in
            self.messages = []
            if let e = error {
                print("There was a issue retrieving data from Firestore \(e)")
            } else {
                if let snapshotDoc = querySnapshot?.documents {
                    for doc in snapshotDoc {
                        let data = doc.data()
                        if let sender = data[Constants.FStore.senderField] as? String , let body = data[Constants.FStore.bodyField] as? String {
                            let newMessage = Message(sender: sender, body: body)
                            self.messages.append(newMessage)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageBody =  messageTextfield.text , let messageSender = Auth.auth().currentUser?.email {
            db.collection(Constants.FStore.collectionName).addDocument(data: [Constants.FStore.senderField: messageSender,
                                                                              Constants.FStore.bodyField : messageBody,
                                                                              Constants.FStore.dateField : Date().timeIntervalSince1970]) { (error) in
                if let e = error {
                    print("There was issue storing data to firestore, \(e)")
                } else {
                    print("Succesfully stored")
                }
            }
        }
    }
    
    @IBAction func logOutPressed(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    

}

extension ChatViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath)  as! MessageCell
        cell.label?.text = messages[indexPath.row].body
        return cell
    }
    
    
}
