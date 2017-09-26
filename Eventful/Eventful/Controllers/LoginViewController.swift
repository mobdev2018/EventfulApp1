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



class LoginViewController: UIViewController , LoginViewControllerDelegate {
    //Login Controller Instance
    
   // var loginController: LoginViewController?
    weak var delegate : LoginViewControllerDelegate?
    
    
    
    // each of these creates a compnenet of the screen
    // creates a UILabel
    let nameOfAppLabel : UILabel =  {
        let nameLabel = UILabel()
        nameLabel.textColor = .white
        let myString = "[Name of App]"
        let myAttribute = [NSFontAttributeName:UIFont(name: "Times New Roman", size: 7.3)!]
        let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
        nameLabel.attributedText = myAttrString
        return nameLabel
    }()
    // creates a UILabel
    
    
    let welcomeBackLabel : UILabel =  {
        let welcomeLabel = UILabel()
        welcomeLabel.textColor = .white
        let myString = "Welcome Back!"
        let myAttribute = [NSFontAttributeName:UIFont(name: "Times New Roman", size: 20.7)!]
        let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
        welcomeLabel.attributedText = myAttrString
        return welcomeLabel
    }()
    
    // creates a UILabel
    
    
    let goalLabel : UILabel =  {
        let primaryGoalLabel = UILabel()
        primaryGoalLabel.textColor = .white
        let myString = "Use our application to find events"
        let myAttribute = [NSFontAttributeName:UIFont(name: "Times New Roman", size: 13)!]
        let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
        primaryGoalLabel.attributedText = myAttrString
        return primaryGoalLabel
    }()
    
    // creates a UITextField
    
    let emailTextField : HoshiTextField = {
        let textField = HoshiTextField()
        textField.placeholderColor = .white
        textField.placeholder = "Email"
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 0
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.borderStyle = .none
        textField.borderInactiveColor = .white
        textField.borderActiveColor = UIColor.white
        textField.textColor = .white
        return textField
    }()

    // creates a UITextField
    let passwordTextField : HoshiTextField = {
        let textField = HoshiTextField()
        textField.placeholderColor = .white
        textField.placeholder = "Password"
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 0
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.borderStyle = .none
        textField.borderInactiveColor = .white
        textField.borderActiveColor = UIColor.white
        textField.textColor = .white
        return textField
    }()
    // creates a UIButton and transitions to a different screen after button is selected
    
    lazy var loginButton: UIButton  = {
        let button = UIButton(type: .system)
        button.setTitle("LOGIN", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 23.5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.backgroundColor = UIColor.logoColor
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
        signUp.textColor = .white
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
        signUpButton.setTitleColor(UIColor.logoColor, for: .normal)
        signUpButton.addTarget(self, action: #selector(handleSignUpTransition), for: .touchUpInside)
        return signUpButton
    }()
    
    
    let bgGradientLayer : CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor(hex: "F77832").cgColor, UIColor(hex:"811FC6").cgColor]
        layer.locations = [0.5]
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        return layer
    }()
    
    override func viewDidLoad() {
        // Every view that I add is from the top down imagine a chandeler that you are just hanging things from
        super.viewDidLoad()
        // will add each of the screen elements to the current view
        
        self.bgGradientLayer.frame = self.view.layer.bounds
        self.view.layer.addSublayer(self.bgGradientLayer)
        
        self.view.addSubview(nameOfAppLabel)
        self.view.addSubview(welcomeBackLabel)
        self.view.addSubview(goalLabel)
        //////////////////////////////////////////////////////////////////////
        
        // All Constraints for Elements in Screen
        // constraints for the nameOfAppLabel
        _ = nameOfAppLabel.anchor(top: self.view.centerYAnchor, left: nil, bottom: nil, right: nil, paddingTop: -215.0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 49.7, height: 9.7)
        nameOfAppLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        //constrints for the welcome back label
        _ = welcomeBackLabel.anchor(top: nameOfAppLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 15.7, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 12.7)
        
        welcomeBackLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        //constrints for the goal label
        _ = goalLabel.anchor(top: welcomeBackLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 180, height: 14)
        
        goalLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true

        
        self.view.backgroundColor = UIColor(r: 255, g: 255 , b: 255)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        self.view.addGestureRecognizer(tap)
        setupLoginScreen()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.observeKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //self.removeObserveKeyboardNotifications()
    }
    
    var stackView: UIStackView?
    fileprivate func setupLoginScreen(){
        stackView = UIStackView(arrangedSubviews: [ emailTextField, passwordTextField,loginButton])
        self.view.addSubview(stackView!)
        stackView?.distribution = .fillEqually
        stackView?.axis = .vertical
        stackView?.spacing = 5.0
        stackView?.anchor(top: goalLabel.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 152)
        self.addBottomMostItems()
    }
    
    fileprivate func addBottomMostItems() {
        let bottomView = UIView()
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(bottomView)
        NSLayoutConstraint.activateViewConstraints(bottomView, inSuperView: self.view, withLeading: 0.0, trailing: 0.0, top: nil, bottom: nil, width: nil, height: 20.0)
        _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: bottomView, secondView: self.bottomLayoutGuide, andSeparation: 10.0)
        
        let pseudoView1 = UIView()
        pseudoView1.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addSubview(pseudoView1)
        NSLayoutConstraint.activateViewConstraints(pseudoView1, inSuperView: bottomView, withLeading: 0.0, trailing: nil, top: 0.0, bottom: 0.0)
        
        self.signUpLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addSubview(self.signUpLabel)
        NSLayoutConstraint.activateViewConstraints(self.signUpLabel, inSuperView: bottomView, withLeading: nil, trailing: nil, top: 0.0, bottom: 0.0)
        _ = NSLayoutConstraint.activateHorizontalSpacingConstraint(withFirstView: pseudoView1, secondView: self.signUpLabel, andSeparation: 0.0)
        _ = NSLayoutConstraint.activateWidthConstraint(view: self.signUpLabel, withWidth: 1.0, andRelation: .greaterThanOrEqual)
        
        self.signUpButton.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addSubview(self.signUpButton)
        NSLayoutConstraint.activateViewConstraints(self.signUpButton, inSuperView: bottomView, withLeading: nil, trailing: nil, top: 0.0, bottom: 0.0)
        _ = NSLayoutConstraint.activateHorizontalSpacingConstraint(withFirstView: self.signUpLabel, secondView: self.signUpButton, andSeparation: 5.0)
        _ = NSLayoutConstraint.activateWidthConstraint(view: self.signUpButton, withWidth: 1.0, andRelation: .greaterThanOrEqual)
        
        let pseudoView2 = UIView()
        pseudoView2.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addSubview(pseudoView2)
        NSLayoutConstraint.activateViewConstraints(pseudoView2, inSuperView: bottomView, withLeading: nil, trailing: 0.0, top: 0.0, bottom: 0.0)
        _ = NSLayoutConstraint.activateHorizontalSpacingConstraint(withFirstView: self.signUpButton, secondView: pseudoView2, andSeparation: 0.0)
        _ = NSLayoutConstraint.activateEqualWidthConstraint(withView: pseudoView2, referenceView: pseudoView1)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    
    
    // will open a new ViewController When login button is selected
    func handleSignUpTransition(){
        let signUpTransition = SignUpViewController()
        present(signUpTransition, animated: true, completion: nil)
    }
    
    // Will move the UI Up on login Screen when keyboard appears
    
    fileprivate func  observeKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    fileprivate func  removeObserveKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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


