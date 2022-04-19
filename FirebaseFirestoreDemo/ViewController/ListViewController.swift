//
//  ListViewController.swift
//  FirebaseFirestoreDemo
//
//  Created by Vaibhu Thakkar on 19/04/22.
//

import UIKit
import FirebaseDatabase
import Firebase
import FirebaseAuth

class ListViewController: UIViewController {

    var rootRef = Firestore.firestore().collection("sampleData")
    var listner: ListenerRegistration!
    var listArray = [DataEntry]()
    var dictRes = NSDictionary()
    
    //MARK:- IBOutlet
    @IBOutlet weak var tblList: UITableView!
    
    //MARK:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
            
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //MARK:- Firestore get document
        //includeMetadataChanges this listens to callback of server even if it is locally updated(Metadata is present) Should keep it off unless we externally need it

        listner = rootRef.addSnapshotListener(includeMetadataChanges: true) { (snapshot, error) in
            self.listArray.removeAll()
            snapshot?.documents.forEach({ (document) in
                let dictionary = document.data()
                self.listArray.append(DataEntry(reference: document.documentID, name: dictionary["name"] as? String ?? ""))
            })
            self.tblList.reloadData()

        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        listner.remove()
    }
    
    //MARK:- IBAction
    @IBAction func btnAddAction(_ sender: Any) {
        if let newDataVc = self.storyboard?.instantiateViewController(identifier: "NewDataVC") as? NewDataVC {
            newDataVc.listArray = listArray
            self.navigationController?.pushViewController(newDataVc, animated: true)
        }
    }
    
   
}

extension ListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblList.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = listArray[indexPath.row].name
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let newDataVc = self.storyboard?.instantiateViewController(identifier: "NewDataVC") as? NewDataVC {
            newDataVc.listArray = listArray
            newDataVc.isFromEdit = true
            newDataVc.docRef = rootRef.document(listArray[indexPath.row].reference)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                newDataVc.txtNewData.text = self.listArray[indexPath.row].name
            }
            self.navigationController?.pushViewController(newDataVc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
          if editingStyle == .delete {
            print("Deleted")
            print(indexPath.row)
            //MARK:- Firestore delete
            rootRef.document(listArray[indexPath.row].reference).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
          }
        }
    
}


class DataEntry {
    var reference = ""
    var name = ""
    
    init(reference: String, name: String) {
        self.reference = reference
        self.name = name
    }
}
