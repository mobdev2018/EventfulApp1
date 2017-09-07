//
//  LoginViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 7/24/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import Foundation
import SVProgressHUD
import TextFieldEffects

protocol LoginViewControllerDelegate: class {
    func finishLoggingIn()
}



class LoginViewController: UIViewController , LoginViewControllerDelegate{
    //Login Controller Instance
    
   // var loginController: LoginViewController?
    weak var delegate : LoginViewControllerDelegate?
    
    
    
    // each of these creates a compnenet of the screen
    // creates a UILabel
    let nameOfAppLabel : UILabel =  {
        let nameLabel = UILabel()
        let myString = "[Name of App]"
        let myAttribute = [NSFontAttributeName:UIFont(name: "Times New Roman", size: 7.3)!]
        let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
        nameLabel.attributedText = myAttrString
        return nameLabel
    }()
    // creates a UILabel
    
    
    let welcomeBackLabel : UILabel =  {
        let welcomeLabel = UILabel()
        let myString = "Welcome Back!"
        let myAttribute = [NSFontAttributeName:UIFont(name: "Times New Roman", size: 20.7)!]
        let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
        welcomeLabel.attributedText = myAttrString
        return welcomeLabel
    }()
    
    // creates a UILabel
    
    
    let goalLabel : UILabel =  {
        let primaryGoalLabel = UILabel()
        let myString = "Use our application to find events"
        let myAttribute = [NSFontAttributeName:UIFont(name: "Times New Roman", size: 13)!]
        let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
        primaryGoalLabel.attributedText = myAttrString
        return primaryGoalLabel
    }()
    
    // creates a UITextField
    
    let emailTextField : HoshiTextField = {
        let textField = HoshiTextField()
        textField.placeholderColor = .lightGray
        textField.placeholder = "Email"
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 0
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.borderStyle = .none
        textField.borderActiveColor = UIColor.black
        return textField
    }()

    // creates a UITextField
    let passwordTextField : HoshiTextField = {
        let textField = HoshiTextField()
        textField.placeholderColor = .lightGray
        textField.placeholder = "Password"
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 0
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.borderStyle = .none
        textField.borderActiveColor = UIColor.black
        return textField
    }()
    // creates a UIButton and transitions to a different screen after button is selected
    
    lazy var loginButton: UIButton  = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.setTitle("LOGIN", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    func handleLogin(){
        if self.emailTextField.text == "" || self.passwordTextField.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and a a password", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            
        }else{
            SVProgressHUD.show(withStatus: "Logging in...")
            AuthService.signIn(controller: self, email: emailTextField.text!, password: passwordTextField.text!) { (user) in
                guard user != nil else {
                    // look back here
           
                    print("error: FiRuser dees not exist")
                    return
                }
                print("user is signed in")
                UserService.show(forUID: (user?.uid)!) { (user) in
                    if let user = user {
                        User.setCurrent(user, writeToUserDefaults: true)
                        self.finishLoggingIn()
                }
                    else {
                        print("error: User does not exist!")
                        return
                    }
                }
            }
        }

    }
    
    func finishLoggingIn() {
        print("Finish logging in from LoginController")
        let homeController = HomeViewController()
        self.view.window?.rootViewController = homeController
        self.view.window?.makeKeyAndVisible()
       // SVProgressHUD.dismiss()
        //let homeVC = HomeViewController()
        //present(homeVC, animated: true)
        
    }
    
    //creatas a UILabel
    let signUpLabel: UILabel = {
        let signUp = UILabel()
        let myString = "Don't have an account?"
        let myAttribute = [NSFontAttributeName:UIFont(name: "Times New Roman", size: 15)!]
        let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
        signUp.attributedText = myAttrString
        return signUp
        
    }()
    
    //will create the signup button
    let signUpButton: UIButton = {
        let signUpButton = UIButton(type: .system)
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        signUpButton.setTitleColor(.black, for: .normal)
        signUpButton.addTarget(self, action: #selector(handleSignUpTransition), for: .touchUpInside)
        return signUpButton
    }()
    
    override func viewDidLoad() {
        // Every view that I add is from the top down imagine a chandeler that you are just hanging things from
        super.viewDidLoad()
        // will add each of the screen elements to the current view
        view.addSubview(nameOfAppLabel)
        view.addSubview(welcomeBackLabel)
        view.addSubview(goalLabel)
        //////////////////////////////////////////////////////////////////////
        
        // All Constraints for Elements in Screen
        // constraints for the nameOfAppLabel
        _ = nameOfAppLabel.anchor(top: view.centerYAnchor, left: nil, bottom: nil, right: nil, paddingTop: -191.3, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 49.7, height: 9.7)
        nameOfAppLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        //constrints for the welcome back label
        _ = welcomeBackLabel.anchor(top: nameOfAppLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 15.7, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 12.7)
        
        welcomeBackLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //constrints for the goal label
        _ = goalLabel.anchor(top: welcomeBackLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 180, height: 14)
        
        goalLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        
        view.backgroundColor = UIColor(r: 255, g: 255 , b: 255)
        observeKeyboardNotifications()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        setupLoginScreen()
        
    }
    
    var stackView: UIStackView?
    fileprivate func setupLoginScreen(){
         stackView = UIStackView(arrangedSubviews: [ emailTextField, passwordTextField,loginButton])
        view.addSubview(stackView!)
        stackView?.distribution = .fillEqually
        stackView?.axis = .vertical
        stackView?.spacing = 5.0
        stackView?.anchor(top: goalLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 150)
        view.addSubview(signUpLabel)
        _ = signUpLabel.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 75, paddingBottom: 10, paddingRight: 0, width: 0, height: 20)
        view.addSubview(signUpButton)
        _ = signUpButton.anchor(top: nil, left: signUpLabel.rightAnchor, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 5, paddingBottom: 10, paddingRight: 0, width: 0, height: 20)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    // will open a new ViewController When login button is selected
    func handleSignUpTransition(){
        let signUpTransition = SignUpViewController()
        present(signUpTransition, animated: true, completion: nil)
    }
    
    // Will move the UI Up on login Screen when keyboard appears
    
    fileprivate func  observeKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
    }
    
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
    
}


extension UIColor{
    convenience init(r: CGFloat, g: CGFloat, b:CGFloat){
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}


class LeftPaddedTextField: UITextField {
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 12, y: bounds.origin.y, width: bounds.width + 10, height: bounds.height)
    }
    
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 12, y: bounds.origin.y, width: bounds.width + 10, height: bounds.height)
    }
}


