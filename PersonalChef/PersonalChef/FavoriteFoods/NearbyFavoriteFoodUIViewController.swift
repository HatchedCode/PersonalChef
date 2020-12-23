//
//  NearbyFavoriteFoodUIViewController.swift
//  PersonalChef
//
//  Created by Osman Bakari on 5/6/20.
//  Copyright © 2020 Osman Bakari. All rights reserved.
//

import UIKit
import MapKit

class NearbyFavoriteFoodUIViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var foodName : String!
    
    @IBOutlet weak var foodLabel: UILabel!
    
    @IBOutlet weak var foodMapView: MKMapView!
    
    var locationManager = CLLocationManager()
    
    var searchFood : String = ""

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
        // Do any additional setup after loading the view.
        self.searchFood = self.foodName
        self.initializeLocation()
        self.foodMapView.userTrackingMode = .followWithHeading
        self.findFood()
    }
    

    func initialize()
    {
        self.foodLabel.text = foodName
    }
    
    
    func initializeLocation()
    {
        // called from start up method
        locationManager.delegate = self
        self.foodMapView.delegate = self

        let status = CLLocationManager.authorizationStatus()
        print("initializeLocation()")
        
        switch status
        {
            case .authorizedAlways, .authorizedWhenInUse:
                startLocation()
            case .denied, .restricted:
                print("location not authorized")
                displayAlert()
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
        @unknown default:
            print("initializeLocation(): Error could not determine status for location.")
        }
    }
    
    
    // Delegate method called when location changes
    func locationManager(_ manager: CLLocationManager,
    didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last
        
        if let latitude = location?.coordinate.latitude
        {
            print("Latitude: \(latitude)")
        }
        
        if let longitude = location?.coordinate.longitude
        {
            print("Longitude: \(longitude)")
        }
    }
    
    
    // Delegate method called whenever location authorization status changes
    func locationManager(_ manager: CLLocationManager,
    didChangeAuthorization status: CLAuthorizationStatus)
    {
        if ((status == .authorizedAlways) || (status == .authorizedWhenInUse))
        {
            self.startLocation()
        }
        else
        {
            self.stopLocation()
        }
    }
    
    // Delegate method called if location unavailable (recommended)
    func locationManager(_ manager: CLLocationManager,
    didFailWithError error: Error)
    {
        print("locationManager error: \(error.localizedDescription)")
    }
    
    func startLocation()
    {
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    
    func stopLocation()
    {
        locationManager.stopUpdatingLocation()
    }
    
    
    
    
    func findFood()
    {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = self.searchFood
        request.region = self.foodMapView.region
        
        let search = MKLocalSearch(request: request)
        
        search.start(completionHandler: searchHandler)
    }
    
    
    func searchHandler (response: MKLocalSearch.Response?, error: Error?)
    {
        if let err = error
        {
            print("Error occured in search: \(err.localizedDescription)")
        }
        else if let resp = response
        {
            print("\(resp.mapItems.count) matches found")
            self.foodMapView.removeAnnotations(self.foodMapView.annotations)
            
            for item in resp.mapItems
            {
                let annotation = MKPointAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
                self.foodMapView.addAnnotation(annotation)
            }
        }
    }
    
    
    //No authorization
    func displayAlert()
    {
        let alert = UIAlertController(title: "Next Action",
        message: "Choose your next action.", preferredStyle: .alert)
        
        
        let okayAction = UIAlertAction(title: "Okay", style: .default,
        handler: { (action) in
            // execute some code when this option is selected
            print("Okay!")
            
            //Do nothing
        })
        
        alert.addAction(okayAction)
        alert.preferredAction = okayAction // only affects .alert style
        
        present(alert, animated: true, completion: nil)
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
