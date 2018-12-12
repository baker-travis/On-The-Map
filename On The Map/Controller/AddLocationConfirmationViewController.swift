//
//  AddLocationConfirmationViewController.swift
//  On The Map
//
//  Created by Travis Baker on 12/10/18.
//  Copyright © 2018 Travis Baker. All rights reserved.
//

import UIKit
import MapKit



class AddLocationConfirmationViewController: UIViewController {
    var studentLocation: StudentLocation?
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var finishButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        let annotation = StudentLocationTitleAnnotation(location: studentLocation!)
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: false)
        let mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: studentLocation!.latitude, longitude: studentLocation!.longitude!), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        mapView.setRegion(mapRegion, animated: false)
        // Do any additional setup after loading the view.
    }
    
    func enableButton(_ enabled: Bool = true) {
        finishButton.alpha = enabled ? 1.0 : 0.5
        finishButton.isEnabled = enabled
    }
    
    @IBAction func finishButtonPressed(_ sender: Any) {
        enableButton(false)
        if let objectId = OnTheMapAPI.objectId {
            OnTheMapAPI.updateStudentLocation(studentLocation!, objectId: objectId) { (success, error) in
                if success {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.showErrorAlert(title: "Location Update Failure", message: "We were unable to update your location. Please try again later.")
                }
                self.enableButton()
            }
        } else {
            OnTheMapAPI.postNewStudentLocation(studentLocation!) { (success, error) in
                if success {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.showErrorAlert(title: "New Location Posting Failure", message: "We were unable to post your new location. Please try again later.")
                }
                self.enableButton()
            }
        }
    }
}

extension AddLocationConfirmationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? StudentLocationTitleAnnotation else { return nil }
        let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "only1")
        view.canShowCallout = true
        
        return view
    }
}
