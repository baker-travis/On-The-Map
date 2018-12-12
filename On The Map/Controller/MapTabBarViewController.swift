//
//  MapTabBarViewController.swift
//  On The Map
//
//  Created by Travis Baker on 12/7/18.
//  Copyright © 2018 Travis Baker. All rights reserved.
//

import UIKit

protocol StudentLocationListDelegate {
    func receiveNewListOfLocations(newLocations: [StudentLocation])
}

class MapTabBarViewController: UITabBarController {
    @IBOutlet var refreshButton: UIBarButtonItem!
    @IBOutlet weak var addLocationButton: UIBarButtonItem!
    @IBOutlet var logoutButton: UIBarButtonItem!
    
    let refreshActivityIndicator = UIActivityIndicatorView(style: .gray)
    var refreshActivityIndicatorButton: UIBarButtonItem {
        return UIBarButtonItem(customView: refreshActivityIndicator)
    }
    
    let logoutActivityIndicator = UIActivityIndicatorView(style: .gray)
    var logoutActivityIndicatorButton: UIBarButtonItem {
        return UIBarButtonItem(customView: logoutActivityIndicator)
    }
    
    let getUserDataDispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStudentInfo()
        getStudentLocation()
        // Enable the add location button after we've received a response from student info and student location
        addLocationButton.isEnabled = false
        getUserDataDispatchGroup.notify(queue: .main, execute: self.enableAddButton)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Every time the view reappears, reload the student locations
        fetchStudentLocations()
    }
    
    func enableAddButton() {
        if let _ = UdacityAPI.userInfo {
            // at this point, all requests have been made that are necessary to post or put a student location
            self.addLocationButton.isEnabled = true
        }
    }
    
    func getStudentInfo() {
        getUserDataDispatchGroup.enter()
        UdacityAPI.getUserInfo { (info, error) in
            if error != nil {
                self.showErrorAlert(title: "Unable to Get Your Information", message: "Thank you for logging in. Unfortunately we are unable to access your information at this time. You can still browse other pins, but will be unable to post a new location. Please try again later.")
            }
            self.getUserDataDispatchGroup.leave()
        }
    }
    
    func getStudentLocation() {
        getUserDataDispatchGroup.enter()
        OnTheMapAPI.getStudentLocation(uniqueKey: UdacityAPI.auth!.account.key) { (location, error) in
            if let error = error {
                if case OnTheMapAPI.Errors.queryReturnedNoResults = error {
                    // This case is fine
                } else {
                    self.showErrorAlert(title: "Unable to Retrieve Your Last Location", message: "We were not able to get your last location you recorded with us from our server. You can still browse the pins on the map, but you will be unable to add any new locations at this time. Please try again later.")
                }
            }
            self.getUserDataDispatchGroup.leave()
        }
    }
    
    func handleUpdatedListOfStudents(students: [StudentLocation], error: Error?) {
        hideActivityIndicator()
        if error != nil {
            showErrorAlert(title: "Error Retrieving User Locations", message: "There may be a problem with your network or our server. Please try again later.")
            print(error!)
            return
        }
        
        if let viewControllers = self.viewControllers {
            for controller in viewControllers {
                if let delegate = controller as? StudentLocationListDelegate {
                    delegate.receiveNewListOfLocations(newLocations: students)
                }
            }
        }
    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        self.navigationItem.setLeftBarButton(logoutActivityIndicatorButton, animated: true)
        logoutActivityIndicator.startAnimating()
        UdacityAPI.logOut { (success, error) in
            self.navigationItem.setLeftBarButton(self.logoutButton, animated: true)
            self.logoutActivityIndicator.stopAnimating()
            if error != nil {
                print(error!)
            }
            if (success) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        fetchStudentLocations()
    }
    
    func fetchStudentLocations() {
        showActivityIndicator()
        OnTheMapAPI.getListOfStudentLocations(options: [.order(.updatedAt, ascending: false)], completionHandler: handleUpdatedListOfStudents(students:error:))
    }
    
    func showActivityIndicator() {
        self.navigationItem.setRightBarButtonItems([addLocationButton, refreshActivityIndicatorButton], animated: true)
        refreshActivityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        refreshActivityIndicator.stopAnimating()
        self.navigationItem.setRightBarButtonItems([addLocationButton, refreshButton], animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
