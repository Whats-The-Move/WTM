//
//  popUpViewController.swift
//  WTM
//
//  Created by Nikunj  Tyagi on 1/22/23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import MapKit
import CoreLocation

class popUpViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var titleText: String = ""
    var likesLabel: Int = 0
    var dislikesLabel: Int = 0
    var addressLabel: String = ""
    @IBOutlet weak var popupView: UIView!
    
    var databaseRef: DatabaseReference?
    var parties = [Party]()
    
    
    @IBOutlet weak var votesLeftLabel: UILabel!
    @IBOutlet weak var wasItTheMoveLabel: UILabel!
    @IBOutlet weak var num: UILabel!
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downvoteButton: UIButton!
    @IBOutlet weak var upvoteLabel: UILabel!
    @IBOutlet weak var downvoteLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var map: MKMapView!
    
    var locationManger = CLLocationManager()
    
    override func viewDidLoad() {
        
        locationManger.delegate = self
        locationManger.requestAlwaysAuthorization()
        locationManger.requestWhenInUseAuthorization()
        locationManger.startUpdatingLocation()
        map.showsUserLocation = true
        map.userTrackingMode = .follow
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        map.overrideUserInterfaceStyle = .dark
        
        map.delegate = self
        
        popupView.layer.cornerRadius = 8
        print("titleText: \(titleText)")
        print("likes: \(likesLabel)")
        print("address: \(addressLabel)")
        titleLabel.text = titleText
        titleLabel.textColor = .black
        upvoteLabel.text = String(likesLabel)
        upvoteLabel.textColor = .black
        downvoteLabel.text = String(dislikesLabel)
        downvoteLabel.textColor = .black
        num.text = String(votesLabel)
        num.textColor = .black
        votesLeftLabel.textColor = .black
        wasItTheMoveLabel.textColor = .black
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressLabel) {
            placemarks, error in
            let placemark = placemarks?.first
            let lat = (placemark?.location?.coordinate.latitude)!
            let lon = (placemark?.location?.coordinate.longitude)!
            
            //print(lat)
            //print(lon)
            
            let sourceCoordinate = (self.locationManger.location?.coordinate)!
            //print(sourceCoordinate)
            
            let sourcePlaceMark = MKPlacemark(coordinate: sourceCoordinate)
            let destPlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
            
            let sourceItem = MKMapItem(placemark: sourcePlaceMark)
            let destItem = MKMapItem(placemark: destPlaceMark)
            
            let destinationRequest = MKDirections.Request()
            destinationRequest.source = sourceItem
            destinationRequest.destination = destItem
            destinationRequest.transportType = .walking
            
            let directions = MKDirections(request: destinationRequest)
            directions.calculate { (response, error) in
                guard let response = response else {
                    if let error = error {
                        print("Something is wrong.")
                    }
                    return
                }
                let route = response.routes[0]
                self.map.addOverlay(route.polyline)
                self.map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
            
            super.viewDidLoad()
            
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
        
    }
    /*
    func mapThis(destinationCoord : CLLocationCoordinate2D){
        let sourceCoordinate = (locationManger.location?.coordinate)!
        
        let sourcePlaceMark = MKPlacemark(coordinate: sourceCoordinate)
        let destPlaceMark = MKPlacemark(coordinate: destinationCoord)
        
        let sourceItem = MKMapItem(placemark: sourcePlaceMark)
        let destItem = MKMapItem(placemark: destPlaceMark)
        
        let destinationRequest = MKDirections.Request()
        destinationRequest.source = sourceItem
        destinationRequest.destination = destItem
        destinationRequest.transportType = .walking
        destinationRequest.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: destinationRequest)
        directions.calculate { (response, error) in
            guard let response = response else {
                if let error = error {
                    print("Something is wrong.")
                }
                return
            }
            let route = response.routes[0]
            self.map.addOverlay(route.polyline)
            self.map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        }
    }
 */
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = UIColor( red: CGFloat(250/255.0), green: CGFloat(17/255.0), blue: CGFloat(242/255.0), alpha: CGFloat(1.0) )
        return render
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch(CLLocationManager.authorizationStatus()) {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManger.startUpdatingLocation()
        case .denied, .notDetermined, .restricted:
            locationManger.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        //print(locations)
    }
    
    @objc func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func likeButtonTapped(_ sender: Any) {
        //print(titleText)
        //print("liked")
        if(votesLabel > 0){
            let database = Database.database().reference()
            database.child("Parties").child((titleLabel.text)!).updateChildValues(["Likes" : ServerValue.increment(1)])
            database.child("Parties").child((titleLabel.text)!).updateChildValues(["allTimeLikes" : ServerValue.increment(1)])
            let number = Int(upvoteLabel.text!)
            likesLabel = number! + 1
            let votesNumber = Int(num.text!)
            votesLabel = votesNumber! - 1
        } else {
            let alert = UIAlertController(title: "Alert", message: "No votes left!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion:  {
                return
            })
        }
        viewDidLoad()
    }

    @IBAction func dislikeButtonTapped(_ sender: Any) {
        //print(titleText)
        //print("disliked")
        if(votesLabel > 0){
            let database = Database.database().reference()
            database.child("Parties").child((titleLabel.text)!).updateChildValues(["Dislikes" : ServerValue.increment(1)])
            database.child("Parties").child((titleLabel.text)!).updateChildValues(["allTimeDislikes" : ServerValue.increment(1)])
            let number = Int(downvoteLabel.text!)
            dislikesLabel = number! + 1
            let votesNumber = Int(num.text!)
            votesLabel = votesNumber! - 1
        } else {
            let alert = UIAlertController(title: "Alert", message: "No votes left!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion:  {
                return
            })
        }
        viewDidLoad()
    }
    
}
