//
//  SettingsViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 8/4/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import FirebaseAuth


class SettingsViewController: UIViewController {
    var authHandle: AuthStateDidChangeListenerHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        navigationItem.title = "Settings"
        view.addSubview(logoutImage)
        view.addSubview(logoutButton)
        view.addSubview(backButton)
//        self.navigationItem.hidesBackButton = true
//        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(GoBack))
//        self.navigationItem.leftBarButtonItem = backButton

        authHandle = AuthService.authListener(viewController: self)

        //Constraints
        
        //Constraints for the logout image
                _ = backButton.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        _ = logoutImage.anchor(top: backButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 32, paddingBottom: 0, paddingRight: 0, width: 15, height: 15)
        //Constraints for the logout button
        _ = logoutButton.anchor(top: backButton.bottomAnchor, left: logoutImage.rightAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 70, height: 15)

    }
    
    
    deinit {
        AuthService.removeAuthListener(authHandle: authHandle)
    }
    
    let logoutImage: UIImageView = {
       let currentLogoutImage = UIImageView()
        currentLogoutImage.image = UIImage(named: "icons8-Logout Rounded Up-50")
        currentLogoutImage.clipsToBounds = true
        currentLogoutImage.contentMode = .scaleAspectFill
        currentLogoutImage.layer.masksToBounds = true
        return currentLogoutImage
    }()
    
    let logoutButton : UIButton = {
       let logout = UIButton(type: .system)
        logout.setTitle("Logout", for: .normal)
        logout.setTitleColor(.black, for: .normal)
        logout.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        return logout
    }()
    
    lazy var backButton: UIButton = {
        let backButton = UIButton(type: .system)
        backButton.setImage(#imageLiteral(resourceName: "icons8-Expand Arrow-48").withRenderingMode(.alwaysOriginal), for: .normal)
        backButton.addTarget(self, action: #selector(handleSettingsDismiss), for: .touchUpInside)
        return backButton
    }()
    
    @objc func handleSettingsDismiss(){
        print("Button pressed")
        dismiss(animated: true, completion: nil)
    }

    //will log the user out
    @objc func handleLogout(){
        print("Logout button pressed")
     
      AuthService.presentLogOut(viewController: self)
        
    }
    
    
    func GoBack(){
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
