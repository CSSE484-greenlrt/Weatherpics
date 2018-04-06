//
//  WeatherpicDetailViewController.swift
//  Weatherpics
//
//  Created by Ryan Greenlee on 4/6/18.
//  Copyright © 2018 Ryan Greenlee. All rights reserved.
//

import UIKit

class WeatherpicDetailViewController: UIViewController {

    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var weatherpicImageView: UIImageView!
    
    var weatherpic: Weatherpic?
 
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit Caption",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(showEditDialog))
    }
    
    @objc func showEditDialog() {
        let alertController = UIAlertController(title: "Edit caption",
                                                message: "",
                                                preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Caption"
            textField.text = self.weatherpic?.caption
        }
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: UIAlertActionStyle.cancel,
                                         handler: nil)
        let updateCaptionAction = UIAlertAction(
            title: "Update",
            style: UIAlertActionStyle.default) {
                (action) in
                let captionTextField = alertController.textFields![0]
                self.weatherpic?.caption = captionTextField.text!
                self.updateView()
                
                // Save the context
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(updateCaptionAction)
        present(alertController, animated: true, completion: nil)
    }

    func updateView() {
        captionLabel.text = weatherpic?.caption
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.captionLabel.text = self.weatherpic?.caption
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let imgString = weatherpic?.imageUrl {
            if let imgUrl = NSURL(string: imgString) {
                if let imgData = NSData(contentsOf: imgUrl as URL) {
                    weatherpicImageView.image = UIImage(data: imgData as Data)
                } else {
                    //println("No data for \(imgString)")
                }
            }
        }
    }

}

