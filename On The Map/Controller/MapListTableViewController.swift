//
//  MapListTableViewController.swift
//  On The Map
//
//  Created by Travis Baker on 12/7/18.
//  Copyright © 2018 Travis Baker. All rights reserved.
//

import UIKit

class MapListTableViewController: UITableViewController {
    var studentLocations: [StudentLocation] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return studentLocations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        
        let studentLocation = self.studentLocations[indexPath.item]
        
        cell.textLabel?.text = "\(studentLocation.firstName) \(studentLocation.lastName)"
        cell.detailTextLabel?.text = studentLocation.mediaURL
        cell.imageView?.image = UIImage(named: "mapMarker")

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentLocation = self.studentLocations[indexPath.item]
        
        openUrl(studentLocation.mediaURL)
    }
    
    func openUrl(_ url: String) {
        if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            showErrorAlert(title: "Bad URL", message: "\(url) is not a valid URL. Please try another.")
        }
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

extension MapListTableViewController: StudentLocationListDelegate {
    func receiveNewListOfLocations(newLocations: [StudentLocation]) {
        self.studentLocations = newLocations
        self.tableView.reloadData()
    }
}
