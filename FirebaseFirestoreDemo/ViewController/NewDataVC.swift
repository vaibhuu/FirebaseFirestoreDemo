//
//  NewDataVC.swift
//  FirebaseFirestoreDemo
//
//  Created by Vaibhu Thakkar on 19/04/22.
//

import UIKit
import FirebaseDatabase
import Firebase

class NewDataVC: UIViewController {

    var rootRef = Firestore.firestore().collection("sampleData")//collection/document/collection/document
    
    var listArray = [DataEntry]()
    
    var isFromEdit = false
    var docRef: DocumentReference!

    //MARK:- IBOutlet
    @IBOutlet weak var txtNewData: UITextField!
   
    //MARK:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    //MARK:- IBAction
    @IBAction func btnAddAction(_ sender: Any) {
        if listArray.filter({$0.name.lowercased() == txtNewData.text?.lowercased()}).count > 0 {
            let alert = UIAlertController(title: "Error", message: "Name already exists", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let dict = ["name": txtNewData.text]
            if isFromEdit {
                docRef.updateData(dict)
            } else {
                rootRef.addDocument(data: dict)
            }
            self.navigationController?.popViewController(animated: true)
        }
    }

}
