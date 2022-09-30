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
    var choosenName = ""
    var choosenId : UUID?
    var choosenLatitude = Double()
    var choosenLongtude = Double()
    var locationManager = CLLocationManager()
    var annotationName = ""
    var annotationComment = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(tappedMap(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 1.5
        mapView.addGestureRecognizer(gestureRecognizer)
        
        if choosenName != "" {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Locations")
            let idString = choosenId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                       if let name = result.value(forKey: "name") as? String {
                            annotationName = name
                           
                           if let comment = result.value(forKey: "comment") as? String {
                               annotationComment = comment
                           }
                           if let latitude = result.value(forKey: "latitude") as? Double {
                               annotationLatitude = latitude
                           }
                           if let longtude = result.value(forKey: "longtude") as? Double {
                               annotationLongitude = longtude
                               
                               let annotation = MKPointAnnotation()
                               annotation.title = annotationName
                               annotation.subtitle = annotationComment
                               let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                               annotation.coordinate = coordinate
                               mapView.addAnnotation(annotation)
                               nameTextField.text = annotationName
                               commentTextField.text = annotationComment
                               
                               locationManager.stopUpdatingLocation()
                               
                               let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                               let region = MKCoordinateRegion(center: coordinate, span: span)
                               mapView.setRegion(region, animated: true)
                               
                               
                           }
                        }
                    }
                }
            }catch {
                print("error")
            }
        }
        
        
        
    }
    
    @objc func tappedMap(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            if nameTextField.text == "" {
        
                let alert = UIAlertController(title: "Please write location name information first :) ", message: "", preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "Ok!", style: UIAlertAction.Style.default, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true)
            }else {
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
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if choosenName == "" {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.009 , longitudeDelta: 0.009)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        }else {
            
        }
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reuseID = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKMarkerAnnotationView
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView?.canShowCallout = true
            pinView?.tintColor = UIColor.red
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
            
        }else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    
    @IBAction func saveButton(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newLocations = NSEntityDescription.insertNewObject(forEntityName: "Locations", into: context)
        if nameTextField.text == "" {
            let alert = UIAlertController(title: "Empty Section!", message: "Please write location information.", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "OK!", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true)
        }else {
            newLocations.setValue(commentTextField.text, forKey: "comment")
            newLocations.setValue(nameTextField.text, forKey: "name")
            newLocations.setValue(choosenLatitude, forKey: "latitude")
            newLocations.setValue(choosenLongtude, forKey: "longtude")
            newLocations.setValue(UUID(), forKey: "id")
            do {
                try context.save()
                print("saved")
            }catch {
                print("error")
            }
        }
       
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
}

