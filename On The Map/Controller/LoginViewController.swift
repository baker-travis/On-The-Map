//
//  ViewController.swift
//  On The Map
//
//  Created by Travis Baker on 12/7/18.
//  Copyright © 2018 Travis Baker. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var emailAddressField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func showErrorState(button: UITextField, error: Bool) {
        if error {
            button.layer.cornerRadius = 8.0;
            button.layer.masksToBounds = true;
            button.layer.borderColor = UIColor.red.cgColor
            button.layer.borderWidth = 1.0;
        } else {
            button.layer.masksToBounds = false
            button.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    func validateTextFields() -> Bool {
        var valid = true
        var errorMessage = ""
        
        if emailAddressField.text == nil || !validateEmail(email: emailAddressField.text!) {
            valid = false
            errorMessage = "Username is not a valid email address."
            showErrorState(button: emailAddressField, error: true)
        } else {
            showErrorState(button: emailAddressField, error: false)
        }
        
        if passwordField.text == nil || passwordField.text == "" {
            if (valid) {
                valid = false
                errorMessage = "Please enter a password"
            }
            showErrorState(button: passwordField, error: true)
        } else {
            showErrorState(button: passwordField, error: false)
        }
        
        if (!valid) {
            errorMessageLabel.text = errorMessage
            errorMessageLabel.isHidden = false
        }
        
        return valid
    }
    
    func validateEmail(email: String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: email)
    }
    
    func enableUIElements(_ shouldEnable: Bool = true) {
        passwordField.isEnabled = shouldEnable
        emailAddressField.isEnabled = shouldEnable
        loginButton.isEnabled = shouldEnable
        loginButton.alpha = shouldEnable ? 1.0 : 0.5
    }
    
    @IBAction func emailButtonNextButtonPressed(_ sender: Any) {
        passwordField.becomeFirstResponder()
    }
    
    @IBAction func passwordButtonGoButtonPressed(_ sender: Any) {
        passwordField.resignFirstResponder()
        login()
    }
    
    @IBAction func signInButtonPressed(_ sender: Any) {
        passwordField.resignFirstResponder()
        login()
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        if let url = URL(string: "https://www.udacity.com/account/auth#!/signup") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func login() {
        self.errorMessageLabel.isHidden = true
        guard let username = emailAddressField.text, let password = passwordField.text, validateTextFields() else {
            return
        }
        
        self.activityIndicator.startAnimating()
        enableUIElements(false)
        UdacityAPI.logIn(username: username, password: password, handler: loginCallback(_:error:))
    }
    
    func loginCallback(_ success: Bool, error: Error?) {
        self.activityIndicator.stopAnimating()
        enableUIElements()
        if error != nil {
            if let errorDesc = (error as? LocalizedError)?.errorDescription {
                self.errorMessageLabel.text = errorDesc
            } else {
                self.errorMessageLabel.text = "Unknown error occurred. Please try again later."
            }
            self.errorMessageLabel.isHidden = false
            return
        }
        
        if (success) {
            performSegue(withIdentifier: "loginToMainSegue", sender: self)
        }
    }
}

