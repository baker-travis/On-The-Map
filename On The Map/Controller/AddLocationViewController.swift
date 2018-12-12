//
//  AddLocationViewController.swift
//  On The Map
//
//  Created by Travis Baker on 12/10/18.
//  Copyright © 2018 Travis Baker. All rights reserved.
//

import UIKit
import CoreLocation

class AddLocationViewController: UIViewController {
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var findLocationButton: RoundButton!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var latitude: Double?
    var longitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func locationTextFieldNextButtonPressed(_ sender: Any) {
        locationTextField.resignFirstResponder()
        websiteTextField.becomeFirstResponder()
    }
    
    @IBAction func websiteTextFieldDoneButtonPressed(_ sender: Any) {
        websiteTextField.resignFirstResponder()
    }
    
    func showErrorState(field: UITextField, error: Bool) {
        if error {
            field.layer.cornerRadius = 8.0;
            field.layer.masksToBounds = true;
            field.layer.borderColor = UIColor.red.cgColor
            field.layer.borderWidth = 1.0;
        } else {
            field.layer.masksToBounds = false
            field.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    func displayError(message: String?, display: Bool = true) {
        errorMessageLabel.text = message
        errorMessageLabel.isHidden = !display
    }
    
    func enableUIElements(_ enabled: Bool = true) {
        self.locationTextField.isEnabled = enabled
        self.websiteTextField.isEnabled = enabled
        self.findLocationButton.isEnabled = enabled
        self.findLocationButton.alpha = enabled ? 1.0 : 0.5
        if enabled {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
    }
    
    @IBAction func findLocationButtonPressed(_ sender: Any) {
        showErrorState(field: locationTextField, error: false)
        showErrorState(field: websiteTextField, error: false)
        displayError(message: nil, display: false)
        guard let geocodeText = self.locationTextField.text, geocodeText != "" else {
            showErrorState(field: locationTextField, error: true)
            displayError(message: "Please enter a location.")
            return
        }
        
        // If website has a non-empty value, we need to check if it's a valid url
        if let website = websiteTextField.text, website != "" {
            guard let url = URL(string: website), let scheme = url.scheme, scheme != "" else {
                showErrorState(field: websiteTextField, error: true)
                displayError(message: "\(website) cannot be reached. Please choose a different url.")
                return
            }
        }
        
        enableUIElements(false)
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(geocodeText) { (placemarks, error) in
            self.enableUIElements()
            if let error = error {
                print(error)
                self.displayError(message: "Unable to geocode the location. Please try another.")
                return
            }
            
            if let placemark = placemarks?[0], let location = placemark.location {
                self.latitude = location.coordinate.latitude
                self.longitude = location.coordinate.longitude
                self.performSegue(withIdentifier: "addLocationToConfirmation", sender: self)
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let destination = segue.destination as? AddLocationConfirmationViewController {
            let newLocation = StudentLocation(firstName: UdacityAPI.userInfo!.firstName, lastName: UdacityAPI.userInfo!.lastName, latitude: self.latitude!, longitude: self.longitude!, mapString: self.locationTextField.text!, mediaURL: self.websiteTextField.text ?? "", uniqueKey: UdacityAPI.auth!.account.key)
            destination.studentLocation = newLocation
        }
    }
 

}
