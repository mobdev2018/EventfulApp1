//
//  SettingsViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 8/4/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import FirebaseAuth


class SettingsViewController: UITableViewController {
    var authHandle: AuthStateDidChangeListenerHandle?
    let cellID = "cellID"
    let settingsOptionsTwoDimArray = [
    ["Logout"]
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        navigationItem.title = "Settings"
        self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(GoBack))
        self.navigationItem.leftBarButtonItem = backButton
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        authHandle = AuthService.authListener(viewController: self)
    }
    deinit {
        AuthService.removeAuthListener(authHandle: authHandle)
    }
    
 
    //will log the user out
    @objc func handleLogout(){
        print("Logout button pressed")
      AuthService.presentLogOut(viewController: self)
        
    }
    //will dismiss the screen
    @objc func GoBack(){
        print("BACK TAPPED")
        self.dismiss(animated: true, completion: nil)
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "   Support"
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        return label
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return settingsOptionsTwoDimArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsOptionsTwoDimArray[section].count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let currentSetting = settingsOptionsTwoDimArray[indexPath.section][indexPath.row]
        cell.textLabel?.text = currentSetting
        cell.textLabel?.textAlignment = .justified
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if [indexPath.section][indexPath.row] == [0][0]{
            print("Logout Clicked")
            self.handleLogout()
        }
    }


}
