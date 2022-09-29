//
//  ViewController.swift
//  Travel Book
//
//  Created by Mahmut Şenbek on 29.09.2022.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var commentTextField: UITextField!
    var choosenLatitude : Double
    var choosenLongtude : Double
    var locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
       // navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem.
        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(tappedMap(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 1.5
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func tappedMap(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            let touchedCoordinate = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            let annotation = MKPointAnnotation()
            choosenLatitude = touchedCoordinate.latitude
            choosenLongtude = touchedCoordinate.longitude
            annotation.coordinate = touchedCoordinate
            annotation.title = nameTextField.text
            annotation.subtitle = commentTextField.text
            self.mapView.addAnnotation(annotation)
        }
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newLocations = NSEntityDescription.insertNewObject(forEntityName: "Locations", into: context)
        
        newLocations.setValue(nameTextField.text, forKey: "name")
        newLocations.setValue(commentTextField, forKey: "comment")
        if nameTextField.text == "" {
            let alert = UIAlertController(title: "Empty Section!", message: "Please write location information.", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "OK!", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true)
        }
        
        newLocations.setValue(choosenLatitude, forKey: "latitude")
        newLocations.setValue(choosenLongtude, forKey: "longtude")
        newLocations.setValue(UUID(), forKey: "id")
        
    
        
    }
    
    
    
}

