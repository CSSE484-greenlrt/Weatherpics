//
//  PasswordCell.swift
//  Password Keeper
//
//  Created by David Fisher on 4/11/18.
//  Copyright © 2018 David Fisher. All rights reserved.
//
import UIKit
import FoldingCell
import Material

class PasswordCell: FoldingCell {
    
    var cornerRadius: CGFloat = 8
    
    typealias ButtonHandler = (Password) -> Void
    
    var editPasswordHandler: ButtonHandler?
    var deletePasswordHandler: ButtonHandler?
    
    @IBOutlet var lockImageViews: [UIImageView]!
    @IBOutlet weak var themeColorView: UIView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet var serviceLabels: [UILabel]!
    
    @IBOutlet weak var buttonContainer: UIView!
    @IBOutlet weak var editButton: FlatButton!
    @IBOutlet weak var deleteButton: FlatButton!
    
    var password : Password?
    
    
    @IBAction func onEditPassword(_ sender: Any) {
        editPasswordHandler?(password!)
    }
    
    @IBAction func onDeletePassword(_ sender: Any) {
        deletePasswordHandler?(password!)
    }
    
    override func awakeFromNib() {
        for view in [foregroundView, containerView] {
            view?.layer.cornerRadius = cornerRadius
            view?.layer.masksToBounds = true
        }
        
        for serviceName in serviceLabels {
            serviceName.font = RobotoFont.bold(with: 24)
        }
        
        let randomColor = ["cyan", "red", "green", "orange", "pink", "purple"].sample()
        
        var themeColor : UIColor = Color.grey.lighten3
        switch (randomColor) {
        case "cyan": themeColor = Color.cyan.lighten3
        case "red": themeColor = Color.red.lighten3
        case "green": themeColor = Color.green.lighten3
        case "orange": themeColor = Color.orange.lighten3
        case "pink": themeColor = Color.pink.lighten3
        case "purple": themeColor = Color.purple.lighten3
        default: break
        }
        backViewColor = themeColor
        
        switch (randomColor) {
        case "cyan": themeColor = Color.cyan.base
        case "red": themeColor = Color.red.base
        case "green": themeColor = Color.green.base
        case "orange": themeColor = Color.orange.base
        case "pink": themeColor = Color.pink.base
        case "purple": themeColor = Color.purple.base
        default: break
        }
        themeColorView.backgroundColor = themeColor
        for imageView in lockImageViews {
            imageView.image = UIImage(named: "ic_lock_\(randomColor)")
        }
        editButton.setTitle("Edit", for: .normal)
        deleteButton.setTitle("Delete", for: .normal)
        buttonContainer.tr_addUpperBorder()
        super.awakeFromNib()
    }
    
    
    func bindPassword(_ password : Password) {
        self.password = password
        for serviceName in serviceLabels {
            serviceName.text = password.service
        }
        self.usernameLabel.text = password.username
        self.passwordLabel.text = password.password
    }
    
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
        let durations = [0.26, 0.2, 0.2, 0.2, 0.2]
        return durations[itemIndex]
    }
}

extension UIView {
    func tr_addUpperBorder() {
        let upperBorder = CALayer(layer: layer)
        upperBorder.backgroundColor = Color.grey.lighten4.cgColor
        upperBorder.frame =  CGRect(x: 0, y: 0, width: self.frame.width, height: 1.0)
        layer.addSublayer(upperBorder)
    }
}

extension Array {
    func sample() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}
