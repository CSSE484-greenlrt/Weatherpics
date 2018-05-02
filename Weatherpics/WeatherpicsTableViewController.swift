//
//  WeatherpicsTableViewController.swift
//  Weatherpics
//
//  Created by Ryan Greenlee on 4/6/18.
//  Copyright © 2018 Ryan Greenlee. All rights reserved.
//

import UIKit
import Firebase

class WeatherpicsTableViewController: UITableViewController {
    
    
    @IBOutlet weak var weatherpicsNavigationItem: UINavigationItem!
    
    var weatherpicsRef: CollectionReference!
    var myWeatherpicsQuery: Query!
    var weatherpicsListener: ListenerRegistration!
    
    let weatherpicCellIdentifier = "WeatherpicCell"
    let noWeatherpicCellIdentifier = "NoWeatherpicCell"
    let showDetailSegueIdentifier = "ShowDetailSegue"
    var weatherpics = [Weatherpic]()
    var showingAllWeatherpics = true

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Menu",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(showMenu))
        weatherpicsRef = Firestore.firestore().collection("weatherpics")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.weatherpics.removeAll()
        self.displayWeatherpics(weatherpicsRef: weatherpicsRef)
        showingAllWeatherpics = true
        
        weatherpicsRef.document("project").addSnapshotListener { (documentSnapshot, error) in
            if let error = error {
                print("Error fetching document. \(error.localizedDescription)")
                return
            }
            self.weatherpicsNavigationItem.title = documentSnapshot?.get("name") as? String
        }
        
        guard let currentUser = Auth.auth().currentUser else { return }
        myWeatherpicsQuery = weatherpicsRef.whereField("uid", isEqualTo: currentUser.uid)
    }
    
    func displayWeatherpics(weatherpicsRef: CollectionReference) {
        weatherpicsListener = weatherpicsRef.order(by: "created", descending: true).limit(to: 50).addSnapshotListener({ (weatherpicSnapshot, error) in
            guard let snapshot = weatherpicSnapshot else {
                print("Error fetching weatherpic. error: \(error!.localizedDescription)")
                return
            }
            snapshot.documentChanges.forEach {(docChange) in
                if (docChange.type == .added) {
                    print("New weatherpic: \(docChange.document.data())")
                    self.picAdded(docChange.document)
                } else if (docChange.type == .modified) {
                    print("Modified weatherpic: \(docChange.document.data())")
                    self.picUpdated(docChange.document)
                } else if (docChange.type == .removed) {
                    print("Removed weatherpic: \(docChange.document.data())")
                    self.picRemoved(docChange.document)
                }
            }
            self.weatherpics.sort(by: { (mq1, mq2) -> Bool in
                return mq1.created > mq2.created
            })
            self.tableView.reloadData()
        })
    }
    
    func picAdded(_ document: DocumentSnapshot) {
        let newWeatherpic = Weatherpic(documentSnapshot: document)
        weatherpics.append(newWeatherpic)
    }
    
    func picUpdated(_ document: DocumentSnapshot) {
        let modifiedWeatherpic = Weatherpic(documentSnapshot: document)
        for weatherpic in weatherpics {
            if (weatherpic.id == modifiedWeatherpic.id) {
                weatherpic.caption = modifiedWeatherpic.caption
                weatherpic.imageUrl = modifiedWeatherpic.imageUrl
                break
            }
        }
    }
    
    func picRemoved(_ document: DocumentSnapshot) {
        for i in 0 ..< weatherpics.count {
            if weatherpics[i].id == document.documentID {
                weatherpics.remove(at: i)
                break
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        weatherpicsListener.remove()
    }
    
    @objc func showMenu() {
        let optionMenu = UIAlertController(title: nil, message: "Photo Bucket Options", preferredStyle: .actionSheet)
        
        let addAction = UIAlertAction(title: "Add Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.showAddDialog()
        })
        
        var editAction: UIAlertAction
        if !self.isEditing {
            editAction = UIAlertAction(title: "Select photos to delete", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                super.setEditing(true, animated: true)
            })
        } else {
            editAction = UIAlertAction(title: "Done editing", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                super.setEditing(false, animated: true)
            })
        }
        
        var showAction: UIAlertAction
        if self.showingAllWeatherpics {
            showAction = UIAlertAction(title: "Show only my photos", style: .default, handler: { (alert: UIAlertAction!) -> Void in
                self.weatherpics.removeAll()
//                self.displayWeatherpics(weatherpicsRef: self.currentUserWeatherpicsRef)
                self.myWeatherpicsQuery.addSnapshotListener({ (querySnapshot, error) in
                    guard let snapshot = querySnapshot else {
                        print("Error fetching query. error: \(error?.localizedDescription)")
                        return
                    }
                    snapshot.documentChanges.forEach {(docChange) in
                        if (docChange.type == .added) {
                            print("New weatherpic: \(docChange.document.data())")
                            self.picAdded(docChange.document)
                        } else if (docChange.type == .modified) {
                            print("Modified weatherpic: \(docChange.document.data())")
                            self.picUpdated(docChange.document)
                        } else if (docChange.type == .removed) {
                            print("Removed weatherpic: \(docChange.document.data())")
                            self.picRemoved(docChange.document)
                        }
                    }
                    self.weatherpics.sort(by: { (mq1, mq2) -> Bool in
                        return mq1.created > mq2.created
                    })
                    self.tableView.reloadData()
                })
                self.showingAllWeatherpics = false
            })
        } else {
            showAction = UIAlertAction(title: "Show all photos", style: .default, handler: { (alert: UIAlertAction!) -> Void in
                self.weatherpics.removeAll()
                self.displayWeatherpics(weatherpicsRef: self.weatherpicsRef)
                self.showingAllWeatherpics = true
            })
        }
        
        let signOutAction = UIAlertAction(title: "Sign out", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.appDelegate.handleLogout()
        })
        signOutAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        optionMenu.addAction(addAction)
        
//        if !self.isEditing {
//            editAction.isEnabled = false
//        }
        optionMenu.addAction(editAction)
        
        optionMenu.addAction(showAction)
        optionMenu.addAction(signOutAction)
        
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @objc func showAddDialog() {
        let alertController = UIAlertController(title: "Create a new Weatherpic",
                                                message: "",
                                                preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Caption"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Image URL (or blank)"
        }
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: UIAlertActionStyle.cancel,
                                         handler: nil)
        let createAction = UIAlertAction(title: "Create",
                                         style: UIAlertActionStyle.default) {
                                            (action) in
                                            let captionTextField = alertController.textFields![0]
                                            let imageURLTextField = alertController.textFields![1]
                                            if (imageURLTextField.text?.isEmpty)! {
                                                imageURLTextField.text = self.getRandomImageUrl()
                                            }
                                            print("caption: \(captionTextField.text)")
                                            let newWeatherpic = Weatherpic(caption: captionTextField.text!,
                                                                           imageUrl: imageURLTextField.text!)
                                            self.weatherpicsRef.addDocument(data: newWeatherpic.data)
//                                            newWeatherpic.caption = captionTextField.text!
//                                            newWeatherpic.imageUrl = imageURLTextField.text!
//                                            newWeatherpic.created = Date()
//                                            self.save()
//                                            self.updateWeatherpicArray()
//
//                                            if self.weatherpics.count == 1 {
//                                                self.tableView.reloadData()
//                                            } else {
//                                                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.top)
//                                            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(createAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func getRandomImageUrl() -> String {
        let testImages = ["http://upload.wikimedia.org/wikipedia/commons/0/04/Hurricane_Isabel_from_ISS.jpg",
                          "http://t.wallpaperweb.org/wallpaper/nature/1920x1080/Lightning_Storm_Over_Fort_Collins_Colorado.jpg",
                          "http://upload.wikimedia.org/wikipedia/commons/0/00/Flood102405.JPG",
                          "http://upload.wikimedia.org/wikipedia/commons/6/6b/Mount_Carmel_forest_fire14.jpg"]
        var randomIndex = Int(arc4random_uniform(UInt32(testImages.count)))
        return testImages[randomIndex];
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        if weatherpics.count == 0 {
            print("Don't allow editing mode at this time")
            super.setEditing(false, animated: animated)
        } else {
            super.setEditing(editing, animated: animated)
        }
    }


    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int
//        return 1
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(weatherpics.count, 1)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if weatherpics.count == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: noWeatherpicCellIdentifier, for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: weatherpicCellIdentifier, for: indexPath)
            cell.textLabel?.text = weatherpics[indexPath.row].caption
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        var canEdit = false
        
        let documentRef = myWeatherpicsQuery.firestore.document(weatherpics[indexPath.row].id!)
        documentRef.getDocument { (document, error) in
            if (document?.exists)! {
                canEdit = true
            }
        }
        
        return canEdit
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
//            context.delete(weatherpics[indexPath.row])
//            save()
//            updateWeatherpicArray()
//            if weatherpics.count == 0 {
//                tableView.reloadData()
//                self.setEditing(false, animated: true)
//            } else {
//                tableView.deleteRows(at: [indexPath], with: .fade)
//            }
            let weatherpicToDelete = weatherpics[indexPath.row]
            weatherpicsRef.document(weatherpicToDelete.id!).delete()
        }
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == showDetailSegueIdentifier {
            // Goal: Pass the selected weatherpic to the detail view controller.
            
            if let indexPath = tableView.indexPathForSelectedRow {
                
                (segue.destination as! WeatherpicDetailViewController).weatherpicRef = weatherpicsRef.document(weatherpics[indexPath.row].id!)
            }
        }
    }
 

}
