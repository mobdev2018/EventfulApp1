//
//  SignUpViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 7/25/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import Foundation
import SVProgressHUD
import SwiftLocation
import CoreLocation
import TextFieldEffects
import Firebase


class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    
    var selectedUserGender: String = ""
    // creates a signup UILabel
    var userLocation:String?
    
    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "addPic").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        return button
    }()
    
    func handlePlusPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage =
            info["UIImagePickerControllerOriginalImage"] as? UIImage {
            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width/2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.black.cgColor
        plusPhotoButton.layer.borderWidth = 3
        
        dismiss(animated: true, completion: nil)
    }
    
//    let signUp:UILabel = {
//        let signUpLabel = UILabel()
//        let myString = "Sign Up"
//        let myAttribute = [NSFontAttributeName:UIFont(name: "Times New Roman", size: 20)!]
//        let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
//        signUpLabel.attributedText = myAttrString
//        
//        return signUpLabel
//    }()
//    
    // creates a name UITextField to hold the name

    let nameTextField : HoshiTextField = {
       let nameText = HoshiTextField()
        nameText.placeholderColor = .lightGray
        nameText.placeholder = "Username"
        nameText.layer.borderColor = UIColor.lightGray.cgColor
        nameText.layer.borderWidth = 0
        nameText.borderStyle = .none
        nameText.borderActiveColor = UIColor.black
        return nameText
    }()

    // creates a email UITextField to hold the email
    let emailTextField : HoshiTextField = {
        let emaiilText = HoshiTextField()
        emaiilText.placeholderColor = .lightGray
        emaiilText.placeholder = "Email"
        emaiilText.layer.borderColor = UIColor.lightGray.cgColor
        emaiilText.layer.borderWidth = 0
        emaiilText.borderStyle = .none
        emaiilText.borderActiveColor = UIColor.black
        return emaiilText
    }()

    //creates a password UItextield
    let passwordTextField : HoshiTextField = {
        let passwordText = HoshiTextField()
        passwordText.placeholderColor = .lightGray
        passwordText.placeholder = "Password"
        passwordText.layer.borderColor = UIColor.lightGray.cgColor
        passwordText.layer.borderWidth = 0
        passwordText.isSecureTextEntry = true
        passwordText.borderStyle = .none
        passwordText.borderActiveColor = UIColor.black
        return passwordText
    }()

    //creates a confirm password UItextfield
    let confirmPasswordTextField : HoshiTextField = {
        let confirmPasswordText = HoshiTextField()
        confirmPasswordText.placeholderColor = .lightGray
        confirmPasswordText.placeholder = "Confirm Password"
        confirmPasswordText.layer.borderColor = UIColor.lightGray.cgColor
        confirmPasswordText.layer.borderWidth = 0
        confirmPasswordText.isSecureTextEntry = true
        confirmPasswordText.borderStyle = .none
        confirmPasswordText.borderActiveColor = UIColor.black
        return confirmPasswordText
    }()
    
    // creates a UIButton
    
    let signupButton: UIButton  = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.setTitle("SIGN UP", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    // will handle the  sign up of a user
    func handleSignUp(){
            // first we cant to take sure that all of the fields are filled
        let bio: String = ""
        
        let profilePic: String = ""
            guard let username = self.nameTextField.text,
                let confirmPassword = self.confirmPasswordTextField.text,
                let email = self.emailTextField.text,
                let password = self.passwordTextField.text,
                !username.isEmpty,
                !email.isEmpty,
                !password.isEmpty,
            !confirmPassword.isEmpty
                else {
                    
                    print("Required fields are not all filled!")
                    return
            }
            
            let gender = self.selectedUserGender;
            // will make sure user is validated before it even tries to create user
            
            if self.validateEmail(enteredEmail:email) != true{
                let alertController = UIAlertController(title: "Error", message: "Please Enter A Valid Email", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                present(alertController, animated: true, completion: nil)

            }
        // will make sure the password and confirm password textfields have the same value if so it will print an error
        if passwordTextField.text != confirmPasswordTextField.text {
            let alertController = UIAlertController(title: "Error", message: "Passwords Don't Match", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        }
        
            // will authenticate a user into the authentication services with an email and passowrd
            AuthService.createUser(controller: self, email: email, password: password) { (authUser) in
                guard let firUser = authUser else {
                    return
                }
                
                // wlll add the user to the firebase database
                UserService.create(firUser, username: username, gender: gender , profilePic: profilePic , bio: bio, location: self.userLocation!) { (user) in
                    guard let user = user else {
                         print("User successfully loaded into firebase db")
                        return
                    }
                    // will set the current user for userdefaults to work
                    User.setCurrent(user, writeToUserDefaults: true)
                    // self.delegate?.finishSigningUp()

                    self.finishSigningUp()
                    
              
                }
            }
        }
    
    
    func finishSigningUp() {
        print("Finish signing up from signup view controller")
        print("Attempting to return to root view controller")
        let homeController = HomeViewController()
        //should change the root view controller to the homecontroller when done signing up
        self.view.window?.rootViewController = homeController
        self.view.window?.makeKeyAndVisible()
    }
    
    
// will validate email entry so user can not enter false text
    
    func validateEmail(enteredEmail:String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)
    }
    //will create a label so users know to select gender when creating account
    let genderLabel: UILabel = {
       let gender = UILabel()
        let myString = "Gender"
        let myAttribute = [NSFontAttributeName:UIFont(name: "Times New Roman", size: 15)!]
        let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
        gender.attributedText = myAttrString
        return gender
    }()
    //will create a segmented control button to add gender
    lazy var genderSelector: UISegmentedControl = {
        let genderSelect = UISegmentedControl(items: ["Male", "Female"])
        genderSelect.tintColor = UIColor.black
        genderSelect.addTarget(self, action: #selector(handleGenderSelection), for: .valueChanged)
        
        return genderSelect
    }()
    
    func handleGenderSelection()  {
       //print(genderSelector.selectedSegmentIndex)
        if (genderSelector.selectedSegmentIndex == 0) {
            selectedUserGender = "Male"
        }else if(genderSelector.selectedSegmentIndex == 1 ){
            selectedUserGender = "Female"
        }
       // print(selectedUserGender)
    }
    
  // will create a cancel button so users can go back to login screen if they actually want to log in
   // Buton setup as well as cancel will be in this code block
    let cancelButton : UIButton = {
       let cancel = UIButton()
        cancel.setTitle("Cancel", for: .normal)
        cancel.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        cancel.setTitleColor(.black, for: .normal)
        cancel.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return cancel
    }()
    
    func handleCancel(){
        self.dismiss(animated: true, completion: nil)
    }
    
    /////////////////////////////////////////////
    
    
    
    
    // Will move the UI Up on login Screen when keyboard appears
    
    fileprivate func  observeKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
    }
    // will properly show keyboard
    func keyboardWillShow(sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            UIView.animate(withDuration: 0.2, animations: {
                self.view.frame.origin.y = -keyboardHeight
            })
        }
    }
    
    // will properly hide keyboard
    func keyboardWillHide(sender: NSNotification) {
        UIView.animate(withDuration: 0.2, animations: {
            self.view.frame.origin.y = 0
        })
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r: 255, g: 255 , b: 255)
        observeKeyboardNotifications()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)

        /////////////////////////  Where all the subviews will be added
        
        view.addSubview(plusPhotoButton)
        view.addSubview(cancelButton)
        ////////////////////////////////////////////////////////////////////
        
        
        /////////////////////////  Where all the constraints will be added
        // constraints for the sign up label/title
             plusPhotoButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 50, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        _ = cancelButton.anchor(top: view.centerYAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: -300, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)

        ////////////////////////////////////////////////////////////////////

        
        createSignUpScreen()

        
        // Do any additional setup after loading the view.
    }
    
    var stackView: UIStackView?
    
    func  createSignUpScreen(){
        stackView = UIStackView(arrangedSubviews: [ nameTextField, emailTextField,passwordTextField,confirmPasswordTextField, signupButton])
        view.addSubview(stackView!)
        stackView?.distribution = .fillEqually
        stackView?.axis = .vertical
        stackView?.spacing = 15.0
        stackView?.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 350)
        
        
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let alertController = UIAlertController(title: "Enable access to your location \n Discover events near you", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Deny", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        let locationAction = UIAlertAction(title: "Allow", style: .default){_ in
            Location.getLocation(accuracy: .city, frequency: .oneShot, success: { (_, location) -> (Void) in
                print("Latitide: \(location.coordinate.latitude)")
                print("Longitude: \(location.coordinate.longitude)")
                let roughLatitude = location.coordinate.latitude.truncator(places: 1)
                let roughLongitude = location.coordinate.longitude.truncator(places: 1)
                let locationKey = String(format: "%.1f,%.1f", roughLatitude, roughLongitude).replacingOccurrences(of: ".", with: "%2e")
                print("LocationKey: \(locationKey)")
                
                let roughLocationFromKey = locationKey.replacingOccurrences(of: "%2e", with: ".").components(separatedBy: ",").map { Double($0)}
                
                print(roughLocationFromKey)
                
                let searchBoxes = [
                    String(format: "%.1f,%.1f", roughLatitude + 0.1, roughLongitude - 0.1).replacingOccurrences(of: ".", with: "%2e"),
                    String(format: "%.1f,%.1f", roughLatitude + 0.1 , roughLongitude).replacingOccurrences(of: ".", with: "%2e"),
                    String(format: "%.1f,%.1f", roughLatitude + 0.1, roughLongitude + 0.1).replacingOccurrences(of: ".", with: "%2e"),
                    String(format: "%.1f,%.1f", roughLatitude, roughLongitude - 0.1).replacingOccurrences(of: ".", with: "%2e"),
                    String(format: "%.1f,%.1f", roughLatitude, roughLongitude).replacingOccurrences(of: ".", with: "%2e"),
                    String(format: "%.1f,%.1f", roughLatitude, roughLongitude + 0.1).replacingOccurrences(of: ".", with: "%2e"),
                    String(format: "%.1f,%.1f", roughLatitude - 0.1, roughLongitude - 0.1).replacingOccurrences(of: ".", with: "%2e"),
                    String(format: "%.1f,%.1f", roughLatitude - 0.1, roughLongitude).replacingOccurrences(of: ".", with: "%2e"),
                    String(format: "%.1f,%.1f", roughLatitude - 0.1, roughLongitude + 0.1).replacingOccurrences(of: ".", with: "%2e")
                ]
                
                print(searchBoxes)
                
                let location = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                print(location)
                Location.getPlacemark(forLocation: location, success: { placemarks -> (Void) in
                    //print(placemarks)
                    guard let currentCityLoc = placemarks.first?.locality else { return }
                    self.userLocation = locationKey
                    guard case self.userLocation! = locationKey else {
                        return
                    }
                    // print(placemarks.first?.locality)
                }, failure: { error -> (Void) in
                    print("Cannot retrive placemark due to an error \(error)")
                })
            }, error: { (request, last, error) -> (Void) in
                request.cancel()
                print("Location monitoring failed due to an error \(error)")
            })
        }
        alertController.addAction(locationAction)
        
        
        self.present(alertController, animated: true)
    }
   

}




