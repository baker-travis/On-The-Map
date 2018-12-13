//
//  MapPointsViewController.swift
//  On The Map
//
//  Created by Travis Baker on 12/7/18.
//  Copyright © 2018 Travis Baker. All rights reserved.
//

import UIKit
import MapKit

class MapPointsViewController: UIViewController {
    var annotations: [MKAnnotation] = []
    var calloutGestureRecognizer: UITapGestureRecognizer?
    @IBOutlet weak var mapView: MKMapView!
    let notificationCenter = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.mapView.delegate = self
        
        notificationCenter.addObserver(self, selector: #selector(updateStudentLocations), name: .studentLocationsListUpdated, object: nil)
    }
    
    func updateMapAnnotations() {
        self.mapView.removeAnnotations(annotations)
        annotations = []
        for location in StudentLocationsModel.studentLocations {
            annotations.append(StudentLocationAnnotation(location: location))
        }
        mapView.addAnnotations(annotations)
    }
    
    func openUrl(_ url: String) {
        if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            showErrorAlert(title: "Bad URL", message: "\(url) is not a valid url. Please try another.")
        }
    }
    
    @objc func handleAnnotationCalloutTap(_ sender: UITapGestureRecognizer) {
        if let view = sender.view as? MKPinAnnotationView, let annotation = view.annotation as? StudentLocationAnnotation {
            openUrl(annotation.studentLocation.mediaURL)
        }
    }
    
    @objc func updateStudentLocations() {
        updateMapAnnotations()
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

extension MapPointsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? StudentLocationAnnotation else { return nil }
        
        let identifier = "marker"
        var view: MKPinAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleAnnotationCalloutTap(_:)))
        view.addGestureRecognizer(gesture)
        calloutGestureRecognizer = gesture
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let calloutGestureRecognizer = calloutGestureRecognizer {
            view.removeGestureRecognizer(calloutGestureRecognizer)
        }
    }
}
