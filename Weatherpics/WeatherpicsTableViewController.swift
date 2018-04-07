//
//  WeatherpicsTableViewController.swift
//  Weatherpics
//
//  Created by Ryan Greenlee on 4/6/18.
//  Copyright © 2018 Ryan Greenlee. All rights reserved.
//

import UIKit
import CoreData

class WeatherpicsTableViewController: UITableViewController {
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let weatherpicCellIdentifier = "WeatherpicCell"
    let noWeatherpicCellIdentifier = "NoWeatherpicCell"
    let showDetailSegueIdentifier = "ShowDetailSegue"
    var weatherpics = [Weatherpic]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(showAddDialog))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateWeatherpicArray()
        tableView.reloadData()
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
                                            let newWeatherpic = Weatherpic(context: self.context)
                                            newWeatherpic.caption = captionTextField.text!
                                            newWeatherpic.imageUrl = imageURLTextField.text!
                                            newWeatherpic.created = Date()
                                            self.save()
                                            self.updateWeatherpicArray()

                                            if self.weatherpics.count == 1 {
                                                self.tableView.reloadData()
                                            } else {
                                                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.top)
                                            }
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
    
    func save() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func updateWeatherpicArray() {
        // Make a fetch request
        // Execute the request in a try/catch block
        let request: NSFetchRequest<Weatherpic> = Weatherpic.fetchRequest()
         request.sortDescriptors = [NSSortDescriptor(key: "created", ascending: false)]
        
        do {
            weatherpics = try context.fetch(request)
        } catch {
            fatalError("Unresolved Core Data error \(error)")
        }
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
        return weatherpics.count > 0
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            context.delete(weatherpics[indexPath.row])
            save()
            updateWeatherpicArray()
            if weatherpics.count == 0 {
                tableView.reloadData()
                self.setEditing(false, animated: true)
            } else {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
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
                
                (segue.destination as! WeatherpicDetailViewController).weatherpic = weatherpics[indexPath.row]
            }
        }
    }
 

}
