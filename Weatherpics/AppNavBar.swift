//
//  AppNavBar.swift
//  Password Keeper
//
//  Created by David Fisher on 4/11/18.
//  Copyright © 2018 David Fisher. All rights reserved.
//
import UIKit
import Material

class AppNavBar: ToolbarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepare()
        prepareNavigationBarView()
    }
    
    override func prepare() {
        super.prepare()
        view.backgroundColor = .black
    }
    
    /// Prepares the toolbar.
    private func prepareNavigationBarView() {
        // Title label.
        toolbar.titleLabel.text = " Password Keeper"
        toolbar.titleLabel.textAlignment = .left
        toolbar.titleLabel.textColor = .white
        toolbar.titleLabel.font = RobotoFont.regular
        toolbar.backgroundColor = .blue
        
        // Logout Button
        let image = UIImage(named: "logout")
        let logoutButton: FlatButton = FlatButton()
        logoutButton.setImage(image, for: .normal)
        logoutButton.setImage(image, for: .highlighted)
        logoutButton.addTarget(appDelegate,
                               action: #selector(AppDelegate.handleLogout),
                               for: .touchUpInside)
        toolbar.rightViews = [logoutButton]
    }
}
